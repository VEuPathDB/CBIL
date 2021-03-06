#!@perl@

# ----------------------------------------------------------
# runBlastSim4.pl
#
# Run sim4 on every pair of sequences determined to 
# have similarity by a prior BLAST run.  The prior BLAST
# run must have been generated by generateBlastSimilarity
# and written to a file with output format 'both' (i.e.,
# displaying both subject summaries and also individual
# spans for each subject.)
#
# TO DO:
#  -reduce sim4 compute time by taking substring of contig
#   -requires that we know maximum likely intron size
#   -or we trust BLAST to find small exons
#  -and/or write all subject (contig) files to disk up front
#
# $Revision$ $Date$ $Author$
#
# Jonathan Crabtree
# ----------------------------------------------------------

use strict;
use Getopt::Long;

use CBIL::Bio::FastaIndex;
use Sim4::Sim4;

# ----------------------------------------------------------
# Configuration
# ----------------------------------------------------------

my $DEBUG = 0;
my $Q_SUFFIX = "sim4_s1.fsa";
my $S_SUFFIX = "sim4_s2.fsa";
my $SIM4 = 'sim4';

# Echo full sim4 alignments to output in debug mode
#
my $SIM4_OPTS = $DEBUG ? 'A=3' : '';

# ----------------------------------------------------------
# User input
# ----------------------------------------------------------

my($queryFile,
   $subjectFile,
   $queryRegex,
   $subjectRegex,
   $blastFile,
   $minHspPctId,
   $minHspLength);

&GetOptions
    ("queryFile=s" => \$queryFile,
     "subjectFile=s" => \$subjectFile,
     "queryRegex=s" => \$queryRegex,
     "subjectRegex=s" => \$subjectRegex,
     "blastFile=s" => \$blastFile,
     "minHspPctId=f" => \$minHspPctId,
     "minHspLength=i" => \$minHspLength
     );

if (!$queryFile || !$subjectFile || !$blastFile || !$queryRegex || !$subjectRegex) {
    print ("Usage: runBlastSim4.pl \n",
	   "        --blastFile=Summaries and spans output by generateBlastSimilarity.pl \n",
	   "        --queryFile=FastaIndex'ed file of BLAST query sequences \n",
	   "        --subjectFile=FastaIndex'ed file of BLAST subject sequences \n",
	   "        --queryRegex=Regular expression to parse a query ID out of blastFile \n",
	   "        --subjectRegex=Regular expression to parse a subject ID out of blastFile \n",
	   "        --minHspPctId=BLAST HSP must have this percent ID and the specfied length \n",
	   "        --minHspLength=BLAST HSP must have this length the specfied percent ID \n",
	   "        (only those BLAST subjects with a qualifying HSP will be passed to sim4)\n\n"
	   );
    die;
}

die "$blastFile unreadable" if (! -r $blastFile);

my $qIndex = new FastaIndex(new CBIL::Util::A +{seq_file => $queryFile, open => 1});
die "Unable to read from $queryFile" if (!$qIndex->open());

my $sIndex = new FastaIndex(new CBIL::Util::A +{seq_file => $subjectFile, open => 1});
die "Unable to read from $subjectFile" if (!$sIndex->open());

print "runBlastSim4.pl:\n";
print "  blastFile=$blastFile\n";
print "  queryFile=$queryFile\n";
print "  subjectFile=$subjectFile\n";
print "  queryRegex=$queryRegex\n";
print "  subjectRegex=$subjectRegex\n";
print "  minHspLength=$minHspLength\n";
print "  minHspPctId=$minHspPctId\n\n";

# ----------------------------------------------------------
# Main program
# ----------------------------------------------------------

$| = 1;

open(BFILE, $blastFile);
my $line = <BFILE>;

my $subject = undef;          # hashref w/ keys 'summary' and 'spans'
my $query = undef;            # hashref w/ keys 'id' and 'file'

while (defined($line)) {
    if ($line =~ /^>/) {      # new query sequence

	my($queryId) = ($line =~ /$queryRegex/);
	die "Unable to parse query ID from $line" if (not(defined($queryId)));

	# Remove old query file if one exists
	#
	&removeTempFile($Q_SUFFIX) if (defined($query->{'file'}));
	chomp($line);
	$query = {'id' => $queryId, 'file' => undef, 'defline' => $line};

	print "blast query = $queryId\n" if ($DEBUG);

	# Loop over subject sequences hit by the query.
	# Expects both "summary" and "span" lines in the BLAST file.
	#
	$line = <BFILE>;

	while (defined($line)) {
	    last if ($line =~ /^>/);         # next query

	    if ($line =~ /\s*Sum:/) {        # new subject sequence
		my $hspNum = 1;
		$subject = {'summary' => &parseSummary($line), 'spans' => []};

		$line = <BFILE>;
		while (defined($line)) {
		    last if ($line =~ /\s*Sum:|^>/);      # new subject or query

		    if ($line =~ /\s*HSP(\d+):/) {
			die "HSP count mismatch in $line" if ($1 != $hspNum++);
			push (@{$subject->{'spans'}}, &parseSpan($line));
		    } else {
			die "Expecting span, read line $line";
		    }
		    $line = <BFILE>;
		}
		&processSubject($subject, $query) if (defined($subject));
		$subject = undef;
	    } else {
		$line = <BFILE>;
	    }
	}
    } else {
	$line = <BFILE>;
    }
}
close(BFILE);

&removeTempFile($Q_SUFFIX) if (defined($query->{'file'}));
&processSubject($subject, $query) if (defined($subject));

# ----------------------------------------------------------
# Subroutines
# ----------------------------------------------------------

# Determine whether a subject sequence has any spans/HSPs
# that meet the search criteria.  If it does, align the
# subject with the current query.
#
# $subject    hashref with keys 'summary' and 'spans'
#
sub processSubject {
    my($subject, $query) = @_;

    # Loop over spans to see if this subject qualifies for sim4
    #
    my $spans = $subject->{'spans'};
    my $doAlignment = 0;
    
    foreach my $span (@$spans) {
	my $pctId = int(($span->{'ids'} / $span->{'length'}) * 100 + 0.5);

	if (($pctId >= $minHspPctId) && ($span->{'length'} >= $minHspLength)) {
	    $doAlignment = 1;
	    last;
	}
    }

    if ($doAlignment) {
	my $sId = $subject->{'summary'}->{'id'};
	my ($subjectId) = ($sId =~ /$subjectRegex/);
	die "Unable to parse subject ID from '$sId'" if (not(defined($subjectId)));

	# Write query sequence if it hasn't already been done
	#
	if (not(defined($query->{'file'}))) {
	    $query->{'seq'} = $qIndex->getSequence(new CBIL::Util::A +{accno => $query->{'id'}});
	    die "Query sequence $query->{'id'} not found" if (not(defined($query->{'seq'}->{'seq'})));
	    $query->{'file'} = &writeTempFile($Q_SUFFIX, $query->{'seq'});
	    $query->{'seq_length'} = &seqLength($query->{'seq'}->{'seq'});
	}

	# Write subject sequence
	#
	my $subjectSeq = $sIndex->getSequence(new CBIL::Util::A +{accno => $subjectId});
	die "Subject sequence $subjectId not found" if (not(defined($subjectSeq->{'seq'})));
	my $sFile = &writeTempFile($S_SUFFIX, $subjectSeq);
	my $slen = &seqLength($subjectSeq->{'seq'});

	print "blast query=$query->{'id'} ($query->{'seq_length'} bp) ";
	print "blast subject=$subjectId ($slen bp)\n";

	# Run alignment
	#
	&runSim4Job($query, $sFile, $slen, $subjectSeq);

	# Remove subject file
	#
	&removeTempFile($S_SUFFIX);
    }
}

sub seqLength {
    my($seq) = @_;
    my $rseq = $seq;
    $rseq =~ s/\s+//g;
    return length($rseq);
}

# Parse a BLAST summary line into a hashref
#
sub parseSummary {
    my($line) = @_;
    my @fields = split(':', $line);

    return {
	'line' => $line,
	'id' => $fields[1],
	'best_score' => $fields[2],
	'best_pval' => $fields[3],
	'min_s_start' => $fields[4],
	'max_s_end' => $fields[5],
	'min_q_start' => $fields[6],
	'max_q_end' => $fields[7],
	'num_spans' => $fields[8],
	'total_length' => $fields[9],
	'total_ids' => $fields[10],
	'total_pos' => $fields[11],
	'direction' => $fields[12],
	'frame' => $fields[13],
    };
}

sub parseSpan {
    my($line) = @_;
    my @fields = split(':', $line);

    return {
	'line' => $line,
	'id' => $fields[1],
	'ids' => $fields[2],
	'pos' => $fields[3],
	'length' => $fields[4],
	'score' => $fields[5],
	'pval' => $fields[6],
	's_start' => $fields[7],
	's_end' => $fields[8],
	'q_start' => $fields[9],
	'q_end' => $fields[10],
	'direction' => $fields[11],
	'frame' => $fields[12],
    };
}

# Perform a single sim4 run.  Runs sim4 with the shorter 
# sequence as the first argument, as the program prefers.
#
sub runSim4Job {
    my($query, $sFile, $sLen, $sSeq) = @_;

    my $qFile = $query->{'file'};
    my $qLen = $query->{'seq_length'};

    my $swapFiles = ($sLen < $qLen);
    my $sim4Cmd = $swapFiles ? "$SIM4 $sFile $qFile " : "$SIM4 $qFile $sFile ";
    $sim4Cmd .= $SIM4_OPTS;

    print "command='$sim4Cmd'", ($swapFiles ? " [query and subject switched]": ""), "\n";
    my @sim4Output = `$sim4Cmd`;

    print join('>>', @sim4Output) if ($DEBUG);

    my $sim4 = Sim4->new(0);
    $sim4->parseSim4Output(@sim4Output);

    if ($swapFiles) {
	$sim4->setQueryId($sSeq->{'hdr'});
	$sim4->setSubjectId($query->{'seq'}->{'hdr'});
    } else {
	$sim4->setQueryId($query->{'seq'}->{'hdr'});
	$sim4->setSubjectId($sSeq->{'hdr'});
    }

    print $sim4->toString();
}

# Write a sequence to a temporary FASTA file
#
sub writeTempFile {
    my($suffix, $seq) = @_;
    my $fname = "/tmp/$$.$suffix";
    open(TMPFILE, ">$fname");
    print TMPFILE $seq->{'hdr'}, "\n";
    print TMPFILE $seq->{'seq'};
    close(TMPFILE);
    return $fname;
}

# Remove a file previously written with writeTempFile
#
sub removeTempFile {
    my($suffix) = @_;
    my $fname = "/tmp/$$.$suffix";
    unlink $fname;
}
