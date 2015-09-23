package CBIL::ISA::Label;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["LabeledExtract" ];
}

1;
