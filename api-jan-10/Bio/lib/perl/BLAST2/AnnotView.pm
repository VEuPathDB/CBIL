#!/usr/bin/perl

# ----------------------------------------------------------
# Generate bioWidget AnnotView output from a BLAST2
# object.
#
# Created: Mon Jul 10 10:59:02 EDT 2000
#
# Jonathan Crabtree
# ----------------------------------------------------------

use strict;

package CBIL::Bio::BLAST2::AnnotView;

use CBIL::Bio::BLAST2::BLAST2;
use BioWidgets::AnnotView;

# blastSpans
#
# $b2
# $limits    hash with keys 'minHspPctId', 'minHspLen'
# $format    hash with keys 'showTitles', 'showIntrons', 'intronFuzz'
#
# Returns a ref to hash containing two array refs, i.e.
# {'forward' => \@fwdSpans, 'reverse' => \@revSpans}
#
sub blastSpans {
    my(
       $b2,			# CBIL::Bio::BLAST2::BLAST2 object
       $limits,
       $format,
       ) = @_;

    my $minHspLen = ($limits->{'minHspLen'} =~ /^\d+$/) ? $limits->{'minHspLen'} : 0;
    my $minHspPctId = ($limits->{'minHspPctId'} =~ /^\d+(\.\d+)?$/) ? $limits->{'minHspPctId'} : 0;
    my $intronFuzz = ($limits->{'intronFuzz'} =~ /^\d+$/) ? $limits->{'intronFuzz'} : 0;
    my $units = ($b2->{'program'} =~ /^BLASTN|BLASTX|TBLASTX$/) ? "bp" : "aa";

    # Store qualifying HSPs, grouped by subject, in an array
    #
    my @fwdSpans; my @revSpans;

    my $nSbs = $b2->getNumSbjcts();
    my @subjects;

    foreach my $s (0 .. $nSbs-1) {
	my $sb = $b2->getSbjct($s);
	my $nHsps = $sb->getNumHSPs();

	my @hsps;

	foreach my $h (0 .. $nHsps-1) {
	    my $hsp = $sb->getHSP($h);
	    my $pctId = $hsp->{'identities'} / $hsp->{'length'};

	    if (($pctId >= $minHspPctId) && ($hsp->{'length'} >= $minHspLen)) {
		push(@hsps, $hsp);
	    }
	}

	push(@subjects, {'subject' => $sb, hsps => \@hsps}) if (scalar(@hsps) > 0);
    }
    
    my $nSubs = 0;

    # Generate a span for each subject
    #
    foreach my $sb (@subjects) {
	my $s = $sb->{'subject'};
	my $hsps = $sb->{'hsps'};

	my ($xMin, $xMax);
	my $hspStr = "";
	my $hNum = 0;

	# Order the hsps by position.
        #
	my @sorted = sort{ $a->{'q_start'} <=> $b->{'q_start'} } @$hsps;
	my $strand;

	for (my $h = 0;$h < scalar(@sorted); ++$h) {
	    my $hsp = $sorted[$h];
	    my $pctId = int(($hsp->{'identities'} / $hsp->{'length'}) * 100);
	    my $len = $hsp->{'length'};
	    
	    $hspStr .= ",\n\t" if ($hNum++ > 0);
	    my $color;

	    if ($len >= 200) {
		$color = $AnnotView::red;
	    } else {
		$color = $AnnotView::lred;
	    }

	    my $x1 = ($hsp->{'q_start'} <= $hsp->{'q_end'}) ? $hsp->{'q_start'} : $hsp->{'s_end'};
	    my $x2 = ($hsp->{'q_start'} <= $hsp->{'q_end'}) ? $hsp->{'q_end'} : $hsp->{'s_start'};

	    # Draw inferred "intron"
	    #
	    if ($hspStr ne "") {
		my $lastHsp = $sorted[$h-1];

		my $lastSMax = ($lastHsp->{s_start} > $lastHsp->{s_end}) ? $lastHsp->{s_start} : $lastHsp->{s_end};
		my $lastQMax = ($lastHsp->{q_start} > $lastHsp->{q_end}) ? $lastHsp->{q_start} : $lastHsp->{q_end};

		my $thisSMin = ($hsp->{s_start} > $hsp->{s_end}) ? $hsp->{s_end} : $hsp->{s_start};
		my $thisQMin = ($hsp->{q_start} > $hsp->{q_end}) ? $hsp->{q_end} : $hsp->{q_start};

		my ($iX1, $iX2);

		if ((abs($lastSMax - $thisSMin) < $intronFuzz) && ($format->{'showIntrons'})) {
		    $hspStr .= &span(&simpleSpanLocn($lastQMax, $thisQMin),
				     &direction(1),
				     &seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
				     &mapSpanInfo(&simpleSpanShape($AnnotView::lred, 2),
						  &mapSymbols(()), &simplePacker(1)), undef, undef,
				     undef, undef, undef, "Inferred intron", undef);
		    $hspStr .= ",\n\t";
		}
	    }

	    if (not defined($xMin)) { $xMin = $hsp->{'q_start'}; $xMax = $hsp->{'q_end'}; }
	    $xMin = $hsp->{'q_start'} if ($hsp->{'q_start'} < $xMin);
	    $xMax = $hsp->{'q_end'} if ($hsp->{'q_end'} > $xMax);

	    my $ss = $hsp->{'s_start'};
	    my $se = $hsp->{'s_end'};
	    $strand = $hsp->{'strand'};

	    my $hspDescr = "$len $units at $pctId% (subject=${ss}-${se})";
	    my $hspDescrShort = "$len $units at $pctId%"; 

	    $hspStr .= &span(&simpleSpanLocn($hsp->{q_start}, $hsp->{q_end}),
			     &direction(1), &seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
			     &mapSpanInfo(&simpleSpanShape($color, 8),
					  &mapSymbols(()), &simplePacker(1, 0)), undef, undef,
			     undef, $hspDescrShort, undef, $hspDescr);
	}

	# Add hyperlinks and stuff.
	#
	my $symbols;
	my $descr = $s->{'description'};
	$descr =~ s/\s+/ /g;

	if ($format->{'showTitles'}) {
	    my $lbl = &floatingLblSymShape($descr, 0, 0, $AnnotView::ss10);
	    my $sym = &mapSymbol(&compassPoint('NORTH'), $lbl);
	    $symbols = &mapSymbols(($sym));
	} else {
	    $symbols = &mapSymbols(());
	}

	my $span = &spanStart(&simpleSpanLocn($xMin, $xMax),
			      &direction(1), &seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
			      &mapSpanInfo(&surroundingSpanShape(0, $AnnotView::white, $AnnotView::grey200),
					   $symbols, &oneLineMapPacker(1)), undef, undef,
			      undef, $descr, undef, $descr);
	$span .= ",\nsubpart={\n" . $hspStr . "}]\n";

#	print STDERR "strand = $strand descr=$descr\n";

	my $isForward = undef;

	if ($strand =~ /Minus \/ Plus/) {
	    $isForward = '0';
	} elsif ($strand =~ /Plus \/ Plus/) {
	    $isForward = '1';
	} elsif ($strand =~ /\+\d/) {
	    $isForward = '1';
	} elsif ($strand =~ /\-\d/) {
	    $isForward = '0';
	}

	if (not defined($isForward)) { push(@fwdSpans, $span); }
	elsif ($isForward) { push(@fwdSpans, $span); } else { push(@revSpans, $span); }
    }
    return {'forward' => \@fwdSpans, 'reverse' => \@revSpans};
}

1;
