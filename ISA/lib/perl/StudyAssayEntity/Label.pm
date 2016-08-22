package CBIL::ISA::StudyAssayEntity::Label;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["LabeledExtract" ];
}

1;
