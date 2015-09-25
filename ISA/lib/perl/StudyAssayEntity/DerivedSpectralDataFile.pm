package CBIL::ISA::StudyAssayEntity::DerivedSpectralDataFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["MsAssay", "NmrAssay"];
}

1;
