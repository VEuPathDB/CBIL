package CBIL::ISA::StudyAssayEntity::Scan;
use base qw(CBIL::ISA::StudyAssayEntity::Fileable)

use strict;

sub getParents {
  return ["HybridizationAssay", "GelElectrophoresisAssay"];
}

1;
