package CBIL::ISA::StudyAssayEntity::TermAccessionNumber;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub getAttributeNames {
  return [];
}

sub getParents {
  return ["Characteristic", "MaterialType", "FactorValue", "ParameterValue", "Unit"];
}


1;
