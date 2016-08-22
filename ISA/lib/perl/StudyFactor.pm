package CBIL::ISA::StudyFactor;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setFactorType { $_[0]->{_factor_type} = $_[1] }
sub getFactorType { $_[0]->{_factor_type} }

sub setFactorName { $_[0]->{_factor_name} = $_[1] }
sub getFactorName { $_[0]->{_factor_name} }



1;
