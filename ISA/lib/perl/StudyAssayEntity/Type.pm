package CBIL::ISA::StudyAssayEntity::Type;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return [ "Genotype" ];
}

1;
