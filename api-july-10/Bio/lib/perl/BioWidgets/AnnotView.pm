#!/usr/bin/perl

# ----------------------------------------------------------
# AnnotView.pm
#
# A set of subroutines that make it easier to generate
# bioWidget annotation files.
#
# Created: Thu Jan 13 13:01:55 EST 2000
#
# Jonathan Crabtree
# ----------------------------------------------------------

use strict vars;
use Exporter;

use vars qw(@ISA @EXPORT);

@ISA = qw(Exporter);
@EXPORT = qw('&direction' '&externalRef' '&extRefs' '&compassPoint' 
	     '&staticInterval' '&spanLocation'
	     '&pointLocation' '&simpleSpanLocn' '&colorSpec' '&fontSpec'
	     '&seqAnnotInfo' '&mapSpanInfo' '&mapLeafSpanInfo' '&axisShape'
 	     '&simpleSpanShape' '&pointySpanShape', '&labelSymbolShape' '&mapSymbols' '&mapSymbol'
             '&orderedPacker' '&orderedPackerParam' '&simplePacker' '&leafSpan' '&span',
	     '&spanStart', '&spanEnd', '&floatingLblSymShape', '&SurroundingSpanShape',
	     '$black', '$blue', '$ss15', '$ss12', '$gray1', '$lblue', '$mblue',
	     '$lpink', '$red', '$lred', '$mred', '$times12', '$vlblue', '$vlgreen', '$dgreen');

# ----------------------------------------------------------
# Useful constants
# ----------------------------------------------------------

# Colors
#
$AnnotView::black = &colorSpec(0,0,0);
$AnnotView::white = &colorSpec(255,255,255);
$AnnotView::grey50 = &colorSpec(50,50,50);
$AnnotView::grey100 = &colorSpec(100,100,100);
$AnnotView::grey150 = &colorSpec(150,150,150);
$AnnotView::grey200 = &colorSpec(200,200,200);

$AnnotView::red = &colorSpec(255,0,0);
$AnnotView::lred = &colorSpec(255,150,150);
$AnnotView::mred = &colorSpec(255,100,100);

$AnnotView::blue = &colorSpec(0,0,255);
$AnnotView::vlblue = &colorSpec(200,200,255);
$AnnotView::lblue = &colorSpec(150,150,255);
$AnnotView::mblue = &colorSpec(100,100,255);

$AnnotView::green = &colorSpec(0,255,0);
$AnnotView::dgreen = &colorSpec(50,155,50);
$AnnotView::vlgreen = &colorSpec(200,255,200);

$AnnotView::dpink = &colorSpec(200,50,50);
$AnnotView::lpink = &colorSpec(255,200,200);
$AnnotView::gray1 = &colorSpec(200,200,200);

# Fonts
#
$AnnotView::ss18b = &fontSpec("SansSerif", "BOLD", 18);
$AnnotView::ss15b = &fontSpec("SansSerif", "BOLD", 15);
$AnnotView::ss15 = &fontSpec("SansSerif", "PLAIN", 15);
$AnnotView::ss15i = &fontSpec("SansSerif", "ITALIC", 15);
$AnnotView::ss12 = &fontSpec("SansSerif", "PLAIN", 12);
$AnnotView::ss12i = &fontSpec("SansSerif", "ITALIC", 12);
$AnnotView::ss12b = &fontSpec("SansSerif", "BOLD", 12);
$AnnotView::ss10b = &fontSpec("SansSerif", "BOLD", 10);
$AnnotView::ss10 = &fontSpec("SansSerif", "PLAIN", 10);
$AnnotView::ss10i = &fontSpec("SansSerif", "ITALIC", 10);
$AnnotView::ss8 = &fontSpec("SansSerif", "PLAIN", 8);
$AnnotView::times15 = &fontSpec("Times", "PLAIN", 15);
$AnnotView::times15b = &fontSpec("Times", "BOLD", 15);
$AnnotView::times12 = &fontSpec("Times", "PLAIN", 12);
$AnnotView::times12b = &fontSpec("Times", "BOLD", 12);
$AnnotView::times10 = &fontSpec("Times", "PLAIN", 10);
$AnnotView::times9 = &fontSpec("Times", "PLAIN", 9);
$AnnotView::times8 = &fontSpec("Times", "PLAIN", 8);
$AnnotView::times7 = &fontSpec("Times", "PLAIN", 7);
$AnnotView::times6 = &fontSpec("Times", "PLAIN", 6);
$AnnotView::times5 = &fontSpec("Times", "PLAIN", 5);

# ----------------------------------------------------------
# Generic subroutines for bioWidget annotation file format. 
# ----------------------------------------------------------

# true = FORWARD, false = REVERSE
#
sub direction {
    my ($isForward) = @_;
    return $isForward ? "DirectionV:FORWARD" : "DirectionV:REVERSE";
}

sub externalRef {
    my($label, $url) = @_;
    return "ExternalRef:[label=\"$label\", URLString=\"$url\"]";
}

sub extRefs {
    my @extRefs = @_;
    return "ExternalRef:{" . join(", ", @extRefs). "}";
}

# dir = NORTH, SOUTH, NORTHWEST, etc.
#
sub compassPoint {
    my ($dir) = @_;
    return "CompassPointV:$dir";
}

sub staticInterval {
    my ($start, $end) = @_;
    return "StaticInterval:[start=$start, end=$end]";
}

sub spanLocation {
    my($start, $end) = @_;
    return "SpanLocation:[startPoint=$start, endPoint=$end]";
}

sub pointLocation {
    my($coord) = @_;
    return "PointLocation:[coord=$coord]";
}

sub simpleSpanLocn {
    my($startPt, $endPt) = @_;
#    if ($startPt > $endPt) {
#	my $tmp = $startPt;
#	$startPt = $endPt;
#	$endPt = $tmp;
#    }
    return &spanLocation(&pointLocation($startPt), &pointLocation($endPt));
}

# A reversed simple span location.  Reverses the location 
# with respect to a containing interval.
#
sub reverseSimpleSpanLocn {
    my($startPt, $endPt, $startInt, $endInt) = @_;
    my $y = $endInt - ($startPt - $startInt);
    my $x = $endInt - ($endPt - $startInt);
    return &spanLocation(&pointLocation($x), &pointLocation($y));
}

sub colorSpec {
    my ($r,$g,$b) = @_;
    return "ColorSpecifier:[r=$r, g=$g, b=$b]";
}

sub fontSpec {
    my ($name, $style, $size) = @_;
    return "FontSpecifier:[name=\"$name\", style=\"$style\", size=$size]";
}

sub seqAnnotInfo {
    my ($label, $color, $font) = @_;
    return "SeqAnnotInfo:[label=\"$label\", color=$color, font=$font]";
}

sub orderedPackerParam {
    my ($num) = @_;
    return "OrderedPackerParam:[number=$num]";
}

sub mapSpanInfo {
    my($shape, $symbols, $packer, $packerParam, $tierIndex) = @_;
    return ("MapSpanInfo:[shape=$shape, symbols=$symbols, packer=$packer" . 
	    (defined($packerParam) ? ", packerParam=$packerParam" : "") .
	    (defined($tierIndex) ? ", tierIndex=$tierIndex" : "") . "]");
}

sub mapLeafSpanInfo {
    my($shape, $symbols, $packerParam, $tierIndex) = @_;
    return ("MapLeafSpanInfo:[shape=$shape, symbols=$symbols" .
	    (defined($packerParam) ? ", packerParam=$packerParam" : "") .
	    (defined($tierIndex) ? ", tierIndex=$tierIndex" : "") . "]");
}

sub axisShape {
    my ($thickness, $tickLength, $font) = @_;
    return ("AxisShape:[" .
	    (defined($thickness) ? "thickness=$thickness" : "") .
	    (defined($tickLength) ? ", tickLength=$tickLength" : "") .
	    (defined($font) ? ", font=$font" : "") .
	     "]");
}

sub noShape {
    return "NoShape:[]";
}

sub simpleSpanShape {
    my($color, $thickness) = @_;
    return "SimpleSpanShape:[color=$color, thickness=$thickness]";
}

sub pointySpanShape {
    my($thickness, $spanColor, $pPixels, $pLeft, $pRight, $textColor, $textFont, $text, $borderColor) = @_;

    return ("PointySpanShape:[spanColor = $spanColor" .
	    (defined($borderColor) ? ", borderColor=$borderColor" : "") .
	    (defined($thickness) ? ", thickness=$thickness" : "") .
	    (defined($pPixels) ? ", pointPixels=$pPixels" : "") .
	    (defined($pLeft) ? ", pointyLeftEnd=$pLeft" : "") .
	    (defined($pRight) ? ", pointyRightEnd=$pRight" : "") .
	    (defined($textColor) ? ", textColor=$textColor" : "") .
	    (defined($textFont) ? ", textFont=$textFont" : "") .
	    (defined($text) ? ", text=\"$text\"" : "") . "]");
}

sub surroundingSpanShape {
    my($margin, $bgcolor, $bordercolor, $surroundKidsOnly, $minThickness) = @_;
    return ("SurroundingSpanShape:[margin=$margin " .
	    (defined($bgcolor) ? ", backgroundColor=$bgcolor" : "") .
	    (defined($bordercolor) ? ", borderColor=$bordercolor" : "") .
	    (defined($surroundKidsOnly) ? ", surroundKidsOnly = $surroundKidsOnly" : "") .
	    (defined($minThickness) ? ", minThickness = $minThickness" : "")
	    . "]");
}

sub transparentSpanShape {
    return "TransparentSpanShape:[]";
}

sub labelSymbolShape {
    my($text, $showLeg, $legLength, $font) = @_;
    my $show = $showLeg ? 'true' : 'false';
    return ("LabelSymbolShape:[labelText=\"$text\", showLeg=$show, legLength=$legLength " . 
	    (defined($font) ? ", font=$font" : "") . "]");
}

sub floatingLblSymShape {
    my($text, $showLeg, $legLength, $font) = @_;
    my $show = $showLeg ? 'true' : 'false';
    return ("FloatingLabelSymbolShape:[labelText=\"$text\", showLeg=$show, " .
	    "legLength=$legLength" .
	    (defined($font) ? ", font=$font" : "") . "]");
}

sub mapSymbols {
    my @symbols = @_;
    return "MapSymbol:{" . join(", ", @symbols). "}";
}

sub mapSymbol {
    my ($location, $shape) = @_;
    return "MapSymbol:[location=$location, shape=$shape]";
}

sub groupDescriptor {
    my($cat, $name) = @_;
    return "GroupDescriptor:[category=\"$cat\", name=\"$name\"]";
}

sub groupColor {
    my($gd, $color) = @_;
    return "GroupColor:[group=$gd, colorSpecifier=$color]";
}

sub groups {
    my @groups = @_;
    return "GroupDescriptor:{" . join(", ", @groups) . "}";
}

sub orderedPacker {
    my ($packInsideParent, $rowGap) = @_;
    return ("OrderedPacker:[packInsideParent=" .
	    ($packInsideParent ? 'true' : 'false') . ", rowGap=$rowGap]");
}

sub oneLineMapPacker {
    return "OneLineMapPacker:[]";
}

sub simplePacker {
    my ($packInsideParent, $rowGap) = @_;
    return ("SimplePacker:[packInsideParent=" . 
	    ($packInsideParent ? 'true' : 'false') . 
	    (defined($rowGap) ? ", rowGap=$rowGap" : "") . "]");
}

sub leafSpan {
    my ($locn, $dirn, $seqW, $mapW, $groups, $extRefs, 
	$type, $source, $accn, $descr, $info) = @_;

    return ("LeafSpan:[spanLocation=$locn, direction=$dirn, " .
	    "mapWidget=$mapW" .
	    (defined($seqW) ? ", seqWidget=$seqW " : "") .
	    (defined($groups) ? ", groups=$groups" : "") .
	    (defined($type) ? ", type=\"$type\"" : "") .
	    (defined($source) ? ", source=\"$source\"" : "") .
	    (defined($accn) ? ", accessionID=\"$accn\"" : "") .
	    (defined($descr) ? ", description=\"$descr\"" : "") .
	    (defined($info) ? ", additionalInfo=\"$info\"" : "") .
	    (defined($extRefs) ? ", externalRefs=$extRefs" : "")
	    . "]");
}

sub span {
    my ($locn, $dirn, $seqW, $mapW, $groups, $extRefs, $type, $source, $accn, $descr, $info) = @_;
    return (&spanStart($locn, $dirn, $seqW, $mapW, $groups, 
		       $extRefs, $type, $source, $accn, $descr, $info) . &spanEnd());
}

sub spanStart {
    my ($locn, $dirn, $seqW, $mapW, $groups, $extRefs, $type, 
	$source, $accn, $descr, $info) = @_;

    return ("Span:[spanLocation=$locn, direction=$dirn, " .
	    "mapWidget=$mapW" .
	    (defined($seqW) ? ", seqWidget=$seqW " : "") .
	    (defined($groups) ? ", groups=$groups" : "") .
	    (defined($type) ? ", type=\"$type\"" : "") .
	    (defined($source) ? ", source=\"$source\"" : "") .
	    (defined($accn) ? ", accessionID=\"$accn\"" : "") .
	    (defined($descr) ? ", description=\"$descr\"" : "") .
	    (defined($info) ? ", additionalInfo=\"$info\"" : "") .
	    (defined($extRefs) ? ", externalRefs=$extRefs" : ""));
}

sub spanEnd {
    return "]";
}

1;

