#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use Lingua::EN::Tagger;
use XML::LibXML;
use XML::Simple;
use DBI;
use DBD::mysql;
#use Encode;

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

my $dsn_snap = "dbi:mysql:$db_snap:$host_snap;mysql_connect_timeout=36000;mysql_enable_utf8=1";
my $connect_snap = DBI->connect($dsn_snap, $user_snap, $pw_snap) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the SNAP database...\n";
$connect_snap->{'AutoCommit'} = 1;
$connect_snap->{'mysql_auto_reconnect'} = 1;
my ($query_snap, $query_handle_snap);

my $dsn_bizviz = "dbi:mysql:$db_bizviz:$host_bizviz;mysql_connect_timeout=36000;mysql_enable_utf8=1";
my $connect_bizviz = DBI->connect($dsn_bizviz, $user_bizviz, $pw_bizviz) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the BIZVIZ database...\n";
$connect_bizviz->{'AutoCommit'} = 1;
$connect_bizviz->{'mysql_auto_reconnect'} = 1;
my ($query_bizviz, $query_handle_bizviz);

$query_snap = "select uuid, caption_text, listed_location_name from $t_elements where length(caption_text)>3 and length(listed_location_name)>2  ";
# $query_snap = "select uuid, caption_text, listed_location_name from $t_elements where id=5905 limit 10 ";
# print "QUERY:\t$query_snap\n";
$query_handle_snap = $connect_snap->prepare($query_snap);
$query_handle_snap->execute();

my $total = 1190572;
my $i = 0;
while (my @row = $query_handle_snap->fetchrow_array())
{
	print $i++, "/", $total, "\n";	
	next if $i < 250_000;
	
#	print join " | ", @row, "\n";
	my $uuid = $row[0];
	my $listed_location_name = $row[2];
	$listed_location_name =~ s/'/\\'/g;
	$listed_location_name =~ s/"/\\"/g;
#	$listed_location_name = $query_handle_snap->quote($listed_location_name);
	
	$query_bizviz = "select count(*) from $t_venue_words where uuid='$uuid' ";
#	print "QUERY:\t$query_bizviz\n";
	$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
	$query_handle_bizviz->execute();
	
	my @count = $query_handle_bizviz->fetchrow_array();
#	print "BIZVIZ uuid count: ",  $count[0], "\n";
	unless ($count[0] == 0)
	{
		print " >>> uuid exists.\n";
		next;
	}
	
	my $text = lc $row[1];
	$text =~ s/[^[:ascii:]]+//g;
	$text =~ s/@\w+//g;
	$text =~ s/[\&\`\^\<\>\(\)\[\]\{\}\/\\\|]//g;
#	$text = $query_handle_snap->quote($text);
	
	my $p = new Lingua::EN::Tagger;
	my $tagged_text = $p->add_tags($text);
#	print "$tagged_text\n";
	
	my $xs = new XML::Simple;
	my $ref = $xs->XMLin("<root>$tagged_text</root>");
	
	foreach my $pos (sort keys %$ref)
	{
		my @words = ();
		my %words = ();
		if (ref $ref->{$pos})
		{
			foreach my $w (@{$ref->{$pos}})
			{
				$words{ $w } = 1 unless ($w =~ m/'/ or length $w<2);
			}
		}
		else
		{
			$words{ $ref->{$pos} } = 1 unless ($ref->{$pos} =~ m/'/ or length $ref->{$pos}<2);
		}
		
		if (not defined $tags{$pos})
		{
#			print "EXCLUDED TAG >>> ", "<$pos>:\t", join ', ', @words, "\n";
			next;
		}
		
		@words = keys %words;
#		print "<$pos>:\t", join ', ', @words, "\n";
		foreach my $w (@words)
		{
			my $ww = $w;
			$ww =~ s/'/\\'/g;
			$ww =~ s/"/\\"/g;
			$query_bizviz = "insert into $t_venue_words (listed_location_name, word_raw, word_type, source, uuid) value ('$listed_location_name', '$w', '$pos', 'instagram', '$uuid' )";
#			print "QUERY:\t$query_bizviz\n";
			$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
			$query_handle_bizviz->execute();
			
		}
	}

#	print "\n", '-'x60, "\n";
}

# $query_bizviz = "select uuid from $t_venue_words";
# print "QUERY:\t$query_bizviz\n";
# $query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
# $query_handle_bizviz->execute();
# 
# while (my @row = $query_handle_bizviz->fetchrow_array())
# {
# 	print "BIZVIZ:",  $row[0], "\n";
# }

# my $xp = new XML::LibXML;
# my $r = $xp->parse_string($tagged_text);
# 
# for my $n ($r->findnodes('root'))
# {
# 	for my $child ($n->getChildnodes())
# 	{
# 		if ($child->nodeType() == XML_ELEMENT_NODE) 
# 		{
# 			print $child->nodeName(), "\t", $child->textContent(), "\n";
# 		}
# 	}
# }
# print Dumper $r;
#print "readable: $readable_text\n";
#print '-'x60, "\n";
#print Dumper %word_list;
