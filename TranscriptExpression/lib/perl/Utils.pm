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


sub headerIndexHashRef {
  my ($headerString, $delRegex)  = @_;

  my %rv;

  my @a = split($delRegex, $headerString);
  for(my $i = 0; $i < scalar @a; $i++) {
    my $value = $a[$i];

    $rv{$value} = $i;
  }

  return \%rv;
}


1;
