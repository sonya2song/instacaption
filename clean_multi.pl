#!/usr/bin/perl -w

use strict;
use POSIX ":sys_wait_h";

use Data::Dumper;
use WordNet::QueryData;
use DBI;
use DBD::mysql;

my @valid_tags = qw (jj md nn rb uh vb wdt wp wps wrb);
my @invalid_tags = qw (vbd vbg vbn vbp vbz nnp nnps nns rbr rbs rbd jjr jjs );
my @words = ();

my $host_snap = 'xxx.boston.com';
my $host_bizviz = 'xxx.boston.com';

my $db_snap = 'xxx';
my $db_bizviz = 'xxx';

my $user_snap = 'xxx';
my $user_bizviz = 'xxx';

my $pw_snap = 'xxx';
my $pw_bizviz = 'xxx';

my $t_elements = 'elements';
my $t_venue_words = 'venue_words';

# my $dsn_snap = "dbi:mysql:$db_snap:$host_snap;mysql_connect_timeout=36000;mysql_enable_utf8=1";
# my $connect_snap = DBI->connect($dsn_snap, $user_snap, $pw_snap) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the SNAP database...\n";
# $connect_snap->{'AutoCommit'} = 1;
# $connect_snap->{'mysql_auto_reconnect'} = 1;
# my ($query_snap, $query_handle_snap);
# 
my $dsn_bizviz = "dbi:mysql:$db_bizviz:$host_bizviz;mysql_connect_timeout=36000;mysql_enable_utf8=1";
my $connect_bizviz = DBI->connect($dsn_bizviz, $user_bizviz, $pw_bizviz) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the BIZVIZ database...\n";
$connect_bizviz->{'AutoCommit'} = 1;
$connect_bizviz->{'mysql_auto_reconnect'} = 1;
my ($query_bizviz, $query_handle_bizviz);

my @dsn;
my @connect;
my @query;
my @query_handle;

my $num_proc = 0; # active processes
my $num_collect = 0; # already collected
my $collect; # result of waitpid
my $i; # number of forked processes
my $forks = 5; # number of forks
my $block = 100; # number of links checked in one fork
	

$SIG{CHLD} = sub { $num_proc-- };

&copy_valid();

&get_id();

# $query_bizviz = "select count(*) from $t_venue_words where word_valid is null and (word_type='vbd' or word_type='vbg' or word_type='vbn' or word_type='vbz')  ";
# print "QUERY:\t$query_bizviz\n";
# $query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
# $query_handle_bizviz->execute();
# my @count = $query_handle_bizviz->fetchrow_array();
# my $total = @count[0];

for ($i = 0 ; $i < $forks ; $i++)
{
#	print "== $num_proc processes are active\n";
	
	my $pid = fork();

	unless (defined $pid)
	{
		print "ERROR in fork: $!\n";
		exit 1;
	}
	
	if ($pid == 0)
	{
		&validate();
		exit 0;
	}
	else
	{
		$num_proc++; # fork successfully
#		print "Parent $$ forks Child $i #$pid\n";

		if ($i > $num_proc + $num_collect) # zombies exist
		{
			if ($collect = waitpid (-1, WNOHANG) > 0)
			{
				$num_collect++;
			}
		}
		
#		while ($num_proc > 3)
#		{
#			print "Parent $$ is asleep\n";
#			sleep 1;
#		}
#		print "Parent $$ is awake\n";
	}
}

sub copy_valid ()
{
	print "========= copy valid =========\n";

	foreach my $t (@valid_tags)
	{
		$query_bizviz = "update $t_venue_words set word_valid=word_raw where word_type='$t' and word_valid is null ";
		print "QUERY:\t$query_bizviz\n";
		$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
		$query_handle_bizviz->execute();

	}
	
}

sub get_id()
{
	print "========= get id =========\n";

	foreach my $t (@invalid_tags)
	{
		$query_bizviz = "select id, word_raw, word_type from $t_venue_words where word_valid is null and word_type='$t' ";
		print "QUERY:\t$query_bizviz\n";
		$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
		$query_handle_bizviz->execute();
		
		while (my @row = $query_handle_bizviz->fetchrow_array())
		{
			push @words, join ':', @row;
		}
	last if scalar @words >= $forks * $block;
	}
	
#	print Dumper @words;
}

sub validate()
{
	print "========= fork [$i] validate words ========= \n";

	$dsn[$i] = "dbi:mysql:$db_bizviz:$host_bizviz;mysql_connect_timeout=36000;mysql_enable_utf8=1";
	$connect[$i] = DBI->connect($dsn_bizviz, $user_bizviz, $pw_bizviz) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the BIZVIZ database...\n";
	$connect[$i]->{'AutoCommit'} = 1;
	$connect[$i]->{'mysql_auto_reconnect'} = 1;
	
	my @slice = @words[$i*$block..$i*$block+$block-1];
	my $j = 0;
	
	foreach my $line (@slice)
	{
		$j++;
		print "fork[$i/$forks]; block[$j/$block]: \t";
		my ($id, $raw, $type) = split ':', $line;
		my $valid = '';
		print "raw: $raw, type: $type, ";
	
		$type = 'v' if $type =~ m/^v/i;
		$type = 'a' if $type =~ m/^j/i;
		$type = 'n' if $type =~ m/^n/i;
		$type = 'r' if $type =~ m/^r/i;
		
		my $wn = WordNet::QueryData->new;
		my @rest = ();
		($valid, @rest) = $wn->validForms("$raw#$type");
	
		if (defined $valid)
		{
			$valid = $1 if $valid =~ m/(\w+)\#\w/i;
			print "new_type: $type, valid: $valid\n";
			$query[$i] = "update $t_venue_words set word_valid='$valid' where id='$id' ";
#			print ">>> QUERY:\t$query[$i]\n";
			$query_handle[$i] = $connect[$i]->prepare($query[$i]);
			$query_handle[$i]->execute();
		}
		else 
		{
			print "+++ didn't get it\n";
			$query[$i] = "update $t_venue_words set word_valid='TBD' where id='$id' ";
#			print ">>> QUERY:\t$query[$i]\n";
			$query_handle[$i] = $connect[$i]->prepare($query[$i]);
			$query_handle[$i]->execute();
		}
	}

	if ($num_proc == $forks - 1 and $j == $block)
	{
		print "The CLEAN MULTI ends at \t", scalar localtime(), "\n";
	}

	return;
}



