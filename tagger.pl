#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use Lingua::EN::Tagger;
use XML::LibXML;
use XML::Simple;
use DBI;
use DBD::mysql;
#use Encode;

my $host_snap = 'xxx.boston.com';
my $host_bizviz = 'xxx.boston.com';


my $db_snap = 'xxx';
my $db_bizviz = 'xxx';

my $user_snap = 'xxx';
my $user_bizviz = 'xxx';

my $pw_snap = 'xxx';
my $pw_bizvis = 'xxx';

my $t_elements = 'elements';
my $t_venue_words = 'venue_words';

my $dsn_snap = "dbi:mysql:$db_snap:$host_snap;mysql_connect_timeout=36000;mysql_enable_utf8=1";
my $connect_snap = DBI->connect($dsn_snap, $user_snap, $pw_snap) or die "\tWARNING (", scalar localtime(), ")\n\t", "can't connect the SNAP database...\n";
$connect_snap->{'AutoCommit'} = 1;
$connect_snap->{'mysql_auto_reconnect'} = 1;
my ($query_snap, $query_handle_snap);

my $text = "WASHINGTON, Feb 20 (Reuters) - President Barack Obama turned to local television stations across the United States on Wednesday to increase public pressure on congressional Republicans to avert \$85 billion in budget cuts set to begin in nine days.

Obama scheduled interviews with television stations in eight markets, most of which have a strong military presence, on a day when the Pentagon was set to describe its plans for laying off some 800,000 civilian employees for 22 days to save money.

The interviews are part of an administration strategy to lay blame for the job losses on Republicans, who control the House of Representatives.

Unless Obama and Republicans reach a deal, about \$85 billion in across-the-board spending cuts will kick in at the beginning of March and continue through Sept. 30 as part of a decade-long \$1.2 trillion budget savings plan agreed in 2011.";

# my $text = "123";
my $p = new Lingua::EN::Tagger;
my $tagged_text = $p->add_tags($text);
# print "tagged text: \n$tagged_text\n";

# my %nouns = $p->get_noun_phrases($tagged_text);
# my %nouns = $p->get_proper_nouns($tagged_text);
# print "proper nouns: \n";
# print Dumper %nouns;

#my %word_list = $p->get_words($text);
#my $readable_text = $p->get_readable($text);

my $xs = new XML::Simple;
my $ref = $xs->XMLin("<root>$tagged_text</root>");
# print Dumper $ref; 

foreach my $pos (sort keys %$ref)
{
	my $str = $ref->{ $pos };
	$str = join(', ', @{$ref->{ $pos }}) if (ref $ref->{ $pos });
	print $pos, ": ",  $str, "\n";
}


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
