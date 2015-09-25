package CBIL::ISA::StudyAssayEntity::Fileable;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub isNode { return 1;}

sub addFile { push @{$_[0]->{_files}}, $_[1] }
sub getFiles { $_[0]->{_files} }

sub getAttributeNames {
  my ($self) = @_;

  my @attributeQualifiers = ("File");

  my $attrs = $self->SUPER::getAttributeNames();

  push @{$attrs}, @attributeQualifiers;

  return $attrs;
}



1;
