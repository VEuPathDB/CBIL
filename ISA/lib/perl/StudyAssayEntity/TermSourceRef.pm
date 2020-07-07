package CBIL::ISA::StudyAssayEntity::TermSourceRef;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub getAttributeNames {
  return [];
}

sub getParents {
  return ["Characteristic", "MaterialType", "FactorValue", "ParameterValue", "Unit", "Observable", "Attribute", "Type"];
}


1;
