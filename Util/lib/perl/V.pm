
package CBIL::Util::V;

=pod

=head1 Synopsis

This package implements a number of utility functions on 'vectors',
hence the abbreviated package name.

=cut

# ======================================================================

use strict 'vars';

# ======================================================================

sub max {
	my $rv = shift;
	foreach ( @_ ) {
		$rv = $_ if $rv < $_;
	}
	return $rv;
}

sub min {
	my $rv = shift;
	foreach ( @_ ) {
		$rv = $_ if $rv > $_;
	}
	return $rv;
}

sub intersection {
	my $alist = shift;
	my $blist = shift;

	my $keys;

	foreach ( @{ $alist } ) { $keys->{ $_ } = 1 }
	foreach ( @{ $blist } ) { $keys->{ $_ }++ }

	return [ grep { $keys->{ $_ } == 2 } keys %{ $keys } ];
}

sub sum {
	my $rv = 0;
	foreach ( @_ ) { $rv += $_ }
	$rv
}

sub product {
	my $rv = 1;
	foreach ( @_ ) { $rv *= $_ }
	$rv
}

sub entropy {
	my $rv = 0;
	foreach ( @_ ) {
		next unless $_ > 0;
		$rv -= $_ * log( $_ );
	}
	$rv /= log( 2.0 );
	$rv
}

sub average {
	my $n  = scalar @_;
	return undef unless $n > 0;
	V::sum( @_ ) / scalar @_
}

sub median {
   my $n = scalar @_;

   my @sortedData = sort {$a<=>$b} @_;
   if ($n % 2 == 0) {
      my $i = $n/2;
      return ($sortedData[$i] + $sortedData[$i-1]) / 2;
   }
   else {
      return $sortedData[($n-1)/2];
   }
}

sub dot_product {
	my $av = shift;
	my $bv = shift;

	my $n =V::min( scalar @{ $av }, scalar @{ $bv } );

	my $rv = 0;
	for ( my $i = 0; $i < $n; $i++ ) {
		$rv += $av->[ $i ] * $bv->[ $i ] / $n;
	}

	$rv
}

# ----------------------------------------------------------------------

1;

__END__
