package CBIL::ISA::StudyAssayEntity::Unit;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["Characteristic", "FactorValue", "ParameterValue", "Value"];
}

1;
