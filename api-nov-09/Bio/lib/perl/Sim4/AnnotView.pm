#!/usr/bin/perl

# ----------------------------------------------------------
# AnnotView.pm
#
# Generate bioWidget AnnotView output from a Sim4 object.
#
# $Revision$ $Date$ $Author$
#
# Jonathan Crabtree
# ----------------------------------------------------------

use strict;

package CBIL::Bio::BLAST2::AnnotView;

use Sim4::Sim4;
use BioWidgets::AnnotView;

my $DOTS_URL = 'http://www.allgenes.org/gc/servlet?page=rna&id=';

sub alignmentSetToAnnotViewSpans {
    my($aligns, $subjectLen, $descr, $colorFn, $descrFn) = @_;
    my $fwdSpans = [];
    my $revSpans = [];

    foreach my $align (@$aligns) {
	if ($align->isReversed()) {
	    push(@$revSpans, &alignmentToAnnotView($align, $colorFn, $descrFn));
	} else {
	    push(@$fwdSpans, &alignmentToAnnotView($align, $colorFn, $descrFn));
	}
    }
    return {forward => $fwdSpans, reverse => $revSpans};
}

# Create an AnnotView RootSpan from a set of Sim4 alignments
# of sequences against a single subject sequence.
#
sub alignmentSetToAnnotView {
    my($aligns, $subjectLen, $descr, $colorFn, $descrFn) = @_;

    my $seqInfo = &seqAnnotInfo($descr, $AnnotView::black, $AnnotView::ss15b);
    my $mapInfo = &mapSpanInfo(&axisShape(2), &mapSymbols(), &simplePacker(1,0));

    my $result = "RootSpan:[interval=". &staticInterval(1, $subjectLen) . ",\n ";
    $result .= "\tseqWidget=$seqInfo,\n ";
    $result .= "\tmapWidget=$mapInfo,\n ";
    $result .= "\tdescription=\"$descr\",\n";
    $result .= "\tsubpart={\n";
    $result .= join(",\n", map {&alignmentToAnnotView($_, $colorFn, $descrFn)} @$aligns);
    $result .= "}]\n\n";

    return $result;
}

# Create an AnnotView span from a Sim4 alignment.
# The span is in the coordinate system of the subject
# sequence and covers only those parts of the subject
# aligned with the query.
#
sub alignmentToAnnotView {
    my($sim4, $colorFn, $descrFn) = @_;

    my $start = $sim4->getMinSubjectStart();
    my $end = $sim4->getMaxSubjectEnd();
    my $reversed = $sim4->isReversed();
    my $color = &$colorFn($sim4);
    my $fmt = {'span_color' => $color};

    my $spans = $sim4->getSpans();
    my $shortDescr = $sim4->getQueryId();
    my $descr = $descrFn ? &$descrFn($sim4) : $shortDescr;

    my($dotsId,$dotsInt) = ($shortDescr =~ /(DT.(\d+))/);
    my($lbl, $extRefs);

    if (defined($dotsId)) {
	$lbl = &labelSymbolShape($dotsId, 0, 0, $AnnotView::ss10);
	$extRefs = &extRefs(&externalRef($dotsId, "${DOTS_URL}$dotsInt"));
	$shortDescr =~ s/^([^\[]+\[[^\]]+\] )//;
    } else {
	$lbl = &labelSymbolShape($descr, 0, 0, $AnnotView::ss10);
	$extRefs = undef;
    }

    my $sym = &mapSymbol(&compassPoint('NORTH'), $lbl);
    my $symbols = &mapSymbols(($sym));
    my $sshape = &surroundingSpanShape(0, $AnnotView::white, $AnnotView::grey100);

    my $spanStrs = [];
    my $lse = undef;     # last subject end
    my $lqe = undef;     # last query end
    my $lqs = undef;     # last query start

    foreach my $exon (@$spans) {
	
	# Draw a span representing an intron if the boundaries
	# align perfectly on the query sequence.
	#
	if (defined($lqe) && (($lqe + 1) == $exon->{'query_start'}) && !$reversed) {
	    push(@$spanStrs, &makeIntron($lse, $exon->{'subject_start'} - 1, $reversed, $fmt));
	} elsif (defined($lqs) && (($lqs - 1) == $exon->{'query_end'}) && $reversed) {
	    push(@$spanStrs, &makeIntron($lse, $exon->{'subject_start'} - 1, $reversed, $fmt));
	}

	push(@$spanStrs, &spanToAnnotView($exon, $descr, $fmt));

	$lqe = $exon->{'query_end'}; 
	$lqs = $exon->{'query_start'}; 
	$lse = $exon->{'subject_end'};
    }

    return (&spanStart(&simpleSpanLocn($start, $end),
		       &direction(1), # hack - $reversed ? '0' : '1'), 
		       &seqAnnotInfo($descr, $AnnotView::black, $AnnotView::times12),
		       &mapSpanInfo($sshape, $symbols, &oneLineMapPacker(1)), 
		       undef, $extRefs, undef, $descr, undef, $descr) .
	    ",\nsubpart={\n" . join(",\n", @$spanStrs) . "}]\n");
}

sub makeIntron {
    my($start, $end, $reversed, $fmt) = @_;
    my $descr = "inferred intron";

    return &span(&simpleSpanLocn($start, $end),
		 &direction($reversed ? '0' : '1'), 
		 &seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
		 &mapSpanInfo(&simpleSpanShape($fmt->{'span_color'}, 2), &mapSymbols(()), 
			      &simplePacker(1, 0)), 
		 undef, undef, undef, $descr, undef, $descr);
}

# Create an AnnotView span from a Sim4 span.
#
sub spanToAnnotView {
    my($span, $descr, $fmt) = @_;

    my $start = $span->{'subject_start'};
    my $end = $span->{'subject_end'};
    my $reversed = $span->{'is_reversed'};
    my $qs = $span->{'query_start'};
    my $qe = $span->{'query_end'};
    my $pct = $span->{'percent_id'};
    my $descr = "Query $qs-$qe $pct% id";

    return &span(&simpleSpanLocn($start, $end),
		 &direction($reversed ? '0' : '1'), 
		 &seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
		 &mapSpanInfo(&simpleSpanShape($fmt->{'span_color'}, 10), &mapSymbols(()), 
			      &simplePacker(1, 0)), 
		 undef, undef, undef, $descr, undef, $descr);
}

1;

