package CBIL::TranscriptExpression::DataMunger::RadAnalysis;
use base qw(CBIL::TranscriptExpression::DataMunger::Loadable);

use strict;

#-------------------------------------------------------------------------------
# Data Sets which we load into the RAD Schema with InsertSimpleRadAnslysis
#-------------------------------------------------------------------------------

sub getAnalysisName         { $_[0]->{analysisName} }
sub setAnalysisName         { $_[0]->{analysisName} = $_[1] }

sub getProfileSetName       { $_[0]->{profileSetName} }

#-------------------------------------------------------------------------------

sub getProtocolName         { $_[0]->{_protocol_name} }
sub setProtocolName         { $_[0]->{_protocol_name} = $_[1] }

sub getProtocolType         { $_[0]->{_protocol_type} }
sub setProtocolType         { $_[0]->{_protocol_type} = $_[1] }

sub getConfigFile           { $_[0]->{_config_file} }
sub setConfigFile           { $_[0]->{_config_file} = $_[1] }

sub getProfileElementsAsString { $_[0]->{_profile_elements_as_string} }
sub setProfileElementsAsString { $_[0]->{_profile_elements_as_string} = $_[1] }


sub createConfigFile {
  my ($self, $skipRow) = @_;

  return if($self->getDoNotLoad());

  my $analysisName = $self->getAnalysisName();
  my $profileSetName = $self->getProfileSetName();

  my $mainDir = $self->getMainDirectory();
  my $dataFile = $self->getOutputFile() ;

  my $profileElementName= $self->getProfileElementsAsString();
  my $protocolName = $self->getProtocolName();
  my $protocolType = $self->getProtocolType();
  my $configFile = $self->getConfigFile();

  my $configFileLocation = $mainDir . "/" . $configFile;

  my @configLineColumns = ($dataFile, $analysisName, $protocolName, $protocolType, $profileSetName, $profileElementName);
  my $configLine = join("\t", @configLineColumns) . "\n";

  my $analysisHeader = "dataFile\tanalysisName\tprotocolName\tprotocolType\tprofilesetname\tprofileelementnames\n";

  if (-e $configFileLocation){
    open(CFH, ">> $configFileLocation") or die "Cannot open file $configFileLocation for writing: $!";  
  }
  else {
    open(CFH, "> $configFileLocation") or die "Cannot open file $configFileLocation for writing: $!";
    print CFH $analysisHeader;
  }

  print CFH $configLine unless($skipRow);
  close CFH;
}


sub generateOutputFile {
   my ($self, $conditionAName, $conditionBName, $suffix) = @_;

   my $outputFile = $conditionAName . " vs " . $conditionBName;
   $outputFile = $outputFile . "." . $suffix if($suffix);
   $outputFile =~ s/ /_/g;

   return $outputFile;
 }

 sub filterConditions {
   my ($self, $conditionName) = @_;

   my $conditions =$self->getConditions();
   my @rv;

   foreach my $condition (@$conditions){
     my ($name, $value) = split(/\|/, $condition);
     if ( $name eq $conditionName){
       push @rv, $condition;
     }
   }
   return \@rv;
 }



1;
