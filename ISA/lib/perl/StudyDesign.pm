package CBIL::ISA::StudyDesign;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setDesignType { $_[0]->{_design_type} = $_[1] }
sub getDesignType { $_[0]->{_design_type} }




1;
