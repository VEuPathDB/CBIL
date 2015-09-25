package CBIL::ISA::StudyAssayEntity::AcquisitionParameterDataFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["NmrAssay"];
}

1;
