
package CBIL::Bio::GenBank::Keywords;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub getKeywords {  $_[0]->{KWD} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  my $A = $M->parseAsText('KEYWORDS', $IOS); 
	chop $A->[0];
	push my @K, split /\;/, $A->[0];
	$M->{KWD} = \@K;
	
  $M;
}

1;
