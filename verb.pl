#!/usr/bin/perl 

use strict;
use Data::Dumper;
use Lingua::EN::VerbTense qw(sFormPartInf);
#use Lingua::EN::Tagger;
#use XML::LibXML;
#use XML::Simple;
use DBI;
use DBD::mysql;
#use Encode;

## sFormPart is listed as a sub in the doc, which is wrong
## sFormPartInf has to be explicitly included in the header
## "Part" represent "past participle" 过去分词

my $string = sFormPartInf("going","Gerund");
print "going: $string\n";
$string = sFormPartInf("goes", "Third");
print "goes: $string\n";

$string = sFormPartInf("went", "Past");
print "went: $string\n";

$string = sFormPartInf("hung", "Past");
print "hung: $string\n";

$string = 'It is eat already.'
# my ($modality, $tense, $inf) = verb_tense($string);
# print "$modality, $tense, $inf\n";