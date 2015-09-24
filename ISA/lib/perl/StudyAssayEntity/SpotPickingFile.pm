package CBIL::ISA::StudyAssayEntity::SpotPickingFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["GelElectrophoresisAssay"];
}

1;
