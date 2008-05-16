#!/usr/bin/perl

#---------------------------------------------------
# Util.pm
#
# A set of utilities for post-processing BLAST 
# output.
#
# Jonathan Crabtree
# $Revision$ $Date$ $Author$
#---------------------------------------------------

use strict;

package CBIL::Bio::BLAST2::Util;

use CBIL::Bio::BLAST2::BLAST2;
use CBIL::Bio::BLAST2::SBJCT;
use CBIL::Bio::BLAST2::HSP;

my $DEBUG = 0;

#---------------------------------------------------
# filterHsps
#
# Filter HSPs by p-value, % identity and length.
#---------------------------------------------------

# Filter a set (arrayref) of HSPs by p-value, percent identity, 
# and length.  Returns an arrayref containing the HSPs that
# meet the cut.
#
sub filterHsps {
    my($hsps, $minPctId, $minLen, $maxPval) = @_;
    my $result = [];

    foreach my $h (@$hsps) {
	my $pctId = ($h->{identities} / $h->{length}) * 100.0;

	if (($pctId >= $minPctId) && 
	    ($h->{length} >= $minLen) && 
	    ($h->{pval} <= $maxPval)) 
	{
	    push (@$result, $h);
	}
    }

    return $result;
}

#---------------------------------------------------
# displayHspStats
#
# Display summary statistics for a set of HSPs.
#---------------------------------------------------

sub displayHspStats {
    my($hsps) = @_;
    
    my $minPctId = undef;
    my $maxPctId = undef;
    my $minLen = undef;
    my $maxLen = undef;
    my $minPval = undef;
    my $maxPval = undef;

    my $totalLen = 0;
    my $totalIds = 0;

    my $numPlusStrand = 0;
    my $numRevStrand = 0;

    my $nHsps = scalar(@$hsps);

    for (my $i = 0;$i < $nHsps;++$i) {
	my $h = $hsps->[$i];
	my $pctId = int(($h->{identities} / $h->{length}) * 100.0 + 0.5);

	$totalIds += $h->{identities};
	$totalLen += $h->{length};

	if ($h->{strand} =~ /\+\d|Plus \/ Plus/) {
	    ++$numPlusStrand;
	} else {
	    ++$numRevStrand;
	}

	if ($i == 0) {
	    $minPctId = $pctId;
	    $maxPctId = $minPctId;
	    $minLen = $h->{length};
	    $maxLen = $minLen;
	    $minPval = $h->{pval};
	    $maxPval = $minPval;
 	} else {
	    $minPctId = $pctId if ($pctId < $minPctId);
	    $maxPctId = $pctId if ($pctId > $maxPctId);
	    $minLen = $h->{length} if ($h->{length} < $minLen);
	    $maxLen = $h->{length} if ($h->{length} > $maxLen);
	    $minPval = $h->{pval} if ($h->{pval} < $minPval);
	    $maxPval = $h->{pval} if ($h->{pval} > $maxPval);
	}
    }

    my $avgPctId = int(($totalIds / $totalLen) * 100.0 + 0.5);

    print "HSPS: $nHsps ($numPlusStrand plus strand, $numRevStrand minus strand)\n";
    print "Length: ", &formatStats($minLen, $maxLen, $totalLen / $nHsps), "\n";
    print "Percent identity: ", &formatStats($minPctId, $maxPctId, $avgPctId), "\n";
    print "P-value: ", &formatStats($minPval, $maxPval, undef), "\n";
    print "\n";
}

sub formatStats {
    my($min, $max, $avg) = @_;
    my $result = "min=$min, max=$max";
    $result .= " avg=$avg" if defined($avg);
    return $result;
}

#---------------------------------------------------
# hspCoverage
#
# Determine how completely a set of hsps cover the
# BLAST query or subject sequence.
#---------------------------------------------------

# Returns a hashref
#
# {intervals => $newIntervals, length => $totalLen};
#
# where $totalLen is the amount of query/subject covered
# by the HSPs and $newIntervals is an arrayref of hashrefs
# of the form {q_start => $x, q_end => $y} (query sequence)
# or {s_start => $x, s_end => $y} (subject sequence)
#
sub hspCoverage {
    my($hsps, $isQuery) = @_;
    my($start, $end);
    
    if ($isQuery) {
	$start = 'q_start';
	$end = 'q_end';
    } else {
	$start = 's_start';
	$end = 's_end';
    }

    # 1. order by start coordinate
    #
    my @sorted = sort { $a->{$start} <=> $b->{$start} } @$hsps;

    # 2. scan from left to right, unioning all overlapping intervals
    # 3. add up their lengths as we go
    #
    my $newIntervals = [];
    my $current = undef;
    my $totalLen = 0;

    foreach my $hsp (@sorted) {
	my $hx = $hsp->{$start};
	my $hy = $hsp->{$end};

	if ($hy < $hx) {
	    my $tmp = $hy;
	    $hy = $hx;
	    $hx = $tmp;
	}

	print "HSP $hx - $hy\n" if ($DEBUG);
	
	if (not defined($current)) {
	    $current = {$start => $hx, $end => $hy};
	} else {
	    my $cx = $current->{$start};
	    my $cy = $current->{$end};

	    # Union if overlap, otherwise push the current
	    # interval.
	    #
	    if ($hx < $cy) {
		$current->{$end} = $hy;
	    } else {
		push(@$newIntervals, $current);
		print "  ", $current->{$start}, " - ", $current->{$end}, "\n" if ($DEBUG);
		$totalLen += ($current->{$end} - $current->{$start});
		$current = {$start => $hx, $end => $hy};
	    }
	}
    }
    push(@$newIntervals, $current) if (defined($current));
    print "  ", $current->{$start}, " - ", $current->{$end}, "\n" if ($DEBUG);
    $totalLen += ($current->{$end} - $current->{$start});
    return {intervals => $newIntervals, length => $totalLen};
}

#---------------------------------------------------
# singleCoverage
#
# Find a high-scoring set of HSPs, no two of which
# overlap with respect to the query sequence.
#---------------------------------------------------

# Returns a hashref {hsps => $arrayref, $score => $score}
# containing the optimal score and an optimal solution 
# (of which there may be more than one.)
#
sub singleCoverage {
    my($hsps) = @_;

    my @sorted = sort { $a->{q_start} <=> $b->{q_start} } @$hsps;
    my $nHsps = scalar(@$hsps);

    # Array of solutions
    #
    my $solutions = [];

    # Fill in the solution array from right to left.
    # Each cell holds the highest-scoring set of alignments
    # using only alignments $i and above.

    # Base case
    #
    $solutions->[$nHsps] = { includeThisOne => 0, score => 0 };

    for (my $i = $nHsps - 1;$i >= 0;--$i) {
	my $hsp = $sorted[$i];

	# Two possible ways to get an optimal solution:

	# 1. Use this HSP and the best solution using only HSPs 
	#    that start to the right of it.
	#
	my $j = &hspByMinQueryStart(\@sorted, $i + 1, $nHsps, $hsp->{q_end} + 1);
	my $ss1 = $solutions->[$j];
	my $soln1 = { 
	    includeThisOne => 1,
	    score => ($ss1->{score} + $hsp->{score}),
	    next => $j
	};

	# 2. Don't use this HSP; take instead the best solution
	#    using only HSPs to its right in the sorted array.
	#
	my $soln2 = {
	    includeThisOne => 0,
	    score => $solutions->[$i + 1]->{score},
	    next => $i + 1
	};

	if ($DEBUG) {
	    print "i = $i\n";

	    print "soln1: ";
	    print "score=", $soln1->{score}, " ";
	    print "includeThisOne=", $soln1->{includeThisOne}, "\n";
	    
	    print "soln2: ";
	    print "score=", $soln2->{score}, " ";
	    print "includeThisOne=", $soln2->{includeThisOne}, "\n";
	}

	# Put the better one in this cell
	#
	if ($soln1->{score} > $soln2->{score}) {
	    $solutions->[$i] = $soln1;
	} else {
	    $solutions->[$i] = $soln2;
	}
    }

    # Traverse the solution array from left to right, reading out
    # the chosen optimal solution.
    #
    my $result = [];
    my $sanityCheck = 0;
    my $i = 0;

    while ($i < $nHsps) {
	my $cell = $solutions->[$i];
	if ($cell->{includeThisOne}) {
	    push(@$result, $sorted[$i]);
	    $sanityCheck += $sorted[$i]->{score};
	}
	$i = $cell->{next};
    }

    if ($sanityCheck != $solutions->[0]->{score}) {
	print "Direct count of score = $sanityCheck\n";
	print "Best solution score = ", $solutions->[0]->{score}, "\n";
	die "Score mismatch.\n"
    }

    return {hsps => $result, score => $solutions->[0]->{score}};
}

# Given a list of HSPs sorted by q_start, find the index of the
# first whose q_start greater than or equal to the specified value.
# Returns $nHsps if there is no such HSP.  Used by singleCoverage.
#
sub hspByMinQueryStart {
    my($hsps, $first, $nHsps, $minQStart) = @_;
    my $result = $nHsps;

    for (my $i = $first;$i < $nHsps;++$i) {
	my $h = $hsps->[$i];
	if ($h->{q_start} >= $minQStart) {
	    $result = $i;
	    last;
	}
    }
    return $result;
}


1;
