#!/usr/bin/perl 

use strict;
use Data::Dumper;
use WordNet::QueryData;
use DBI;
use DBD::mysql;

my @tags = ('cd', 'jj', 'jjr', 'jjs', 'md', 'nn', 'nnp', 'nnps', 'nns', 'rb', 'rbr', 'rbs', 'uh', 'vb', 'vbd', 'vbg', 'vbn', 'vbp', 'vbz', 'wdt', 'wp', 'wps', 'wrb');
my %tags = ();
foreach my $tag (@tags)
{
	$tags{$tag} = 1;
}
# print Dumper \%tags;

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
my $forks = 1; # number of forks
my $block = 5; # number of links checked in one fork

my @entries = ();

$SIG{CHLD} = sub { $num_proc-- };

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

sub getid()
{
	print "+++ get id \n";

	$query_bizviz = "select id, word_raw, word_type from $t_venue_words where word_valid is null and (word_type like 'jj_' or word_type='vbg' or word_type='vbn' or word_type='vbz') ";
	print "QUERY:\t$query_bizviz\n";
	$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
	$query_handle_bizviz->execute();
	
	while (my @row = $query_handle_bizviz->fetchrow_array())
	{
	}
}

sub validate()
{
	print "+++ validate words \n";

	$dsn[$i] = "dbi:mysql:$db_bizviz:$host_bizviz;mysql_connect_timeout=36000;mysql_enable_utf8=1";
	$connect[$i] = DBI->connect($dsn_bizviz, $user_bizviz, $pw_bizviz) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the BIZVIZ database...\n";
	$connect[$i]->{'AutoCommit'} = 1;
	$connect[$i]->{'mysql_auto_reconnect'} = 1;
	
	my @slice = @entries[$i*$block..$i*$block+$block-1];
	
	foreach my $line (@slice)
	{
# 		my $id = $row[0];
# 		my $raw = $row[1];
# 		my $type = $row[2];
# 		my $valid = '';
# 		print "raw: $raw, type: $type, ";
# 	
# 		$type = 'v' if $type =~ m/vb*/i;
# 		my $wn = WordNet::QueryData->new;
# 		my @rest = ();
# 		($valid, @rest) = $wn->validForms("$raw#$type");
# 		$valid = $1 if $valid =~ m/(\w+)\#\w/i;
# 	
# 		print "new_type: $type, valid: $valid\n";
# 	
# 		unless ($valid eq '')
# 		{
# 			$query = "update $t_venue_words set word_valid='$valid' where id='$id' ";
# 			print "QUERY:\t$query\n";
# 			$query_handle = $connect->prepare($query);
# 			$query_handle->execute();
# 		}
# 		else 
# 		{
# 			print ">>> didn't get it\n";
# 			next;
# 		}
	}
	
}



