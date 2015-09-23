package CBIL::ISA::MaterialType;
use base qw(CBIL::ISA::OntologyTerm);

use strict;

sub getParents {
  return ["Source", "Sample", "Extract", "LabeledExtract" ];
}

1;
