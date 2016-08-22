package CBIL::TranscriptExpression::DataMunger::TwoStateComparison;
use base qw(CBIL::TranscriptExpression::DataMunger::Loadable);

use strict;

sub generateOutputFile {
   my ($self, $conditionAName, $conditionBName, $suffix) = @_;

   my $outputFile = $conditionAName . " vs " . $conditionBName;
   $outputFile = $outputFile . "." . $suffix if($suffix);
   $outputFile =~ s/ /_/g;

   return $outputFile;
 }








1;

