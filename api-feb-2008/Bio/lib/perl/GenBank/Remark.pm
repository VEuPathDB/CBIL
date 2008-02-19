
package CBIL::Bio::GenBank::Remark;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('REMARK', $IOS);

  $M;
}

1;

