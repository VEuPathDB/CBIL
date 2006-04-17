package CBIL::Bio::BLAST2::SBJCT;

# Perl module to represent a BLAST2 subject (i.e. a subject 
# sequence and an ordered list of HSPs or GSPs against that
# subject sequence.)
#
# Jonathan Crabtree 9/20/1998
#

use CBIL::Bio::BLAST2::HSP;

# Create a new SBJCT object.
#
sub new {
    bless (my $self = {});
    my($description,		# Subject's definition line from the BLAST DB
       $length,			# Length (reported from the DB) of the subject
       $n_hsps,			# Number of HSPs in @$$hsps
       $hsps			# Reference to an array of HSP objects
       ) = @_;
    $$self{'description'} = $description;
    $$self{'length'} = $length;
    $$self{'n_hsps'} = $n_hsps;
    $$self{'hsps'} = $hsps;
    return $self;
}

# Return the number of HSPs (actually GSPs in BLAST2)
# for a subject.
#
sub getNumHSPs {
    my $self = shift;
    return $$self{'n_hsps'};
}

# Return one of the subject's HSPs.
#
sub getHSP {
    my $self = shift;
    my ($hspnum) = @_;		# 0-based index < &getNumHSPs()
    return ${$$self{'hsps'}}[$hspnum];
}

# Convert the subject to a string, using (almost) the same 
# output format as WU-BLAST2.
#
# $format     'blast2', 'spans'  (default = 'blast2')
# $spans      'summary', 'spans', 'both'  (default = 'both')
# $spanDelim  delimiter to use in 'spans' mode
#
sub toString {
    my ($self, $format, $spans, $spanDelim) = @_;
    $format = 'blast2' if (not(defined($format)));
    my $result = "";

    if ($format =~ /^blast2$/i) {
	$result .= ">" . $$self{'description'};
	$result .= "\n            Length = " . $$self{'length'}. "\n";

	foreach $hsp (@{$$self{'hsps'}}) {
	    $result .= "\n" . $hsp->toString();
	}			
	return $result;
    } elsif ($format =~ /^spans$/i) {
	my $d = $spanDelim;
	$spans = 'both' if (not(defined($spans)));
	my $subjectId = $self->{'description'};

	# Summary for the entire subject
	#
	if ($spans =~ /^summary|both$/i) {
	    # best score, best pval, min_s_start, max_s_end, min_q_start, max_q_end,
	    # num hsps, total len, total ids, total positives, best direction, best frame
	    
	    $result .= "  Sum$d " . $subjectId . $d;
	}

	# Individual span for each HSP
	#
	if ($spans =~ /^spans|both$/) {
	    my $hnum = 1;

	    foreach $hsp (@{$$self{'hsps'}}) {
		$result .= "\n   HSP${hnum}$d " . $subjectId . $d;
		$result .= $hsp->toString('spans', $spanDelim);
		++$hnum;
	    }			
	}

	return $result;
    } else {
	return undef;
    }
}

1;
