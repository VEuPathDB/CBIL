package CBIL::ISA::StudyAssayEntity::ImageFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["Assay", "HybridizationAssay", "GelElectrophoresisAssay"];
}

1;
