package CBIL::Bio::TrivTrans;


# use strict;
sub Trivial {
   my ($seq) = @_;
  my $length_max = 0;

       my $max ='';
	my $revvcomp=0;	
 	my $trans_start = 0;
        for(my $i=0;$i<3;$i++) {
                ($seq[$i],$trans_start[$i],$revcomp[$i]) = &translate($seq,$i+1);
		$trans_start[$i] +=$i;
#                print " Trivial translation unit: length of seq ".length($seq[$i])." start is ".$trans_start[$i]."in frame $i revcomp is ". $revcomp[$i]."\n";
#		print " here is the sequence: \n".SequenceUtils::breakSequence($seq[$i]);
		if(length($seq[$i])>$length_max) {
                        $length_max = length($seq[$i]);
                        $max = $seq[$i];
			$revvcomp = $revcomp[$i];
			$trans_start=$trans_start[$i];
                }
        }
#        print STDERR "length of max ORF is ", $length_max, "\n";
#        open (T, ">./temp/$name.orf");
#        print T ">$name\n";
#        while(length($max)) {
#                print  substr($max,0,80)."\n";
#                substr($max,0,80)="";
#        }
#        close T;
  return $length_max,$max,$trans_start,$revvcomp;
}




sub translate {
        my ($seq,$rFrame) = @_;
        $seq =~s/\s+//g;
        $seq =~tr/atgc/ATGC/ ;
  %codon = ("TTT", F, "TCT", S, "TAT", Y, "TGT", C,
            "TTC", F, "TCC", S, "TAC", Y, "TGC", C,
            "TTA", L, "TCA", S, "TAA", X, "TGA", X,   
            "TTG", L, "TCG", S, "TAG", X, "TGG", W,
            "CTT", L, "CCT", P, "CAT", H, "CGT", R,
            "CTC", L, "CCC", P, "CAC", H, "CGC", R,
            "CTA", L, "CCA", P, "CAA", Q, "CGA", R,
            "CTG", L, "CCG", P, "CAG", Q, "CGG", R, 
            "ATT", I, "ACT", T, "AAT", N, "AGT", S,
            "ATC", I, "ACC", T, "AAC", N, "AGC", S,
            "ATA", I, "ACA", T, "AAA", K, "AGA", R, 
            "ATG", M, "ACG", T, "AAG", K, "AGG", R, 
            "GTT", V, "GCT", A, "GAT", D, "GGT", G,
            "GTC", V, "GCC", A, "GAC", D, "GGC", G, 
            "GTA", V, "GCA", A, "GAA", E, "GGA", G,
            "GTG", V, "GCG", A, "GAG", E, "GGG", G,
            "TCN", S, "CTN", L, "CCN", P, "CGN", R,
            "ACN", T, "GTN", V, "GCN", A, "GGN", G); 
  
  if ($rFrame =~ /[123]/) {
    return &get_prot($seq, $rFrame - 1);
  }else {
    print STDERR "You haven't specified a valid reading frame\n";
  }
}

sub get_prot {
  my($seq, $fram) = @_;
  my $revseq = $seq;
  $revseq =~ tr/GATC/CTAG/;
  $revseq = reverse $revseq;
  $revseq = substr($revseq, $fram, length($revseq));

  $seq = substr($seq,$fram, length($seq));

#  print STDERR "\n";
#  print STDERR "forward: $seq\n";
#  print STDERR "reverse: $revseq\n";
  my $trans = "";
  my $max_trans = "";
  my $revcomp = 0;    #reverse complement
  my $trans_start=0;
  my $curr_start=1;
  my $ct=1;
  while (length($seq)>2) {
    $cod = substr($seq, 0, 3);
    if ( $codon{$cod} ne "") {
      if ( $codon{$cod} eq "X") {
           if (length($max_trans)<length($trans))
                {$max_trans = $trans; $trans_start=$curr_start;} 
	$trans=""; $curr_start = $ct+3;}
           else
{$trans .= $codon{$cod}};
    }else {
      $trans .= "X";
    }
    $ct+=3;
    substr($seq, 0, 3) = "";
  }

if (length($max_trans)<length($trans)) # last segment with no stop codon
  {$max_trans = $trans; $trans_start=$curr_start;};

$curr_start=1;
   $ct = 1;
 $trans ="";
   while (length($revseq)>2) {
    $cod = substr($revseq, 0, 3);
    if ( $codon{$cod} ne "") {
      if ( $codon{$cod} eq "X") {
           if (length($max_trans)<length($trans))
                {$max_trans = $trans; $revcomp=1;$trans_start =$curr_start;
#	print " got new start: $trans_start\n";
		}; $trans=""; $curr_start=$ct+3;
	}
           else
{$trans .= $codon{$cod}};
    }else {
      $trans .= "X";
    }
    $ct+=3;
    substr($revseq, 0, 3) = "";
  }
  if (length($max_trans)<length($trans))  # it happened at the end of the assembly (no stop codon observed)
	{  
#	print "I happened to be in the last cycle lengths are".length($max_trans)."  ".length($trans)."\n";
# print " here is the trans sequence: \n".SequenceUtils::breakSequence($trans);
	$max_trans = $trans; $trans_start= $curr_start;
 		$revcomp=1;}
        {return $max_trans, $trans_start, $revcomp;}
}
1;

