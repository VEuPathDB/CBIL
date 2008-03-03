package CBIL::Bio::Blast::HSP;

# Perl module to represent a BLAST HSP or GSP.  
# Called HSP.pm because I'm old-fashioned.
#
# Jonathan Crabtree 9/20/1998
#

# Create a new HSP object
#
sub new {
  bless(my $self = {});
  my($score,			# BLAST raw score
     $bits,			# raw score in bits of info.
     $expect,			# e-value
     $pval,			# p-value
     $sumpn,			# number of HSPs used to compute $pval
     $identities,		# count of the number of identical residues
     $positives,		# ditto for positives (aa)
     $strand,			# strand/reading frame of the alignment
     $length,			# length of the alignment
     $q_start,			# query start index
     $q_end,			# query end index
     $s_start,			# subject start index
     $s_end,			# subject end index
     $query,			# string containing query sequence
     $match,			# ditto for the match line(s)
     $sbjct,			# ditto for the subject sequence
     $seq_indent		# needed to format output correctly
     ) = @_;

  $$self{'score'} = $score;  $$self{'bits'} = $bits; 
  $$self{'expect'} = $expect;
  $$self{'pval'} = $pval;  $$self{'sumpn'} = $sumpn;
  $$self{'identities'} = $identities;  $$self{'positives'} = $positives;
  $$self{'strand'} = $strand; $$self{'length'} = $length;
  $$self{'query'} = $query; $$self{'seq_indent'} = $seq_indent;
  $$self{'match'} = $match; $$self{'subject'} = $sbjct;

  if ($q_start < $q_end) {
      $$self{'q_start'} = $q_start; 
      $$self{'q_end'} = $q_end;
      $$self{'q_rev'} = 0;
  } else {
      $$self{'q_start'} = $q_end; 
      $$self{'q_end'} = $q_start;
      $$self{'q_rev'} = 1;
  }

  if ($s_start < $s_end) {
      $$self{'s_start'} = $s_start; 
      $$self{'s_end'} = $s_end;
      $$self{'s_rev'} = 0;
  } else {
      $$self{'s_start'} = $s_end; 
      $$self{'s_end'} = $s_start;
      $$self{'s_rev'} = 1;
  }

  return $self;
}

# Helper method for toString: generates a BLAST2-lookalike
# string from a fraction of identities/positive matches.
#
sub matchesToString {
    my($matches,		# number of identical/positive residues
       $total			# total number of residues
     ) = @_;
  my $result = "";
  my $pct = int(($matches/$total) * 100);
  $result .= "${matches}/${total} (${pct}%)";
  return $result;
}

# Implementation of toString 'blast2' format
#
sub toStringBlast {
  my ($self) = shift;

  my $result = "";		# Store the result string in here

  $result .= " Score = " . $$self{'score'} . " (" . $$self{'bits'} . " bits)";
  $result .= ", Expect = " . $$self{'expect'};
  if ($$self{'sumpn'} == 1) {
      $result .= ", P = " . $$self{'pval'};
  } else {
      $result .= ", Sum P(" . $$self{'sumpn'} . ") = " . $$self{'pval'};
  }
  $result .= "\n Identities = ";
  $result .= &matchesToString($$self{'identities'}, $$self{'length'});
  $result .= ", Positives = ";
  $result .= &matchesToString($$self{'positives'}, $$self{'length'});
  
  if (defined($$self{'strand'})) {
      $result .= ", Strand = " . $$self{'strand'};
  }
  
  $result .= "\n\n";

  if ($$self{q_rev}) {
      my $qs = $$self{'q_end'};  my $qe = $$self{'q_start'};
  } else {
      my $qs = $$self{'q_start'};  my $qe = $$self{'q_end'};
  }

  if ($$self{s_rev}) {
      my $ss = $$self{'s_end'};  my $se = $$self{'s_start'};
  } else {
      my $ss = $$self{'s_start'};  my $se = $$self{'s_end'};
  }
  
  # Break the query, match, and subject sequences into chunks
  # of length 60, along with the appropriate numbering and
  # formatting.
  #
  my $l = length($$self{'query'});
  
  # Chunk size.  Shouldn't be hardcoded.
  #
  my $incr = 60;
  
  my $match_indent_str = "";
  for ($i = 0;$i < $$self{'seq_indent'};$i++) { $match_indent_str .= ' '; }
  my $index_chars = $$self{'seq_indent'} - 8;
  my ($tqs, $tqe, $tss, $tse);
  $tqs = $qs; $tss = $ss;
  
  for ($c = 0; $c < $l; $c += $incr) {
      my $sl = ($c + $incr > $l) ? $l - $c : $incr;
      my $pos = 0;
      
      my $query_str = substr($$self{'query'}, $c, $sl);
      my $sbjct_str = substr($$self{'subject'}, $c, $sl);
      
      # Adjust sequence index displayed by the number of gap
      # characters ('-') in the string.
      #
      my $n_qchars = $sl;
      while (($pos = (index($query_str, "-", $pos))) > -1) { 
	  $n_qchars--; 
	  $pos++;
      }
	  
      # Compute the coordinates used to label the sequence line;
      # need to subtract if the alignment is against the reverse
      # strand.
      #
      if ($qs < $qe) {
	  $tqe = $tqs + $n_qchars - 1;
      } else {
	  $tqe = $tqs - $n_qchars + 1;
      }
      
      # Same adjustment as above, only for the subject sequence
      # instead of the query.
      #
      my $n_schars = $sl; $pos = 0;
      while (($pos = (index($sbjct_str, '-', $pos))) > -1) { 
	  $n_schars--; $pos++;
      }
      
      if ($ss < $se) {
	  $tse = $tss + $n_schars - 1;
      } else {
	  $tse = $tss - $n_schars - 1;
      }
      
      $result .= "Query: " . sprintf("%${index_chars}d", $tqs) . " " .
	  $query_str . " ${tqe}\n";;
      $result .= $match_indent_str . substr($$self{'match'}, $c, $sl) . "\n";
      $result .= "Sbjct: " . sprintf("%${index_chars}d", $tss) . " " .
	  $sbjct_str . " ${tse}\n\n";
      
      $tqs = ($qs < $qe) ? $tqe + 1: $tqe - 1;
      $tss = ($ss < $se) ? $tse + 1: $tse - 1;
  }
  return $result;
}

# Implementation of toString 'spans' format.  Mirrors output
# format of generateBlastSimilarity.perl
#
# $d  field delimiter
#
sub toStringSpans {
  my($self, $d) = @_;

  my @fields = qw{identities positives length score pval};
  my $result = join($d, map {$self->{$_}} @fields);

  my $ss = $self->{'s_start'}; my $se = $self->{'s_end'};
  my $qs = $self->{'q_start'}; my $qe = $self->{'q_end'};

  $result .= $d;
  $result .= "${ss}${d}${se}${d}";
  $result .= "${qs}${d}${qe}${d}";

  my $frame = ($strand =~ /([\+\-]\d+)/) || '';

  $result .= ($self->isReversed() ? '1' : '0') . $d;
  $result .= $frame;

  return $result;
}

sub isReversed {
    my($self) = @_;
    return ($self->{'strand'} =~ /Minus \/ Plus|\-\d/)
}

# Produce a human-readable representation of the HSP.
# By default it produces BLAST2-compatible output
# (more or less).
#
# $format     'blast2', 'spans'  (default = 'blast2')
# $spanDelim  delimiter to use in 'spans' mode
#
sub toString {
  my ($self, $format, $spanDelim) = @_;
  $format = 'blast2' if (not(defined($format)));

  if ($format =~ /^blast2$/i) {
      return $self->toStringBlast();
  } elsif ($format =~ /^spans$/) {
      return $self->toStringSpans($spanDelim);
  }
  return undef;
}

1;
