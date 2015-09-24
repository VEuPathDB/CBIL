package CBIL::ISA::StudyAssayEntity::Description;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub isNode { return 0; }

sub getAttributeNames {
  return [];
}

sub getParents {
  return ["Source", "Sample", "Extract", "LabeledExtract"];
}


1;
