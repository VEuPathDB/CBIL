#!@perl@

#---------------------------------------------------
# singleCoverage.pl
#
# Compute single coverage for a BLAST run and 
# display some summary statistics.  Assumes that
# the target database contains only 1 sequence.
#
# Jonathan Crabtree
# $Revision$ $Date$ $Author$
#---------------------------------------------------

use strict;

use CBIL::Bio::BLAST2::BLAST2;
use CBIL::Bio::BLAST2::SBJCT;
use CBIL::Bio::BLAST2::HSP;
use CBIL::Bio::BLAST2::Util;

my $DEBUG = 0;

#---------------------------------------------------
# Input
#---------------------------------------------------

my $blastFile = shift || die "BLAST file must be first argument.";

#---------------------------------------------------
# Main program
#---------------------------------------------------

$| = 1;

#---------------------------------------------------
# Read BLAST file
#
my $blast = &CBIL::Bio::BLAST2::parseBLAST2output( $blastFile );
my $nSubjects = $blast->getNumSbjcts();

if ($nSubjects == 0) {
    print STDERR "No HSPs.";
    exit(0);
} elsif ($nSubjects > 1) {
    die "More than 1 subject sequence in $blastFile";
}

my $subject = $blast->getSbjct(0);
my $nHsps = $subject->getNumHSPs();

my $hsps = [];
for (my $i = 0;$i < $nHsps;++$i) { push(@$hsps, $subject->getHSP($i)); }

#---------------------------------------------------
# Before single coverage
#
print "***Original file contains ", scalar(@$hsps), " HSPs\n\n";
&Util::displayHspStats($hsps);

print "Query coverage (len=", $blast->{query_size} , "):";
my $hc1 = &Util::hspCoverage($hsps, 1);
print " ", scalar(@{$hc1->{intervals}}), " intervals covering ", $hc1->{length}, " bp\n";

print "Subject coverage (len=", $subject->{length} ,"):";
my $hc2 = &Util::hspCoverage($hsps, 0);
print " ", scalar(@{$hc2->{intervals}}), " intervals covering ", $hc2->{length}, " bp\n";
print "\n";

#---------------------------------------------------
# After single coverage
#
my $single = &Util::singleCoverage($hsps);

print "***Single coverage yields ", scalar(@{$single->{hsps}}), " HSPs ",
    "with total score = ", $single->{score}, "\n\n";

&Util::displayHspStats($single->{hsps});

print "Query coverage (len=", $blast->{query_size} , "):";
$hc1 = &Util::hspCoverage($single->{hsps}, 1);
print " ", scalar(@{$hc1->{intervals}}), " intervals covering ", $hc1->{length}, " bp\n";

print "Subject coverage (len=", $subject->{length} ,"):";
$hc2 = &Util::hspCoverage($single->{hsps}, 0);
print " ", scalar(@{$hc2->{intervals}}), " intervals covering ", $hc2->{length}, " bp\n";
print "\n";

