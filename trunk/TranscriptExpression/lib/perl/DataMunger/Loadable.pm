package CBIL::TranscriptExpression::DataMunger::Loadable;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

sub getDoNotLoad               { $_[0]->{doNotLoad} }

sub createConfigFile {}

1;
