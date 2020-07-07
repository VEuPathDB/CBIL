package CBIL::ISA::StudyAssayEntity::Observable;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return [ "Phenotype" ];
}

1;
