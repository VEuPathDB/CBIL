#! /usr/bin/perl

=pod

=head1 Description

Compute various statistics of a dataset.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict "vars";

use CBIL::Util::EasyCsp;
use CBIL::Util::V;

# ========================================================================
# --------------------------- Ready, Set, Go! ----------------------------
# ========================================================================

$| = 1;

run(cla());

# --------------------------------- run ----------------------------------

sub run {
   my $Cla = shift;

   my %pts_n  = (); # tag -> int ; number of points (rows) for each tag
   my %data_r = (); # tag -> [ real ] ; list of values seen for each tag

   my $totalPts_n = loadData($Cla, \%data_r, \%pts_n);
   sortData($Cla, \%data_r, \%pts_n);
   trimData($Cla, \%data_r, \%pts_n);

   $Cla->{debug} && printData($Cla, \%data_r, \%pts_n);

   my @sortedKeys = sortKeys($Cla, \%data_r, \%pts_n);

   if ($Cla->{header} && $Cla->{statistics}) {
      print join("\t",
                 qw( label n_pts f_pts median mean std var min max span total )
                ), "\n";
   }

   foreach my $tag (@sortedKeys) {
      processTag($Cla, \%data_r, \%pts_n, $totalPts_n, $tag);
   }
}

# --------------------------------- cla ----------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   ( [ { h => 'trim this many points from top and bottom',
         t => CBIL::Util::EasyCsp::IntType(),
         o => 'trimN',
         's' => 'tn',
       },

       { h => 'trim this percent of points from top and bottom',
         t => CBIL::Util::EasyCsp::FloatType(),
         o => 'trimP',
         's' => 'tp',
       },

       { h => 'trim these values',
         t => CBIL::Util::EasyCsp::FloatType(),
         l => 1,
         o => 'trimV',
         's' => 'tv',
       },

       { h => 'numerically sort line tags when reporting statistics',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'numericTagSort',
         's' => 'ns',
       },

       { h => 'print tabulated statistics of values',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'statistics',
         's' => 'stats',
         d => 1,
       },

       { h => 'plot values',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'plot',
       },

       { h => '?',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'fraction',
       },

       { h => 'include column headers in output',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'header',
       },

       { h => 'format statistics with this C-style format spec',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'format',
         d => '%0.3f',
       },

       { h => 'put label in the last column',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'LabelLast',
       },
     ],
     'compute statistics of (tagged) numeric values'
   ) || exit 0;
}

# ========================================================================
# --------------------------- Support Methods ----------------------------
# ========================================================================

# ------------------------------- loadData -------------------------------

=pod

=head2 Reading Data

Data is taken from the first one or two tab-delimited columns in the
input stream.  The first column is used as a tag that identifies the
category of the data which is in the second column.  If there is just
one column, then the tag is set to '_'.

=cut

sub loadData {
   my $Cla  = shift;
   my $Data = shift;
   my $Pts  = shift;

   my $Rv = 0;

   # load the data
   while ( <> ) {
      chomp;
      my @cols = split( /\s+/, $_, 2 );
      if ( scalar @cols == 1 ) {
         unshift( @cols, '_' );
      }
      push( @{$Data->{$cols[0]}}, $cols[1] );
      $Pts->{$cols[0]}++;
      $Rv++;
   }

   return $Rv;
}

# ------------------------------- sortData -------------------------------

sub sortData {
   my $Cla  = shift;
   my $Data = shift;
   my $Pts  = shift;

   my $Rv = 0;

   foreach ( keys %$Data ) {
      my @d = sort { $a <=> $b } @{ $Data->{$_} };
      $Data->{$_} = \@d;
      $Rv += $Pts->{$_};
   }

   return $Rv;
}

# ------------------------------- trimData -------------------------------

=pod

=head2 Data Trimming

=cut

sub trimData {
   my $Cla  = shift;
   my $Data = shift;
   my $Pts  = shift;

   # trim n data points from the extremes
   if ( defined $Cla->{trimN} && $Cla->{trimN} > 0 ) {
      foreach my $tag ( keys %$Data ) {
         my @d = @{ $Data->{$tag} };
         $Data->{$tag} = [ @d[ $Cla->{trimN} .. $Pts->{$tag} - $Cla->{trimN} ] ];
         $Pts->{$tag} = scalar @{ $Data->{$tag} };
      }
   }

   # trim p percentage from both ends
   elsif ( defined $Cla->{trimP} and $Cla->{trimP} > 0 ) {
      foreach my $tag ( keys %$Data ) {
         my $np = int( $Cla->{trimP} * $Pts->{$tag} + 0.5 );
         my @d = @{ $Data->{$tag} };
         $Data->{$tag} = [ @d[ $np .. $Pts->{$tag} - $np ] ];
         $Pts->{$tag} = scalar @{ $Data->{$tag} };
      }
   }

   # trim values which are outside of a range
   elsif ( scalar @{$Cla->{trimV}} > 0 ) {
      foreach my $tag ( keys %$Data ) {
         my @d = grep {
            $_ >= $Cla->{trimV}->[ 0 ] && $_ <= $Cla->{trimV}->[ 1 ] 
         } @{ $Data->{$tag} };
         $Data->{$tag} = \@d;
         $Pts->{$tag} = scalar @d;
      }
   }
}

# ------------------------------ printData -------------------------------

sub printData {
   my $Cla  = shift;
   my $Data = shift;
   my $Pts  = shift;

   foreach my $tag ( keys %$Data ) {
      print join("\t",
                 $tag,
                 $Pts->{$tag},
                 join( ", ", @{ $Data->{$tag} } )
                ), "\n";
   }
}

# ------------------------------- sortKeys -------------------------------

sub sortKeys {
   my $Cla  = shift;
   my $Data = shift;
   my $Pts  = shift;

   my @Rv;

   if ( $Cla->{numericTagSort} ) {
      @Rv = sort { $a <=> $b } keys %$Data;
   } else {
      @Rv = sort { $a cmp $b } keys %$Data;
   }

   return wantarray ? @Rv : \@Rv;
}

# ------------------------------ processTag ------------------------------

sub processTag {
   my $Cla  = shift;
   my $Data = shift;
   my $Pts  = shift;
   my $PtsN = shift;
   my $Tag  = shift;

   my $data = $Data->{$Tag};
   my $pts  = $Pts->{$Tag};

   if ( $Cla->{plot} ) {
      plotData($Cla, $data, $pts, $PtsN, $Tag);
   } else {
      tabulateData($Cla, $data, $pts, $PtsN, $Tag);
   }
}

# -------------------------- tabulateStatistics --------------------------

sub tabulateData {
   my $Cla  = shift;
   my $Data = shift;
   my $Pts  = shift;
   my $PtsN = shift;
   my $Tag  = shift;

   # my $data = {};
   # foreach ( @{ $data } ) {
   #   $data->{ sprintf( '%0.2f', $_ ) }++;
   # }
   #
   # print qq{\n"$k\n};
   # foreach ( sort { $a <=> $b } keys %{ $data } ) {
   #   print join( "\t", $_, $data->{ $_ } ), "\n";
   # }


   # get median
   # ..................................................

   my $median_r;

   # even number of points
   if ( $Pts % 2 == 0 ) {
      $median_r = ( $Data->[$Pts/2 - 1] + $Data->[$Pts/2] ) / 2;
   }

   # odd nmber of points
   else {
      $median_r = $Data->[ $Pts/2 ];
   }


   # get mean
   # ..................................................

   my $mean_r  = CBIL::Util::V::average(@$Data);
   #foreach (@$Data) { $total_r += $_ }

   # get stddev and variance
   # ..................................................

   my $var_r = CBIL::Util::V::sum(map { ($_ - $mean_r)**2 } @$Data);
   $var_r /= $Pts-1 || 1;

   my $std_r = sqrt( $var_r );

   # get min and max
   # ..................................................

   my $d_min  = CBIL::Util::V::min(@$Data);
   my $d_max  = CBIL::Util::V::max(@$Data);
   my $d_span = $d_max - $d_min;

   # output data
   # ..................................................

   print join( "\t",
               $Cla->{LabelLast} ? () : ($Tag),
               $Pts,
               sprintf( $Cla->{format}, $Pts/$PtsN),
               ( map { sprintf( $Cla->{format}, $_ ) }
                 $median_r, $mean_r, $std_r, $var_r, $d_min, $d_max, $d_span, $PtsN
               ),
               $Cla->{LabelLast} ? ($Tag) : (),
             ), "\n";
}

