
package CBIL::Bio::GenBank::Origin;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('ORIGIN', $IOS);

  $M->{STR} =~ s/\s//g;

  $M;
}

1;

