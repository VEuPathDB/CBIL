
package CBIL::Bio::GenBank::Segment;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('SEGMENT', $IOS);

  $M;
}

1;

