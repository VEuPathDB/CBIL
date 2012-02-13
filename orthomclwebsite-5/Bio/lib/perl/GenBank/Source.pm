
package CBIL::Bio::GenBank::Source;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use CBIL::Bio::GenBank::BaseObject;
use CBIL::Bio::GenBank::Organism;

use strict 'vars';

sub setOrganism { $_[0]->{ORG} = $_[1]; $_[0] }

sub getOrganism { $_[0]->{ORG} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('SOURCE', $IOS, 0);

  $M->setOrganism( CBIL::Bio::GenBank::Organism->new( { ios => $IOS } ) );

  $M;
}

1;

