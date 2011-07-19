#!/usr/bin/perl

# ----------------------------------------------------------
# Genscan.pm
#
# Runs GENSCAN on a sequence.
#
# Created: Thu Apr 13 01:06:53 EDT 2000
#
# Jonathan Crabtree
# ----------------------------------------------------------

use strict;

use BioWidgets::AnnotView;

# ----------------------------------------------------------
# Configuration
# ----------------------------------------------------------

#my $GENSCAN = '/usr/local/bin/genscan';
#my $GS_DIR = '/usr/local/src/bio/GENSCAN';

my $GENSCAN = '/Bioinformatics/usr/local/bin/genscan';
my $GS_DIR = '/Bioinformatics/home/crabtree/genscan';

my $PARAM_FILES = {
    'arabidopsis' => "$GS_DIR/Arabidopsis.smat",
    'maize' => "$GS_DIR/Maize.smat",
    'human' => "$GS_DIR/HumanIso.smat",
    'mouse' => "$GS_DIR/HumanIso.smat"
};

# ----------------------------------------------------------
# runGenscan
#
# $seq   Sequence on which to run GENSCAN
# $org   Organism listed in $PARAM _FILES
# ----------------------------------------------------------

sub runGenscan {
    my ($seq, $seqlen, $org, $spanLabel, $spanOrder) = @_;

    my $paramFile = $PARAM_FILES->{$org};
    die "Unknown organism $org" if (not defined($paramFile));

    # Write sequence to a temporary file
    #
    my $tmpFile = "/tmp/$$.genscan.tmp";
    open(TFILE, ">$tmpFile");
    print TFILE ">seq\n";
    print TFILE $seq, "\n";
    close(TFILE);

    my $gsCmd = "$GENSCAN $paramFile $tmpFile -ps genscan.ps |";
#    print STDERR "Running $gsCmd\n";

    my @fwdSpans;
    my @revSpans;
    
    # Parse GENSCAN output
    #
    open(GSCMD, $gsCmd);

    while (<GSCMD>) { last if /^Predicted genes\/exons:/; }

    my @genes;
    my $exons = [];
    my $exonRegex = ('^\s*(\d+)\.(\d+)\s+(\S+)\s+([-+])\s+(\d+)\s+(\d+)\s+(\d+)\s+');

    while (<GSCMD>) {
	if (/^\s*$/) {
	    if ($#$exons > 0) {
#		print STDERR "pushing ", scalar(@$exons), " exons\n";
		push(@genes, $exons);
		$exons = [];
	    }
	    next;
        }

	last if (/^Predicted peptide sequence/);
        next if (/^\s*Gn\.Ex\s*Type/);
        next if (/^[- ]+$/);

	my ($gNum,$eNum,$type,$strand,$begin,$end,$len) = ($_ =~ /$exonRegex/);
	die "Unable to parse $_" if (not defined($eNum));
        my $span = {
	    'gene' => $gNum,
	    'exon' => $eNum,
	    'type' => $type,
	    'strand' => $strand,
	    'begin' => $begin,
	    'end' => $end,
	    'len' => $len
	    };
#	print STDERR "read span $gNum.$eNum $begin-$end\n";
	push(@$exons, $span);
    }
    close(GSCMD);

    if ($#$exons > 0) {
#	print STDERR "pushing ", scalar(@$exons), " exons\n";
	push(@genes, $exons);
	$exons = [];
    }

    # Remove temporary file
    #
    unlink $tmpFile;

    for(my $g = 0;$g < scalar(@genes);++$g) {
	my ($xMin, $xMax);

	my $gene = $genes[$g];
	my $exonStr;
	my ($lastX1, $lastX2);
	my $lastStrand;

	for (my $e = 0;$e < scalar(@{$gene});++$e) {
	    my $span = $$gene[$e];
	    my $gnum = $span->{'gene'};
	    my $enum = $span->{'exon'};
	    my $type = $span->{'type'};
	    my $strand = $span->{'strand'};
	    my $len = $span->{'len'};

	    my $x1 = ($span->{'begin'} <= $span->{'end'}) ? $span->{'begin'} : $span->{'end'};
	    my $x2 = ($span->{'begin'} <= $span->{'end'}) ? $span->{'end'} : $span->{'begin'};

	    if (not defined($xMin)) { $xMin = $x1; $xMax = $x2; }
	    $xMin = $x1 if ($x1 < $xMin);
	    $xMax = $x2 if ($x2 > $xMax);

	    # Draw intron
	    #
	    if ($e > 0) {
		$exonStr .= ",\n\t" if ($e > 0);
		my ($iX1, $iX2);
		
		if ($x1 > $lastX2) {
		    $iX1 = $lastX2; $iX2 = $x1;
		} else {
		    $iX1 = $x2; $iX2 = $lastX1;
		}

		my $descr = "predicted intron";
		$exonStr .= &AnnotView::span(&AnnotView::simpleSpanLocn($iX1, $iX2),
				  &AnnotView::direction($strand eq '+'), 
				  &AnnotView::seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
				  &AnnotView::mapSpanInfo(&AnnotView::simpleSpanShape($AnnotView::black, 2),
					       &AnnotView::mapSymbols(()), &AnnotView::simplePacker(1)), 
					     undef, undef, undef, $descr, undef, $descr);

		$exonStr .= ",\n\t" if ($e > 0);

	    }

	    $lastX1 = $x1; $lastX2 = $x2;

	    my $descr = "exon ${strand}$enum $type";
	    $exonStr .= &AnnotView::span(&AnnotView::simpleSpanLocn($x1, $x2),
			      &AnnotView::direction($strand eq '+'), 
			      &AnnotView::seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
			      &AnnotView::mapSpanInfo(&AnnotView::simpleSpanShape($AnnotView::black, 10),
					   &AnnotView::mapSymbols(()), &AnnotView::simplePacker(1)), 
					 undef, undef, undef, $descr, undef, $descr);
	    $lastStrand = $strand;
	}

	my $gDescr = "GENSCAN " . $lastStrand . "0" . ($g+1);
	my $lbl = &AnnotView::labelSymbolShape($gDescr, 0, 0, $AnnotView::times12);
	my $sym = &AnnotView::mapSymbol($lastStrand eq '+' ? &AnnotView::compassPoint('NORTH') : &AnnotView::compassPoint('SOUTH'), $lbl);
	my $symbols = &AnnotView::mapSymbols(());

	my $geneModelSpan = &AnnotView::spanStart(&AnnotView::simpleSpanLocn($xMin, $xMax),
				       &AnnotView::direction(1), &AnnotView::seqAnnotInfo('', $AnnotView::black, $AnnotView::times5),
				       &AnnotView::mapSpanInfo(&AnnotView::surroundingSpanShape(1, $AnnotView::white, $AnnotView::blue),
						    $symbols, &AnnotView::oneLineMapPacker(1)), undef, undef,
						  undef, $gDescr, undef, $gDescr);
	$geneModelSpan .= ",\nsubpart={\n" . $exonStr . "}]\n";

	if ($lastStrand eq '+') { push(@fwdSpans, $geneModelSpan); } else { push(@revSpans, $geneModelSpan); }
    }

    return {'forward' => \@fwdSpans, 'reverse' => \@revSpans};
}

return 1;
