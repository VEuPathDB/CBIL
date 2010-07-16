#!/usr/bin/perl

package Sim4;

# ----------------------------------------------------------
# Package that parses and manipulates sim4 output.
#
# Created: Mon Jul 17 19:38:09 EDT 2000
#
# $Revision$ $Date$ $Author$
#
# Jonathan Crabtree
# ----------------------------------------------------------

use strict;

use Sim4::AnnotView;

sub new {
    my($class, $debug) =  @_;
    my $self = {debug => $debug};
    bless $self, $class;
    return $self;
}

sub parseSim4Output {
    my($self, @output) = @_;
    my($qSeqLen,$sSeqLen);
    my $complement = 0;

    $self->{'spans'} = [];
    $self->{'num_spans'} = 0;
    my $exonEndPtsFound = 0;

    foreach my $line (@output) {

	if ($line =~ /^\s*$/) {
	    last if ($self->getNumSpans() > 0);
	    next;
	}

	if ($line =~ /^\(complement\)/) { $complement = 1; next; }

	if ($line =~ /^seq1 = \S+( \((.+)\))?, (\d+) bp/) { 
	    $self->{query_id} = $2;
	    $self->{query_length} = $3; 
	    next; 
	}
	if ($line =~ /^seq2 = \S+( \((.+)\))?, (\d+) bp/) { 
	    $self->{subject_id} = $2; 
	    $self->{subject_length} = $3; 
	    next; 
	}

	my($qstart,$qend,$sstart,$send,$pct,$sym) = 
	    ($line =~ /^(\d+)-(\d+)\s+\((\d+)-(\d+)\)\s+(\d+)%\s*(==|->|<-|--|)\s*$/);

	die "Unable to parse '$line'" if (not defined($pct));

	# For complement matches Sim4 reports query coordinates in the 
	# reverse orientation (i.e. from the end of the shorter/query
	# sequence.)
	#
	if ($complement) {
	    my $qend2 = $self->{query_length} - $qend + 1;
	    my $qstart2 = $self->{query_length} - $qstart + 1;
	    $qend = $qstart2;
	    $qstart = $qend2;
	}

	my $qlen = ($qend - $qstart + 1);

	my $span = {'line' => $line,
		    'match_length' => $qlen,
		    'percent_id' => $pct,
		    'is_reversed' => $complement ? '1' : '0',
		    'query_start' => $qstart, 
		    'query_end' => $qend,
		    'subject_start' => $sstart, 
		    'subject_end' => $send, 
		    'symbol' => $sym};

	$self->addSpan($span);
    }
}

sub toString {
    my($self, $format) = @_;
    $format = 'spans' if (not(defined($format)));
    my $result = "";

    if ($format =~ /spans/i) {
	$result .= "query='" . $self->getQueryId() . "' ";
	$result .= "(" . $self->getQueryLength() . " bp) ";
	$result .= "subject='" . $self->getSubjectId() . "' ";
	$result .= "(" . $self->getSubjectLength() . " bp)\n";

	foreach my $span (@{$self->{'spans'}}) {
	    $result .= &spanToString($span, $format);
	    $result .= "\n";
	}
    } elsif ($format =~ /annotview/i) {
	$result .= &AnnotView::alignmentToAnnotView($self);
    }
    else {
	die "Incorrect format '$format'";
    }
    return $result;
}

my $SPAN_REGEX = ('len=(\d+) qs=(\d+) qe=(\d+) ss=(\d+)' .
		  ' se=(\d+) pct=(\d+) sym=' . 
		  "'" . '(.*)'. "'" . ' reversed=(\d+)');

# The inverse of toString.
#
sub fromString {
    my($self, $str, $format) = @_;
    $format = 'spans' if (not(defined($format)));

    $self->{'spans'} = [];
    $self->{'num_spans'} = 0;

    if ($format =~ /spans/i) {
	my @spans = split(/\n/, $str);
	my $defline = shift @spans;

	if ($defline =~ /query='(.*)' \((\d+) bp\) subject='(.*)' \((\d+) bp\)/) {
	    $self->{'query_id'} = $1;
	    $self->{'query_length'} = $2;
	    $self->{'subject_id'} = $3;
	    $self->{'subject_length'} = $4;
	} else {
	    print STDERR "Sim4.pm: Error parsing $defline\n";
	    return undef;
	}
	
	foreach my $spanl (@spans) {
	    if ($spanl =~ /$SPAN_REGEX/) {
		my $span = {'match_length' => $1,
			    'query_start' => $2,
			    'query_end' => $3,
			    'subject_start' => $4,
			    'subject_end' => $5,
			    'percent_id' => $6,
			    'symbol' => $7,
			    'is_reversed' => $8};
		$self->addSpan($span);
	    } else {
		print STDERR "Sim4.pm: Error parsing $spanl\n";
		return undef;
	    }
	}
    } else {
	print STDERR "Sim4.pm: Incorrect format '$format'\n";
	return undef;
    }
    return 1;
}

# Only this method should be used to add spans to the 
# alignment, as it computes summary statistics that are
# then cached in the object.
#
sub addSpan {
    my($self, $span) = @_;

    push(@{$self->{'spans'}}, $span);
    ++$self->{'num_spans'};

    # Update summary info
    #
    if ($self->{'num_spans'} == 1) {
	$self->{'is_reversed'} = $span->{'is_reversed'};
	$self->{'minSpanPctId'} = $span->{'percent_id'};
	$self->{'maxSpanPctId'} = $span->{'percent_id'};
	$self->{'totalIds'} = $span->{'percent_id'} * $span->{'match_length'};
	$self->{'totalQueryAlignedBases'} = $span->{'query_end'} - $span->{'query_start'} + 1;
	$self->{'totalSubjectAlignedBases'} = $span->{'subject_end'} - $span->{'subject_start'} + 1;
    } else {
	$self->{minSpanPctId} = $span->{percent_id} if ($span->{percent_id} < $self->{minSpanPctId});
	$self->{maxSpanPctId} = $span->{percent_id} if ($span->{percent_id} > $self->{minSpanPctId});
	$self->{'totalIds'} += $span->{'percent_id'} * $span->{'match_length'};
	$self->{'totalQueryAlignedBases'} += $span->{'query_end'} - $span->{'query_start'} + 1;
	$self->{'totalSubjectAlignedBases'} += $span->{'subject_end'} - $span->{'subject_start'} + 1;
	die "Span in opposite orientation" if ($span->{'is_reversed'} != $self->{'is_reversed'});
    }

    print STDERR &spanToString($span), "\n" if ($self->{'debug'});
}

# ----------------------------------------------------------
# Accessor methods
# ----------------------------------------------------------

sub getNumSpans { return shift->{'num_spans'}; }
sub getSpans { return shift->{'spans'}; }
sub isReversed { return shift->{'is_reversed'}; }
sub getMinSpanPctId { return shift->{'minSpanPctId'}; }
sub getMaxSpanPctId { return shift->{'maxSpanPctId'}; }

sub getAvgPctId { 
    my $self = shift;
    return $self->{'totalIds'} / $self->getTotalAlignLength();
}

sub getMinSpanAttr {
    my($self, $attr) = @_;
    my @attrs = sort {$a <=> $b} map { $_->{$attr} } @{$self->{'spans'}};
    return $attrs[0];
}

sub getMaxSpanAttr {
    my($self, $attr) = @_;
    my @attrs = sort {$b <=> $a} map { $_->{$attr} } @{$self->{'spans'}};
    return $attrs[0];
}

sub getMinQueryStart { return shift->getMinSpanAttr('query_start'); }
sub getMaxQueryEnd { return shift->getMaxSpanAttr('query_end'); }
sub getMinSubjectStart { return shift->getMinSpanAttr('subject_start'); }
sub getMinSubjectEnd { return shift->getMinSpanAttr('subject_end'); }
sub getMaxSubjectEnd { return shift->getMaxSpanAttr('subject_end'); }
sub getMaxSubjectStart { return shift->getMinSpanAttr('subject_start'); }

sub getTotalAlignLength {
    my($self) = @_;
    my @lengths = map { $_->{'match_length'} } @{$self->{'spans'}};
    my $result = 0;
    foreach my $l (@lengths) { $result += $l; }
    return $result;
}

sub getTotalQueryAlignedBases { return shift->{totalQueryAlignedBases}; }
sub getTotalSubjectAlignedBases { return shift->{totalSubjectAlignedBases}; }
sub getQueryLength { return shift->{query_length}; }
sub getSubjectLength { return shift->{subject_length}; }
sub getQueryId { return shift->{query_id}; }
sub getSubjectId { return shift->{subject_id}; }

sub setQueryId {
    my($self, $id) = @_;
    $self->{'query_id'} = $id;
}

sub setSubjectId {
    my($self, $id) = @_;
    $self->{'subject_id'} = $id;
}

# Returns the maximum difference between the start of
# one span and the end of the previous one.
#
sub getMaxQueryGap {
    my($self) = @_;
    my $maxGap = 0;
    my $isFirst = 1;

    if ($self->isReversed()) {
	my $lastQueryStart = 1;

	foreach my $span (@{$self->getSpans()}) {
	    if ($isFirst) {
		$isFirst = 0;
	    } else {
		my $gap = $lastQueryStart - $span->{'query_end'} - 1;
		print " gap = $gap\n";
		$maxGap = $gap if ($gap > $maxGap);
	    }
	    $lastQueryStart = $span->{'query_start'};
	}
    } else {
	my $lastQueryEnd = 1;

	foreach my $span (@{$self->getSpans()}) {
	    if ($isFirst) {
		$isFirst = 0;
	    } else {
		my $gap = $span->{'query_start'} - $lastQueryEnd - 1;
		print " gap = $gap\n";
		$maxGap = $gap if ($gap > $maxGap);
	    }
	    $lastQueryEnd = $span->{'query_end'};
	}
    }
    return $maxGap;
}

# ----------------------------------------------------------
# Static methods
# ----------------------------------------------------------

sub spanToString {
    my($span, $format) = @_;
    $format = 'spans' if (not(defined($format)));
    my $result = "";

    if ($format =~ /spans/i) {
	$result .= " len=" . $span->{match_length};
	$result .= " qs=" . $span->{query_start};
	$result .= " qe=" . $span->{query_end};
	$result .= " ss=" . $span->{subject_start};
	$result .= " se=" . $span->{subject_end};
	$result .= " pct=" . $span->{percent_id};
	$result .= " sym='" . $span->{symbol} ."'";
	$result .= " reversed=" . $span->{is_reversed};
    } 
    elsif ($format =~ /annotview/i) {
	$result .= &AnnotView::spanToAnnotView($span);
    } 
    else {
	die "Incorrect format '$format'";
    }

    return $result;
}

1;
	
#	if (++$numSpans > 1) {
#	    my $span = $spans[$numSpans - 1];
#	    my $lastSpan = $spans[$numSpans - 2];
#	    $gap = abs($lastSpan->{'query_end'} - $span->{'query_start'});
#	    $self->{'queryInternalGapChars'} += $gap;
#	    $self->{'maxQueryInternalGap'} = $gap if ($gap > $maxQueryInternalGap);
#	    ++$numQueryInternalGaps if ($gap > 10);
#	}


