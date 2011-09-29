package CBIL::TranscriptExpression::DataMunger::AllPairwisePaGE;
use base qw(CBIL::TranscriptExpression::DataMunger::PaGE);

use strict;

use CBIL::TranscriptExpression::Error;
use CBIL::TranscriptExpression::Utils;

use GUS::Community::FileTranslator;

use File::Basename;

my $MISSING_VALUE = 'NA';
my $USE_LOGGED_DATA = 1;

#-------------------------------------------------------------------------------

sub setAnalysisName          { $_[0]->{analysisName} = $_[1] }
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
              my $outputFile = $self->generateOutputFile($conditionAName,$conditionBName);
              my $aRef = $self->filterConditions($conditionAName);
              my $bRef = $self->filterConditions($conditionBName);
              my $avb = [@$bRef,@$aRef];
              my $clone = $self->clone();
              $clone->setConditions($avb);
              $clone->setOutputFile($outputFile);
              $clone->setAnalysisName($analysisName);
              $clone->SUPER::munge();
            }
          }
    }
 }

 sub generateAnalysisName {
   my ($self,$conditionAName,$conditionBName) = @_;
   return $conditionAName." vs ".$conditionBName;
 }

 sub generateOutputFile {
   my ($self,$conditionAName,$conditionBName) = @_;
   my $outputFile = $conditionAName." vs ".$conditionBName;
   $outputFile =~ s/ /_/g;
   return $outputFile;
 }

 sub filterConditions {
   my ($self,$conditionName) = @_;
   my $conditions =$self->getConditions();
   my @rv;
   foreach my $condition (@$conditions){
     my ($name,$value) = split(/\|/,$condition);
     if ( $name eq $conditionName){
       push @rv,$condition;
     }
   }
   return \@rv;
     
 }
1;
