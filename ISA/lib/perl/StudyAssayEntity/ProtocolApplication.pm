package CBIL::ISA::StudyAssayEntity::ProtocolApplication;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub addParameterValue { push @{$_[0]->{_parameter_values}}, $_[1] }
sub getParameterValues { $_[0]->{_parameter_values} || [] }

sub setPerformer { $_[0]->{_performer} = $_[1] }
sub getPerformer { $_[0]->{_performer} }

sub setDate { $_[0]->{_date} = $_[1] }
sub getDate { $_[0]->{_date} }

# Reference to the protocol object
sub setProtocol { $_[0]->{_protocol} = $_[1] }
sub getProtocol { $_[0]->{_protocol} }


sub getParents {
  return [];
}

sub getAttributeNames {
  return ["ParameterValue", "Performer", "Date"];
}


1;
