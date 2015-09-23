package CBIL::ISA::Unit;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["Characteristic", "FactorValue", "ParameterValue"];
}

1;
