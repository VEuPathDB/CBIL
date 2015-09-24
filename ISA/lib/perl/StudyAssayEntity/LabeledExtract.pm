package CBIL::ISA::StudyAssayEntity::LabeledExtract;
use base qw(CBIL::ISA::StudyAssayEntity::MaterialEntity);

use strict;

sub getParents {
  return ["Extract"];
}

1;
