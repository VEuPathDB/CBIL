package CBIL::ISA::Comment;
use base qw(CBIL::ISA::StudyAssayEntity);

use strict;

sub setQualifier { $_[0]->{_qualifier} = $_[1] }
sub getQualifier { $_[0]->{_qualifier} }

sub setValue { $_[0]->{_value} = $_[1] }
sub getValue { $_[0]->{_value} }

sub new {
  my ($class, $args) = @_;
  return bless $args, $class;
}


1;
