package CBIL::TranscriptExpression::DataMunger::AllPairwisePaGE;
use base qw(CBIL::TranscriptExpression::DataMunger::PaGE);

use strict;

#-------------------------------------------------------------------------------

sub setConditions            { $_[0]->{conditions} = $_[1] }

#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;
  $args->{analysisName} = "PlaceHolder";
  $args->{outputFile} = "AnotherPlaceHolder";
  my $self = $class->SUPER::new($args); 
  return $self;
}

 sub munge {
   my ($self) = @_;
   my $conditionsHashRef = $self->groupListHashRef($self->getConditions());
   my @groupNames = keys %$conditionsHashRef;
   my $fullConditions = $self->getConditions();
    for (my $i = 0; $i < scalar @groupNames; $i++) {
      my $conditionAName = $groupNames[$i];
      for (my $j = 0; $j < scalar @groupNames; $j++)
        {
          if ($j>$i) 
            {
              my $conditionBName = $groupNames[$j];
              my $analysisName = $self->generateAnalysisName($conditionAName,$conditionBName);
              my $outputFile = $self->generateOutputFile($conditionAName,$conditionBName, "PageOutput");
              my $aRef = $self->filterConditions($conditionAName);
              my $bRef = $self->filterConditions($conditionBName);
              my $avb = [@$bRef,@$aRef];
              my $clone = $self->clone();
              $clone->setConditions($avb);
              $clone->setOutputFile($outputFile);
              $clone->setAnalysisName($analysisName);

              my $profileElementsString = $conditionAName . ";" . $conditionBName;
              $clone->setProfileElementsAsString($profileElementsString);
              $clone->SUPER::munge();
            }
          }
    }
 }

 sub generateAnalysisName {
   my ($self,$conditionAName,$conditionBName) = @_;
   return $conditionAName." vs ".$conditionBName;
 }

1;
