package CBIL::ISA::OntologySource;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setTermSourceFile { $_[0]->{_term_source_file} = $_[1] }
sub getTermSourceFile { $_[0]->{_term_source_file} }

sub setTermSourceName { $_[0]->{_term_source_name} = $_[1] }
sub getTermSourceName { $_[0]->{_term_source_name} }

sub setTermSourceVersion { $_[0]->{_term_source_version} = $_[1] }
sub getTermSourceVersion { $_[0]->{_term_source_version} }

sub setTermSourceDescription { $_[0]->{_term_source_description} = $_[1] }
sub getTermSourceDescription { $_[0]->{_term_source_description} }


1;
