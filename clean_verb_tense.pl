#!/usr/bin/perl 

use strict;
use Data::Dumper;
use Lingua::EN::VerbTense qw(sFormPartInf);
# use Lingua::EN::Tagger;
# use XML::LibXML;
# use XML::Simple;
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

my $dsn = "dbi:mysql:$db_bizviz:$host_bizviz;mysql_connect_timeout=36000;mysql_enable_utf8=1";
my $connect = DBI->connect($dsn_bizviz, $user_bizviz, $pw_bizviz) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the BIZVIZ database...\n";
$connect->{'AutoCommit'} = 1;
$connect->{'mysql_auto_reconnect'} = 1;
my ($query, $query_handle);


# $query_snap = "select uuid, caption_text, listed_location_name from $t_elements where length(caption_text)>3 and length(listed_location_name)>2  ";
# # $query_snap = "select uuid, caption_text, listed_location_name from $t_elements where id=5905 limit 10 ";
# # print "QUERY:\t$query_snap\n";
# $query_handle_snap = $connect_snap->prepare($query_snap);
# $query_handle_snap->execute();

$query_bizviz = "select count(*) from $t_venue_words where word_valid is null and (word_type='vbd' or word_type='vbg' or word_type='vbn' or word_type='vbz')  ";
print "QUERY:\t$query_bizviz\n";
$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
$query_handle_bizviz->execute();
my @count = $query_handle_bizviz->fetchrow_array();
my $total = @count[0];
my $i = 0;

$query_bizviz = "select id, word_raw, word_type from $t_venue_words where word_valid is null and (word_type='vbd' or word_type='vbg' or word_type='vbn' or word_type='vbz') ";
print "QUERY:\t$query_bizviz\n";
$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
$query_handle_bizviz->execute();

while (my @row = $query_handle_bizviz->fetchrow_array())
{
	print $i++, "/", $total, "\n";	
	
#	print join " | ", @row, "\n";
	my $id = $row[0];
	my $raw = $row[1];
	my $type = $row[2];
	my $valid;
	print "verb: $raw, type: $type, ";

# VB      Verb, infinitive                        take, live
# VBD     Verb, past tense                        took, lived
# VBG     Verb, gerund                            taking, living
# VBN     Verb, past/passive participle           taken, lived
# VBP     Verb, base present form                 take, live
# VBZ     Verb, present 3SG -s form               takes, lives
	$type = 'Past' if $type eq 'vbd';
	$type = 'Gerund' if $type eq 'vbg';
	$type = 'Part' if $type eq 'vbn';
	$type = 'Third' if $type eq 'vbz';
	
	$valid = '';
	$valid = sFormPartInf($raw, $type);
	print "new_type: $type, inf: $valid\n";

	unless ($valid eq '')
	{
		$query = "update $t_venue_words set word_valid='$valid' where id='$id' ";
		print "QUERY:\t$query\n";
		$query_handle = $connect->prepare($query);
		$query_handle->execute();
	}
	else 
	{
		print ">>> didn't get it\n";
		next;
	}
# 	$query_bizviz = "select count(*) from $t_venue_words where uuid='$uuid' ";
# #	print "QUERY:\t$query_bizviz\n";
# 	$query_handle_bizviz = $connect_bizviz->prepare($query_bizviz);
# 	$query_handle_bizviz->execute();
	

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
