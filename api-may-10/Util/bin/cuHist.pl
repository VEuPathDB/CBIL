#! @perl@

=pod

=head1 Synopsis

  cuHist.pl [OPTIONS] <DELIMITED DATA>

=head1 Purpose

C<cuHist.pl> takes a list of numeric or string values and computes the
empirical distribution of the observed values.  Numeric values can be
placed in bins to compute a probability density function.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict "vars";

use CBIL::Util::EasyCsp;

# ========================================================================
# --------------------------------- Code ---------------------------------
# ========================================================================

$| = 1;

run(cla());

# --------------------------------- cla ----------------------------------

sub cla {
  my $Rv = CBIL::Util::EasyCsp::DoItAll
    ( [
       { h  => 'sorting method',
	 t  => CBIL::Util::EasyCsp::StringType,
	 e  => [qw( n qi z t s a u r ilc )],
	 o  => 'sort',
	 d  => 'n',
       },

       { h  => 'put data in this many bins',
	 t  => CBIL::Util::EasyCsp::IntType,
	 o  => 'binN',
	 so => 'b',
       },

       { H => 'put data in log-based bins',
	 t => CBIL::Util::EasyCsp::IntType,
	 o => 'logBinN',
       },

       { h => 'bin width',
	 t => CBIL::Util::EasyCsp::FloatType,
	 o => 'binWidth',
       },

       { h => 'bin base, i.e., first bin',
	 t => CBIL::Util::EasyCsp::FloatType,
	 o => 'binBase',
       },

       { h => 'take log of data; this is the base',
	 t => CBIL::Util::EasyCsp::FloatType,
	 o => 'log',
       },

       { h => 'report distribution in probability, [0,1], rather than counts',
	 t => CBIL::Util::EasyCsp::BooleanType,
	 o => 'probability',
	 so => 'p',
       },

       { h => 'use second column as weight',
	 t => CBIL::Util::EasyCsp::BooleanType,
	 o => 'weighted',
       },

       { h => 'use all words on line, not just first',
	 t => CBIL::Util::EasyCsp::BooleanType,
	 o => 'allWords',
       },

       { h => 'use this RX to split lines',
	 t => CBIL::Util::EasyCsp::StringType,
	 o => 'inDelimRx',
	 d => "\t",
       },

       { h => 'use this string to delimit output values',
	 t => CBIL::Util::EasyCsp::StringType,
	 o => 'outDelim',
	 d => "\t",
       },
      ],
      'make histogram of data'
    ) || exit 0;

  return $Rv;
}

# --------------------------------- run ----------------------------------

=cut

=head1 Details

=cut

sub run {
  my $Cla = shift;

  my %_Counter;
  my %_Binned;

=pod

=head1 Reading Data

Data is read from <>, i.e., all files listed on the command line or
from stdin.

=cut

  # ........................................
  # read data

  my $pts_n         = 0;
  my $totalWeight_r = 0;
  my $min_r         = 1e38;
  my $max_r         = -1e38;
  my $del_r;

  while (<>) {
    chomp;
    my @words = split( /$Cla->{inDelimRx}/, $_ );
    my $word;
    my $d_vote;

    # determine the words we'll cout and the weight for each
    if ( $Cla->{allWords} ) {
      $d_vote = 1.0;
    }

    else {
      if ($Cla->{weighted}) {
	$d_vote = $words[1];
      }
      else {
	$d_vote = 1.0;
      }
      @words = ( $words[0] );
    }

    # accumulate weighted words
    foreach $word ( @words ) {

      $totalWeight_r += $d_vote;

      if ($Cla->{sort} eq 'i' or $Cla->{sort} eq 'z') {
	$word = int($word);
      }

      if (my $base = $Cla->{'log'}) {
	if ($word > 0) {
	  $word = log($word)/log($base);
	} else {
	  next;
	}
      }
      $_Counter{$word} += $d_vote;

      $pts_n++;

      $min_r = $word if $min_r > $word;
      $max_r = $word if $max_r < $word;
    }
  }

  # ........................................
  # bin if requested

  # proper binning
  if ( defined $Cla->{binWidth} ) {

    my @d_binnedData;

    # get a nice minimum.
    my $d_bMin = defined $Cla->{binBase}
      ? $Cla->{binBase} - $Cla->{binWidth} / 2.0 
	: $min_r - $Cla->{binWidth} / 2.0; 
    #( int( $min_r / $Cla->{binWidth} ) - 1 ) * $Cla->{binWidth};

    # bin data
    foreach ( keys %_Counter ) {
      my $i_bin = int( ($_ - $d_bMin ) / $Cla->{binWidth} );
      $d_binnedData[ $i_bin ] += $_Counter{ $_ };
    }

    my $i;
    for ( $i = 0; $i < scalar( @d_binnedData ); $i++ ) {
      my $d_score = $d_bMin + ( $i + 0.5 ) * $Cla->{binWidth};

      if ( defined $d_binnedData[ $i ] ) {
	$_Binned{ $d_score } = $d_binnedData[ $i ];
      }
      else {
	$_Binned{ $d_score } = 0;
      }
    }
  }

  # improper binning
  elsif ( defined $Cla->{binN} ) {

    print STDERR "Computing number of bins $Cla->{bins}\n";
    $Cla->{bins} = log($pts_n)  / log(2);

    if ( $Cla->{bins} > 0 ) {
      $del_r = ($max_r - $min_r) / $Cla->{bins};
      foreach (keys %_Counter) {
	my $d_bin = int(($_ - $min_r) / $del_r) * $del_r + $min_r;
	$_Binned{$d_bin} += $_Counter{$_};
      }
    }
  }

  # no binning, transfer data
  else {
    foreach (keys %_Counter) {
      $_Binned{$_} = $_Counter{$_};
    }
  }

  # percentage requested
  if ( $Cla->{probability} ) {
    print STDERR "Total Weight = $totalWeight_r\n" if $Cla->{verbose};

    foreach ( keys %_Binned) {
      $_Binned{ $_ } = $_Binned{ $_ } / $totalWeight_r;
    }
  }

  # ........................................
  # output

  my $delim = $Cla->{outDelim};

  if ($Cla->{sort} eq 'n') {
    foreach (sort {$a <=> $b} keys %_Binned) {
      print "$_${delim}$_Binned{$_}\n";
    }
  }

  elsif ($Cla->{sort} eq 'i' or $Cla->{sort} eq 'z') {
    my $i_lo = 1e38;
    my $i_hi = -1e38;

    foreach (keys %_Binned) {
      $i_lo = $_ if $i_lo > $_;
      $i_hi = $_ if $i_hi < $_;
    }

    $i_lo = 0 if $Cla->{sort} eq 'z' and $i_lo > 0;

    my $i;
    for ($i = $i_lo; $i <= $i_hi; $i++) {
      if ($_Binned{$i}) {
	print "$i${delim}$_Binned{$i}\n";
      }
      else {
	print "$i${delim}0\n";
      }
    }
  }

  elsif ($Cla->{sort} eq 't') {
    my $i_total = 0;
    foreach (sort {$a <=> $b} keys %_Binned) {
      $i_total += $_Binned{$_};
      print "$_${delim}$i_total\n";
    }
  }

  elsif( $Cla->{sort} eq 's' ) {
    my $i_total = 0;
    foreach (sort {$b <=> $a} keys %_Binned) {
      $i_total += $_Binned{$_};
      print "$_${delim}$i_total\n";
    }
  }

  elsif ($Cla->{sort} eq 'ilc') {
    my $i_total = 0;
    foreach (sort {$b <=> $a} keys %_Binned) {
      $i_total += $_Binned{$_};
      print join("${delim}", $_, log($i_total) / 2.30259 ), "\n";
    }

    #  my $i_total = 0;
    #  foreach (keys %_Binned) {
    #    $i_total += $_Binned{$_};
    #  }
    #
    #  my $d_runTot = $i_total;
    #  foreach (sort {$a <=> $b} keys %_Binned) {
    #    print join("${delim}", $_, $d_runTot), "\n";
    #    $d_runTot -= $_Binned{$_};
    #  }
  }

  elsif ($Cla->{sort} eq 'a') {
    foreach (sort {$a cmp $b} keys %_Binned) {
      print "$_${delim}$_Binned{$_}\n";
    }
  }

  elsif ($Cla->{sort} eq 'u') {
    foreach (sort {uc($a) cmp uc($b)} keys %_Binned) {
      print "$_${delim}$_Binned{$_}\n";
    }
  }

  elsif ($Cla->{sort} eq 'r') {
    foreach (sort 
	     {$_Binned{$a} == $_Binned{$b} 
		? uc($a) cmp uc($b) 
		  : $_Binned{$a} <=> $_Binned{$b}}
	     keys %_Binned) {
      print "$_${delim}$_Binned{$_}\n";
    }
  }
}



