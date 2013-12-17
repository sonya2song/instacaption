#!/usr/bin/perl -w
use strict;

#functional simple way
#OO more musical way
use Audio::Beep;

my $beeper = Audio::Beep->new();

			# lilypond subset syntax accepted
			# relative notation is the default 
			# (now correctly implemented)
my $music = "g' f bes' c8 f d4 c8 f d4 bes c g f2";
			# Pictures at an Exhibition by Modest Mussorgsky

$beeper->play( $music );