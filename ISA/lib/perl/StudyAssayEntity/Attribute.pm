package CBIL::ISA::StudyAssayEntity::Attribute;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return [ "Phenotype" ];
}

1;
