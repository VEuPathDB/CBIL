package CBIL::ISA::StudyAssayEntity::DataTransformation;
use base qw(CBIL::ISA::StudyAssayEntity::Fileable CBIL::ISA::StudyAssayEntity::MaterialEntity);

use strict;

sub getParents {
  return ["Assay", "GelElectrophoresisAssay", "MsAssay", "NmrAssay", "HybridizationAssay"];
}

1;
