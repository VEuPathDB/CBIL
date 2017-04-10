#!/usr/bin/perl

# ------------------------------------------------------------------------
# Alignment.pm
#
# An alignment in a PSL file.  For (space) efficiency the alignment is 
# stored as a string and the various fields are parsed out only as needed.
#
# Created: Thu Apr 25 10:21:23 EDT 2002
# 
# Jonathan Crabtree
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

use strict;

package CBIL::Bio::BLAT::Alignment;

# ------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------

my $DEBUG = 0;

# Minimum amount of a sequence that must be 'A's for it to be considered a polyA tail.
#
my $POLYA_FRAC = 0.95;

# Currently only supports psLayout version 3
#
my $PSL_PARSER = {

    psl_version => '3',

    # Tab-delimited columns of the psLayout output, tagged with order of appearance ('ind')
    #
    columns => [{ var => 'matches', descr => '', ind => 0},
		{ var => 'mismatches', descr => '', ind => 1},
		{ var => 'rep_matches', descr => '', ind => 2},
		{ var => 'num_ns', descr => '', ind => 3},
		{ var => 'q_gap_count', descr => '', ind => 4},
		{ var => 'q_gap_bases', descr => '', ind => 5},
		{ var => 't_gap_count', descr => '', ind => 6},
		{ var => 't_gap_bases', descr => '', ind => 7},
		{ var => 'strand', descr => '', ind => 8},
		{ var => 'q_name', descr => '', ind => 9},
		{ var => 'q_size', descr => '', ind => 10},
		{ var => 'q_start', descr => '', ind => 11},
		{ var => 'q_end', descr => '', ind => 12},
		{ var => 't_name', descr => '', ind => 13},
		{ var => 't_size', descr => '', ind => 14},
		{ var => 't_start', descr => '', ind => 15},
		{ var => 't_end', descr => '', ind => 16},
		{ var => 'num_blocks', descr => '', ind => 17},
		{ var => 'block_sizes', descr => '', list => 1, ind => 18},
		{ var => 'q_starts', descr => '', list => 1, ind => 19},
		{ var => 't_starts', descr => '', list => 1, ind => 20},
		],

    # Subroutine that builds span objects from the column data (see above)
    #
    getSpans => sub {
	my $self = shift;
	my $spans = [];
	my $nBlocks = $self->get('num_blocks');
	my $blockSizes = $self->get('block_sizes');
	my $qStarts = $self->get('q_starts');
	my $tStarts = $self->get('t_starts');

	for (my $i = 0; $i < $nBlocks; ++$i) {
	    my $blockSize = $blockSizes->[$i];

	    # NOTE: when strand is "-" then all query coordinates are with
	    # respect to the other end of the sequence.

            # BLAT use coordinates (], shifted one here to make it [)
	    push(@$spans, 
		 { length => $blockSize,
		   qs => $qStarts->[$i] + 1,
		   qe => $qStarts->[$i] + $blockSize + 1,
		   ts => $tStarts->[$i] + 1,
		   te => $tStarts->[$i] + $blockSize + 1,
	       }
		 );
	}
	return $spans;
    }
};

sub getValues { $_[0]->{_values} }


# ------------------------------------------------------------------------
# Module 
# ------------------------------------------------------------------------

# Intialize a PSL parser by building some additional data structures
#
sub initParser {
    my($parser) = @_;

    # Build mapping from column name to column index
    #
    my $columns = $parser->{columns};
    my $columnsByName = {};
    my $ncols = 0;

    foreach my $col (@$columns) {
	$columnsByName->{$col->{var}} = $col;
	++$ncols;
    }

    $parser->{'columnsByName'} = $columnsByName;
    $parser->{'numColumns'} = $ncols;
}

&initParser($PSL_PARSER);

# ------------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------------

sub new {
    my($class, $str) = @_;
    chomp($str);
    my @vals = split("\t", $str);

    my $self = bless { _values => \@vals }, $class;
    return $self;
}

# ------------------------------------------------------------------------
# Accessor methods
# ------------------------------------------------------------------------

# Get raw column value by index
#
sub _getByInd {
    my($self, $ind) = @_;

    my $values = $self->getValues();

    return $values->[$ind];
}

# Get a raw column value by name
#
sub getRaw {
    my($self, $colName) = @_;
    my $col = $PSL_PARSER->{'columnsByName'}->{$colName};
    my $ind = $col->{'ind'};
    return $self->_getByInd($ind);
}

# Get a column value by name.  Scalars are returned as-is, 
# list values are returned as listrefs.
#
sub get {
    my($self, $colName) = @_;
    my $col = $PSL_PARSER->{'columnsByName'}->{$colName};
    my $ind = $col->{'ind'};

    if ($col->{'list'}) {
	my @listvals = split(/,\s*/, $self->_getByInd($ind));
	return \@listvals;
    } else {
	return $self->_getByInd($ind);
    }
}

# Return the blocks/spans of the alignment as a listref of objects
# with keys: length,qs,qe,ts,te.
#
sub getSpans {
    my($self) = @_;
    my $gsFn = $PSL_PARSER->{'getSpans'};
    return &$gsFn($self);
}

# ------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------

sub toString {
    my $self = shift;

    my $values = $self->getValues();
    return join("\t", @$values);
}

# Debug version of toString; exercises the get method
# 
sub toStringDebug {
    my($self, $showColName) = @_;
    my $colStrs = [];

    for (my $i = 0;$i < $PSL_PARSER->{'numColumns'};++$i) {
	my $col = $PSL_PARSER->{'columns'}->[$i];
        my $colNam = $col->{'var'};

	my $colval = $self->get($colNam);

	if ($col->{'list'}) {
	    push(@$colStrs, ($showColName ? "$colNam=" : "") . join(",", @$colval) . ",");
	} else {
	    push(@$colStrs, ($showColName ? "$colNam=" : "") . $colval);
	}
    }
    return join("\t", @$colStrs);
}

# ------------------------------------------------------------------------
# Analysis
# ------------------------------------------------------------------------

# Check the quality (as categorized in BlatAlignmentQuality table in GUS) of this alignment
#
sub checkQuality {
    my ($self, $querySeq, $params, $gapTable, $dbh) = @_;

    print "DEBUG: check quality for blat alignment:\n", $self->toStringDebug(1), "\n" if $DEBUG;

    # default quality id to 4, 'everything else'
    #
    my $qualityId = 4;

    # first check the alignment for consistency, which is the same as 'very good' quality category (id = 1)
    #
    my @res = $self->checkConsistency($querySeq, $params);
    print "DEBUG: results from checkConsistency: ", join(', ', @res), "\n" if $DEBUG;

    return unless scalar(@res) > 0;
    my $is_consistent = $res[0];
    my $hasP3polyA = $res[1];
    my $hasP5polyA = $res[3];
    my $pctId = $res[7];
    my $p3mis = $res[17];
    my $p5mis = $res[18];
    $qualityId = 1 if $is_consistent;
    print "DEBUG: is_consistent=$is_consistent, hasP3polyA=$hasP3polyA, hasP5polyA=$hasP5polyA, pctId=$pctId, ",
          "p3mis=$p3mis, p5mis=$p5mis\n" if $DEBUG;

    # next forgive query gaps that might be explained away by existence of plausible genomic sequence gaps
    #
    my $maxQueryGap = $params->{maxQueryGap};
    my $maxEndMismatch = $params->{maxEndMismatch};
    my $minPctId = $params->{minPctId};
    my $minGapPct = $params->{minGapPct};
    my $endGapFactor = $params->{endGapFactor};
    if (!$is_consistent && $pctId >= $minPctId && !($hasP3polyA && $hasP5polyA)) {
      my @qGapSizes = $self->getUnexplainedLargeInternalGapSizes($dbh, $gapTable, $maxQueryGap, $minGapPct);
      print "DEBUG: unexplained large query gap sizes are: ", join(', ', @qGapSizes), "\n" if $DEBUG;
      my ($hasP3GenomicGap, $hasP5GenomicGap);
      $hasP3GenomicGap = $self->hasEndGenomicGap($dbh, $gapTable, $endGapFactor, $minGapPct, $p3mis, 0)
	  if $p3mis > $maxEndMismatch;
      $hasP5GenomicGap = $self->hasEndGenomicGap($dbh, $gapTable, $endGapFactor, $minGapPct, $p5mis, 1)
	  if $p5mis > $maxEndMismatch;

      if (($p3mis <= $maxEndMismatch || $hasP3GenomicGap) && scalar(@qGapSizes) == 0 &&
          ($p5mis <= $maxEndMismatch || $hasP5GenomicGap)) {
        print "DEBUG: setting qualityId to 2\n" if $DEBUG;
        $qualityId = 2;
      } else {
        # next relax restriction on the size of internal query gaps without plausible genomic sequence gap explanations
        # and relax restriction on the size of end mismatch bases
        #
        my $okEndGap = $params->{okEndGap};
        my $okInternalGap = $params->{okInternalGap};
        my $mgs = 0;
        foreach (@qGapSizes) { $mgs = $_ if $_ > $mgs; }
        if ($p3mis <= $okEndGap && $mgs <= $okInternalGap && $p5mis <= $okEndGap) { 
          print "DEBUG: setting qualityId to 3\n" if $DEBUG;
          $qualityId = 3;
        } else { print "DEBUG: leaving qualityId at 4\n" if $DEBUG; }
      }
    } else {
      print "DEBUG: leaving qualityId at ", ($is_consistent ? 1 : 4), "\n" if $DEBUG;
    }

    $res[0] = $qualityId;
    return @res;
}

sub checkConsistency {
    my($self, $querySeq, $params) = @_;
    # ------------------------------
    # Debug
    # ------------------------------
    my $debug = 0;

    # ------------------------------
    # Parameters
    # ------------------------------

    my $maxEndMismatch = $params->{'maxEndMismatch'}; 
    my $minPctId = $params->{'minPctId'};
    my $maxQueryGap = $params->{'maxQueryGap'};
    my $okInternalGap => $params->{'okInternalGap'};
    my $okEndGap => $params->{'okEndGap'};
    my $endGapFactor => $params->{'endGapFactor'};
    my $minGapPct => $params->{'minGapPct'};

    # $POLYA_FRAC (file-scoped)

    # Defaults
    #
    $maxEndMismatch = 0 if (!defined($maxEndMismatch));
    $minPctId = 100 if (!defined($minPctId));
    $maxQueryGap = 0 if (!defined($maxQueryGap));

    my $is_3p_complete = 0;
    my $is_5p_complete = 0;
    my $has_3p_polyA = 0;
    my $has_5p_polyA = 0;
    my $is_consistent = 0;
    my $is_genomic_contaminant = 0;

    # Sanity check on length of query sequence
    #
    if (length($querySeq) != ($self->get('q_size'))) {
	my $qName = $self->get('q_name');
    	print STDERR "Alignment.checkConsistency(): ERROR - length mismatch for query sequence '$qName'\n";
	print STDERR "actual length = ", length($querySeq), " advertised = ", $self->get('q_size'), "\n";
	return;
    }

    # --------------------------------------------------------------------------------------
    # STEP 1: Determine completeness of 3' and 5' ends of alignment wrt the query sequence
    #
    # An alignment is considered 3'(5') complete if either
    #  1. It has <= $maxEndMismatch of the query sequence unaligned at the 3'(5') end
    #  2. It has > $maxEndMismatch for the query sequence unaligned at the 3'(5') end,
    #     but the unaligned query sequence appears to be a polyA tail.
    #
    # NOTE: We flag any alignments for which 2. applies at both the 3' and the 5' end.
    # --------------------------------------------------------------------------------------

    # Determine where areas of mismatch are at either end
    #
#    my $firstSpan = $spans->[0];
#    my $lastSpan = $spans->[$numSpans - 1];

    # Use q_start, q_end from the BLAT output, because these are independent of strand
    #
    my $minQS = $self->get('q_start');
    my $maxQE = $self->get('q_end');
    my $end1 = $minQS;                               # 5' end
    my $end2 = $self->get('q_size') - $maxQE;        # 3' end

    # Sanity check
    die "ERROR - end1 < 0" if ($end1 < 0);
    die "ERROR - end2 < 0" if ($end2 < 0);

    print $self->toString(), "\n" if ($debug);
    
    # If the length of either end sequence is over $maxEndMismatch,
    # check whether the extra sequence (i.e. that beyond the
    # first $maxEndMismatch) can be classified as polyA.

    # 5' end
    if ($end1 > $maxEndMismatch) {
	my $endSeq1 = substr($querySeq, 0, $end1 - $maxEndMismatch);
#	print "running poly-A check on endSeq1='$endSeq1'\n" if ($DEBUG);
	if (&isPolyA($endSeq1)) {
	    $has_5p_polyA = 1;
	    $is_5p_complete = 1;
	}
    } else {
	$is_5p_complete = 1;
    }

    # 3' end
    if ($end2 > $maxEndMismatch) {
	my $endSeq2 = substr($querySeq, $maxQE + $maxEndMismatch, $end2 - $maxEndMismatch);
#	print "running poly-A check on endSeq2='$endSeq2'\n" if ($DEBUG);
	if (&isPolyA($endSeq2)) {
	    $has_3p_polyA = 1;
	    $is_3p_complete = 1;
	}
    } else {
	$is_3p_complete = 1;
    }

    if ($debug) {
	print "5' mismatch=$end1 polyA=$has_5p_polyA complete=$is_5p_complete\n";    
	print "3' mismatch=$end2 polyA=$has_3p_polyA complete=$is_3p_complete\n";
    }

    # --------------------------------------------------------------------------------------
    # STEP 2: Check whether average percent identity >= $minPctId
    # --------------------------------------------------------------------------------------

    my $matches = $self->get('matches');
    my $mismatches = $self->get('mismatches');
    my $repmatches = $self->get('rep_matches');
    my $ns = $self->get('num_ns');

    # NOTE - should Ns be included in these counts?

    my $alignedBases = ($matches + $mismatches + $repmatches + $ns);
    my $alignedQueryBases = ($matches + $repmatches + $ns);
    my $pctId = ($alignedQueryBases / $alignedBases) * 100.0;
    my $pctRep = ($repmatches / ($matches + $repmatches + $ns)) * 100.0;

    if ($debug) {
	print "avg. pctId = $pctId ";
	print "repeat percent = $pctRep\n";
    }

    # ----------------------------------------------------------------------------------------------
    # STEP 3: Check that there are no unaligned query segments > $maxQueryGap, also get $maxTGap
    # ----------------------------------------------------------------------------------------------

    my $spans = $self->getSpans();
    my $numSpans = scalar(@$spans);

    my ($maxQGap, $maxTGap) = (0, 0);
    my $first = 1;
    my ($lastQCoord, $lastTCoord)  = (undef, undef);

    # Don't include end mismatches in this statistic 
    #
    foreach my $span (@$spans) {
	if ($first) {
	    $first = 0;
	} else {
	    my $qGap = $span->{qs} - $lastQCoord;
	    my $tGap = $span->{ts} - $lastTCoord;
	    $maxQGap = $qGap if ($qGap > $maxQGap);
	    $maxTGap = $tGap if ($tGap > $maxTGap);
	}
	$lastQCoord = $span->{qe};
	$lastTCoord = $span->{te};
    }

    print "maxQGap = $maxQGap, maxTGap = $maxTGap\n" if ($debug);
    die "ERROR - end1 < 0" if ($maxQGap < 0 || $maxTGap < 0);

    # --------------------------------------------------------------------------------------
    # Compute consistency 
    # --------------------------------------------------------------------------------------

    my $pctIdMet = ($pctId >= $minPctId) ? 1 : 0;
    my $gapMet = ($maxQGap <= $maxQueryGap) ? 1 : 0;
    my $bothEndsComplete = ($is_5p_complete && $is_3p_complete) ? 1 : 0;
    my $bothEndsPolyA = ($has_5p_polyA && $has_3p_polyA) ? 1 : 0;

    print "pctIdMet=$pctIdMet gapMet=$gapMet bothEnds=$bothEndsComplete bothPoly=$bothEndsPolyA\n" if ($debug);

    if ($pctIdMet && $gapMet && $bothEndsComplete && !$bothEndsPolyA) {
	$is_consistent = 1;
    }

    # NOTE: Presumed genomic contaminants (which are not considered 
    # consistent alignments) are identified in a postprocessing step
    # by querying the database.  Any DoTS assembly that has only one EST
    # and shows no evidence of being spliced is considered a genomic
    # contaminant.
    #
    # TO DO
    #  - take repeat content into account
    #  - examine number of consistent alignments an assembly has

    return ($is_consistent,
	    $has_3p_polyA,
	    $is_3p_complete,
	    $has_5p_polyA,
	    $is_5p_complete,
	    $self->get('q_name'),
	    $self->get('t_name'),
	    $pctId,
	    $alignedQueryBases,
	    $maxQGap,
	    $maxTGap,
	    $numSpans,
	    $minQS,
	    $maxQE,
	    $self->get('t_start'),
	    $self->get('t_end'),
	    $self->get('strand'),
	    $end2,  # 3' mismatch
	    $end1   # 5' mismatch
	    );
}

# try to explain internal query gap in the alignment
# by looking at appropriate genomic regions for genomic gaps
# return an array of the sizes of unexplained gaps above the threshold of $maxQueryGap
#
sub getUnexplainedLargeInternalGapSizes {
  my ($self, $dbh, $gapTable, $maxQueryGap, $minGapPct) = @_;

  my @qGapSizes;
  return () unless $gapTable;

  my $spans = $self->getSpans();
  my $numSpans = scalar(@$spans);

  for (my $i=0; $i<$numSpans-1; $i++) {
    my $qGap = $spans->[$i+1]->{qs} - $spans->[$i]->{qe};
    if ($qGap > $maxQueryGap) {
      my $gs = $spans->[$i]->{te};
      my $ge = $spans->[$i+1]->{ts};
      push @qGapSizes, $qGap unless &hasGenomicGap($dbh, $gapTable, $qGap, $minGapPct, $gs, $ge);
    }
  }

  return @qGapSizes;
}

# try to explain query end mismatches in the alignment
# by looking at appropriate genomic regions for genomic gaps
# return an array of the sizes of unexplained gaps above the threshold of $maxQueryGap
#
sub hasEndGenomicGap {
  my ($self, $dbh, $gapTable, $endGapFactor, $minGapPct, $qGapSize, $is5p) = @_;

  return undef unless $gapTable;

  my $is_reversed = ($self->get('strand') eq '-') ? 1 : 0;
  my $target_end = $self->get('t_end');
  my $target_start = $self->get('t_start');
  my ($gs, $ge);
  if ($is5p) {
    $gs = $is_reversed ? $target_end : $target_start-$endGapFactor*$qGapSize;
    $ge = $is_reversed ? $target_end + $endGapFactor*$qGapSize : $target_start;
  } else {
    $gs = $is_reversed ?  $target_start-$endGapFactor*$qGapSize : $target_end;
    $ge = $is_reversed ?  $target_start : $target_end + $endGapFactor*$qGapSize;
  }

  return &hasGenomicGap($dbh, $gapTable, $qGapSize, $minGapPct, $gs, $ge);
}

# ------------------------------------------------------------------------
# File-scoped methods
# ------------------------------------------------------------------------

# determine whether there is a large enough genomic gap
#
sub hasGenomicGap {
    my($dbh, $gapTable, $queryGapSize, $minGapPct, $start, $end) = @_;

    # For finished sequence
    #
    return 0 if (!defined($gapTable));

    print "DEBUG: checking for genomic gap overlaps $start to $end in $gapTable ",
          "that is at least $minGapPct \% of query gap of $queryGapSize\n" if $DEBUG;

    my $sql = "select chromstart, chromend from $gapTable where chromstart <= $end and chromend >= $start";
    my $sth = $dbh->prepare($sql);
    print "DEBUG: running:\n$sql\n" if $DEBUG;
    $sth->execute();
    my ($gapSize, $gapStart, $gapEnd) = (0, 0, 0);
    while (my $h = $sth->fetchrow_hashref('NAME_lc')) {
        $gapStart = $h->{'chromstart'} if $gapStart == 0 || $gapStart > $h->{'chromstart'};
        $gapEnd = $h->{'chromend'} if $gapEnd == 0 || $gapEnd < $h->{'chromend'};
        $gapSize += ($h->{'chromend'} - $h->{'chromstart'});
    }

    my $hasSufficientGap = 0;
    if ($gapSize * 100.0 / $queryGapSize >= $minGapPct) {
      $hasSufficientGap = 1;
      print "DEBUG: found LARGE enough gaps of $gapSize bp between $gapStart an $gapEnd\n" if $DEBUG;
    } elsif ($gapSize) {
      print "DEBUG: found gap(s) too SMALL, only $gapSize bp between $gapStart and $gapEnd\n" if $DEBUG; 
    } else {
      print "DEBUG: not genomic gap found!\n" if $DEBUG;
    }
    $sth->finish();

    return $hasSufficientGap;
}


# Count the number of A's in the sequence and decide 
# whether it is a potential poly-A sequence.  Returns
# true if (numAs / (length - numNs)) >= $POLYA_FRAC
#
sub isPolyA {
    my($seq) = @_;
    my $sl = length($seq); 

    my $numAs = 0;
    my $numNs = 0;

    for (my $i = 0;$i < $sl;++$i) {
	my $char = substr($seq, $i, 1);

	if (($char eq 'A') || ($char eq 'a')) {
	    ++$numAs;
	} elsif (($char eq 'N') || ($char eq 'n')) {
	    ++$numNs;
	}
    }

    # Adjust effective length by the number of 'N's
    #
    my $adjLen = $sl - $numNs;
    return 1 if ($adjLen == 0);
    my $fracA = ($numAs/$adjLen);
    return ($fracA >= $POLYA_FRAC) ? '1' : '0';
}

sub getScore {
  my $self = shift;
  my $alignedBases = $self->get('matches') + $self->get('mismatches') + $self->get('num_ns');
  my $alignedQueryBases =  $self->get('matches') + $self->get('rep_matches') + $self->get('num_ns');
  my $alignPct = ($alignedBases / $self->get('q_size')) * 100.0;
  my $pctId = ($alignedQueryBases / $alignedBases) * 100.0;
  return  sprintf("%3.3f", sqrt($pctId * $alignPct));
}

1;






