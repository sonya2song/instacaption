#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use WordNet::QueryData;

my $wn = WordNet::QueryData->new;
# print join "\n", sort $wn->listAllWords("verb"), "\n";
#print "ants: ", join (", ", $wn->queryWord("book#n#1", "ants")), "\n";
print "validForms: ", join(", ", $wn->validForms("happier#a")), "\n";
#print "Forms: ", join(", ", $wn->validForms("lay down")), "\n";
#print "lexname: ", join(", ", $wn->lexname("lay down#v")), "\n"; #not working

#print "Noun count: ", scalar($wn->listAllWords("noun")), "\n";
#print "Parts of Speech: ", join(", ", $wn->querySense("running")), "\n";
#print "Parts of Speech: ", join(", ", $wn->queryWord("running")), "\n";
 
# print "ants: ", join (", ", $wn->queryWord("book", "ants")), "\n";
# print "synset: ", join (", ", $wn->querySense("organize#v#1", "syns")), "\n";
# print "deri: ", join (", ", $wn->queryWord("organize#v#1", "deri")), "\n";

# print "validForms: ", join (", ", $wn->queryWord("book#v", "validForms")), "\n";
# 
# 
# print "synset: ", join (", ", $wn->querySense("booking#v", "syns")), "\n";
# print "domn: ", join (", ", $wn->querySense("book#n", "domn")), "\n";
# print "dmnc: ", join (", ", $wn->querySense("book#n", "dmnc")), "\n";
# print "dmnu: ", join (", ", $wn->querySense("book#n", "dmnu")), "\n";
# print "dmnr: ", join (", ", $wn->querySense("book#n", "dmnr")), "\n";
# 
# print "lexname: ", join (", ", $wn->querySense("book#n", "lexname")), "\n";