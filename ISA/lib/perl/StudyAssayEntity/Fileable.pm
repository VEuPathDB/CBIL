package CBIL::ISA::StudyAssayEntity::Fileable;
use base qw(CBIL::ISA::StudyAssayEntity)

use strict;

sub isNode { return 1;}

sub addFile { push @{$_[0]->{_files}}, $_[1] }
sub getFiles { $_[0]->{_files} }


# subclasses must consider these
sub getAttributeNames {
  return ["File"];
}

1;
