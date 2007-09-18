
package CBIL::Bio::GenBank::Organism;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use strict 'vars';

sub setSpecies  { $_[0]->{SPE} = $_[1]; $_[0] }
sub setTaxonomy { $_[0]->{TAX} = $_[1]; $_[0] }

sub getSpecies  { $_[0]->{SPE} }
sub getTaxonomy { $_[0]->{TAX} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  my $org = $M->parseAsText('\s+ORGANISM',$IOS);
  $M->setSpecies(shift @$org);
  my @tax = map { s/\.$//; $_ } split( /\s*;\s+/ , join(' ',@$org) );
  $M->setTaxonomy( [ @tax ] );

  $M;
}

1;

