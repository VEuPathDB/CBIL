package CBIL::ISA::StudyAssayEntity::Assay;
use base qw(CBIL::ISA::StudyAssayEntity::MaterialEntity);
use base qw(CBIL::ISA::StudyAssayEntity::Fileable);

use strict;

sub getParents {
  return ["Sample", "Extract", "LabeledExtract"];
}

# study assay has the measurment and technology types (ontologies) for the assay
sub setStudyAssay { $_[0]->{_study_assay} = $_[1] }
sub getStudyAssay { $_[0]->{_study_assay} }

1;
