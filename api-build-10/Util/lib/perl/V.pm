
package CBIL::Util::V;

=pod

=head1 Synopsis

This package implements a number of utility functions on 'vectors',
hence the abbreviated package name.

=cut

# ======================================================================

use strict 'vars';

# ======================================================================

# --------------------------------- zip ----------------------------------

sub zip {
  my $List = (scalar(@_) == 1 && ref $_[0] eq 'LIST') ? shift : \@_;

  my @Rv;

  my $N    = int(scalar(@$List)/2);

  for (my $i = 0; $i < $N; $i++) {
    push(@Rv, $List->[$i], $List->[$i+$N]);
  }

  return wantarray ? @Rv : {@Rv};
}

# --------------------------------- max ----------------------------------

=pod

=head2 max

Returns the maxium value in the list.

=cut

sub max {
   my $rv = shift;
   foreach ( @_ ) {
      $rv = $_ if $rv < $_;
   }
   return $rv;
}

=pod

=head2 argmax

Returns the 0-based index of the (first) maximum value.

=cut

sub argmax {
  my $Rv;

  if (@_) {
    $Rv  = 0;
    my $max = $_[0];

    for (my $i = 1; $i < @_; $i++) {
      if ($max < $_[$i]) {
	$max = $_[$i];
	$Rv  = $i;
      }
    }
  }

  return $Rv;
}

=pod

=head2 min

Returns the mininum value in a list.

=cut

sub min {
   my $rv = shift;
   foreach ( @_ ) {
      $rv = $_ if $rv > $_;
   }
   return $rv;
}

=pod

=head2 intersection

Returns the values common to two lists.

=cut

sub intersection {
   my $alist = shift;
   my $blist = shift;

   my $keys;

   foreach ( @{ $alist } ) {
      $keys->{ $_ } = 1;
   }
   foreach ( @{ $blist } ) {
      $keys->{ $_ }++;
   }

   return [ grep { $keys->{ $_ } == 2 } keys %{ $keys } ];
}

=pod

=head2 sum

Returns the total value of all items in a list.

=cut

sub sum {
   my $rv = 0;
   foreach ( @_ ) {
      $rv += $_;
   }
   $rv
}

=pod

=head2 product

Returns the total product of all items in a list.

=cut

sub product {
   my $rv = 1;
   foreach ( @_ ) {
      $rv *= $_;
   }
   $rv
}

=pod

=head2 entropy

Returns the entropy of all items in a list.  Does not normalize to 1
before computing.

=cut

sub entropy {
   my $rv = 0;
   foreach ( @_ ) {
      next unless $_ > 0;
      $rv -= $_ * log( $_ );
   }
   $rv /= log( 2.0 );
   $rv
}

=pod

=head2 average

Returns the average (mean) value of all items in a list.

=cut

sub average {
   my $n  = scalar @_;
   return undef unless $n > 0;
   sum( @_ ) / scalar @_
}

=pod

=head2 median

Returns the median value of all items in a list.

=cut

sub median {
   my $n = scalar @_;

   my @sortedData = sort {$a<=>$b} @_;
   if ($n % 2 == 0) {
      my $i = $n/2;
      return ($sortedData[$i] + $sortedData[$i-1]) / 2;
   } else {
      return $sortedData[($n-1)/2];
   }
}

=pod

=head2 variance

Returns the variance of all items in a list.

=cut

sub variance {
   my $Rv = 0;

   my $n       = scalar @_;
   if ($n > 1) {
      my $average = average(@_);

      foreach (@_) {
         $Rv += ($_ - $average)**2;
      }

      $Rv /= ($n-1);
   }

   return $Rv;
}

=pod

=head2 sd

Returns the standard deviation of the values in a list.

=cut

sub sd { return sqrt(variance(@_)) }

=pod

=head2 dot_product

Returns the dot product of two vectors.  Uses the minimum length of
the two, then multiplies each corresponding elements and returns the
sum of these products.

=cut

sub dot_product {
   my $av = shift;
   my $bv = shift;

   my $n = min( scalar @{ $av }, scalar @{ $bv } );

   my $rv = 0;
   for ( my $i = 0; $i < $n; $i++ ) {
      $rv += $av->[ $i ] * $bv->[ $i ] / $n;
   }

   $rv
}

# ----------------------------------------------------------------------

1;

__END__
