
package CBIL::Bio::GenBank::Comment;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub getString { $_[0]->{STR} };
# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('COMMENT', $IOS);

  $M;
}

1;

