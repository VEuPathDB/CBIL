
package CBIL::Bio::GenBank::Definition;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('DEFINITION', $IOS);

  $M;
}

1;

