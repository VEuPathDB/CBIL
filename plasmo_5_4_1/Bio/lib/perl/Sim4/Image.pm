#!/usr/bin/perl

# ---------------------------------------------------------------------
# Image.pm
#
# Generate gif/png output using the GDUtil packages.
#
# $Revision$ $Date$ $Author$
#
# Jonathan Crabtree
# ---------------------------------------------------------------------

use strict;

package Image;

use Sim4::Sim4;

# Graphics libraries
#
use GDUtil::GDCanvas;
use GDUtil::Span;
use GDUtil::StripeSpan;
use GDUtil::AxisSpan;
use GDUtil::Packer;

my $MARGIN = 100;

# Generate a GDUtil::GDCanvas from a sim4 alignment.
#
sub alignmentToGDCanvas {
    my($sim4, $width, $height, $start, $end) = @_;

    my $canvas = 
      GDUtil::GDCanvas->new($width, $height,
			    {x1 => $MARGIN, x2 => $width - $MARGIN},
			    {x1 => $start, x2 => $end});

    $canvas->allocateWebSafePalette();
    my $image = $canvas->getImage();
    my $fgColor = $image->colorClosest(0,0,255);

    my $autoheight = 1 if (not defined($height));
    $height = 100 if ($autoheight);
    
    $start = 1 if (!defined($start));
    $end = $sim4->getSubjectLength() if (!defined($end));
    my $subjId = $sim4->getSubjectId();

    my $stripeSpan = &alignmentToGDSpan($sim4, $start, $end, $fgColor);
    
    my $rootSpan = 
      GDUtil::AxisSpan->new({
	  x1 => $start,
	  x2 => $end,
	  y1 => $height - 5, 
	  height => 2, tickHeight => 2, tickWidth => 1,
	  kids => [ $stripeSpan ],
	  packer => GDUtil::Packer::constantPacker(0),
	  tickInterval => 'ends',
	  tickLabel => 'bp',
	  label => $subjId,
	  labelVAlign => 'center'
	  });
    
    $rootSpan->pack();

    if ($autoheight) {
	$height = $rootSpan->getHeight() + 5;

	$canvas = 
	  GDUtil::GDCanvas->new($width, $height,
				{x1 => $MARGIN, x2 => $width - $MARGIN},
				{x1 => $start, x2 => $end});

	$canvas->allocateWebSafePalette();
	$rootSpan->{y1} = $height - 5 ;
	$rootSpan->pack();
    }

    $rootSpan->draw($canvas);
    return $canvas;
}

sub alignmentToGDSpan {
    my($sim4, $start, $end, $fgColor) = @_;
    my $reversed = $sim4->isReversed();
    
    my $sim4Exons = $sim4->getSpans();
    my $queryId = $sim4->getQueryId();
    my $subjId = $sim4->getSubjectId();

    print STDERR "query id = $queryId subject id = $subjId\n";

    my $spans = [];
    my $lse = undef;     # last subject end
    my $lqe = undef;     # last query end
    my $lqs = undef;     # last query start
    
    foreach my $exon (@$sim4Exons) {
	
	# Draw a span representing an intron if the boundaries
	# align perfectly on the query sequence.
	#
	if (defined($lqe) && (($lqe + 1) == $exon->{'query_start'}) && !$reversed) {
	    push(@$spans, &makeIntron($lse, $exon->{'subject_start'} - 1, $reversed, $fgColor));
	} elsif (defined($lqs) && (($lqs - 1) == $exon->{'query_end'}) && $reversed) {
	    push(@$spans, &makeIntron($lse, $exon->{'subject_start'} - 1, $reversed, $fgColor));
	}

	my $subjStart = $exon->{'subject_start'};
	my $subjEnd = $exon->{'subject_end'};
	
	push(@$spans, &makeExon($subjStart, $subjEnd, $fgColor, 0));
	     
	$lqe = $exon->{'query_end'}; 
	$lqs = $exon->{'query_start'}; 
	$lse = $exon->{'subject_end'};
    }

    my $stripeSpan = GDUtil::StripeSpan->new({
	x1 => $start,
	x2 => $end,
	kids => $spans,
	packer => GDUtil::Packer::constantPacker(0),
	label => $queryId,
	labelVAlign => 'bottom',
	labelHAlign => 'left',
	drawBar => 1,
    });

    return $stripeSpan;
}

sub makeIntron {
    my($start, $end, $reversed, $color) = @_;
    
    my $args = {
	x1 => $start,
	x2 => $end,
	height => 1,
	vertOffset => -4,
	color => $color,
	filled => 1,
	};
    
    return GDUtil::Span->new($args);
}

sub makeExon {
    my($start, $end, $color, $border) = @_;
    
    my $args = {
	x1 => $start,
	x2 => $end,
	height => 12,
	color => $color,
	filled => 1,
	};

    $args->{border} = 1 if ($border);
    return GDUtil::Span->new($args);
}

1;

