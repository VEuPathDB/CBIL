
package CBIL::Bio::GenBank::Authors;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub setAuthors { $_[0]->{AUT} = $_[1]; $_[0] }

sub getString  { $_[0]->{STR} }
# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('\s+AUTHORS', $IOS);

  $_ = $M->getString();

  $M->setAuthors( [ split( /\s*(?:,)\s+|\s*(?:and)\s+/, $_ ) ] );

  $M
}

1;

