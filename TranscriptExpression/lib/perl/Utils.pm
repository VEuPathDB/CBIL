package CBIL::TranscriptExpression::Utils;

use strict;

sub checkRequiredParams {
  my ($requiredParamArrayRef, $args) = @_;

  unless($requiredParamArrayRef) {
    return 1;
  }

  foreach my $param (@$requiredParamArrayRef) {
    unless($args->{$param}) {
      CBIL::TranscriptExpression::Error->new("Parameter [$param] is missing in the xml file.")->throw();
    }
  }
}


1;
