package CBIL::ISA::StudyAssay;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setAssayMeasurementType { $_[0]->{_assay_measurement_type} = $_[1] }
sub getAssayMeasurementType { $_[0]->{_assay_measurement_type} }

sub setAssayTechnologyType { $_[0]->{_assay_technology_type} = $_[1] }
sub getAssayTechnologyType { $_[0]->{_assay_technology_type} }

sub setAssayFileName { $_[0]->{_assay_file_name} = $_[1] }
sub getAssayFileName { $_[0]->{_assay_file_name} }

sub setAssayTechnologyPlatform { $_[0]->{_assay_technology_platform} = $_[1] }
sub getAssayTechnologyPlatform { $_[0]->{_assay_technology_platform} }

1;
