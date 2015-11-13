package CBIL::ISA::Protocol;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setProtocolName { $_[0]->{_protocol_name} = $_[1] }
sub getProtocolName { $_[0]->{_protocol_name} }

sub setProtocolType { $_[0]->{_protocol_type} = $_[1] }
sub getProtocolType { $_[0]->{_protocol_type} }


sub setProtocolDescription { $_[0]->{_protocol_description} = $_[1] }
sub getProtocolDescription { $_[0]->{_protocol_description} }

sub setProtocolUri { $_[0]->{_protocol_uri} = $_[1] }
sub getProtocolUri { $_[0]->{_protocol_uri} }

sub setProtocolVersion { $_[0]->{_protocol_version} = $_[1] }
sub getProtocolVersion { $_[0]->{_protocol_version} }

sub addProtocolParameters { push @{$_[0]->{_protocol_parameters}}, $_[1] }
sub getProtocolParameters { $_[0]->{_protocol_parameters}  || [] }

sub addProtocolComponentsType { push @{$_[0]->{_protocol_components_type}},  $_[1] }
sub getProtocolComponentsType { $_[0]->{_protocol_components_type}  || [] }


1;
