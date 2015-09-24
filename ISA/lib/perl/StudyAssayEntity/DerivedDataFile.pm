package CBIL::ISA::StudyAssayEntity::DerivedDataFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["Assay", "GelElectrophoresisAssay"];
}

1;
