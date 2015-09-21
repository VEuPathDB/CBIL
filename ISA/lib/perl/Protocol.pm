package CBIL::ISA::Protocol;

use strict;

sub new {
  my $class = shift;
  return bless {}, $class;
}

sub setName { $_[0]->{_name} = $_[1] }
sub getName { $_[0]->{_name} }

sub setType { $_[0]->{_type} = $_[1] }
sub getType { $_[0]->{_type} }

sub setDescription { $_[0]->{_description} = $_[1] }
sub getDescription { $_[0]->{_description} }

sub setUri { $_[0]->{_uri} = $_[1] }
sub getUri { $_[0]->{_uri} }

sub setVersion { $_[0]->{_version} = $_[1] }
sub getVersion { $_[0]->{_version} }

sub addProtocolParam { push @{$_[0]->{_protocol_params}}, $_[1] }
sub getProtocolParams { $_[0]->{_protocol_params} }

1;
