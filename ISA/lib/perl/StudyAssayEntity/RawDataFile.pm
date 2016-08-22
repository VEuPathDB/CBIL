package CBIL::ISA::StudyAssayEntity::RawDataFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["Assay", "GelElectrophoresisAssay"];
}

1;
