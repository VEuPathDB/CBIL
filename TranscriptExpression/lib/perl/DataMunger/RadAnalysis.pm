package CBIL::TranscriptExpression::DataMunger::RadAnalysis;
use base qw(CBIL::TranscriptExpression::DataMunger::Loadable);

use strict;

#-------------------------------------------------------------------------------
# Data Sets which we load into the RAD Schema with InsertSimpleRadAnslysis
#-------------------------------------------------------------------------------

sub getAnalysisName         { $_[0]->{analysisName} }
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
  my ($self) = @_;

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
  my $configLine = join("\t", @configLineColumns);

  if (-e $configFileLocation){
    open(CFH, ">> $configFileLocation") or die "Cannot open file $configFileLocation for writing: $!";  
  }
  else {
    open(CFH, "> $configFileLocation") or die "Cannot open file $configFileLocation for writing: $!";
    my $analysisHeader = "dataFile\tanalysisName\tprotocolName\tprotocolType\tprofilesetname\tprofileelementnames\n";
    print CFH $analysisHeader;
  }

  print CFH $configLine."\n";
  close CFH;
}


1;
