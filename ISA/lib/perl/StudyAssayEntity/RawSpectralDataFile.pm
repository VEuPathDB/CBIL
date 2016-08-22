package CBIL::ISA::StudyAssayEntity::RawSpectralDataFile;
use base qw(CBIL::ISA::StudyAssayEntity::FileAttribute);

use strict;

sub getParents {
  return ["MsAssay"];
}

1;
