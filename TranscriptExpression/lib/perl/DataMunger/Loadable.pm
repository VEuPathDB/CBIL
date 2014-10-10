package CBIL::TranscriptExpression::DataMunger::Loadable;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

sub getDoNotLoad               { $_[0]->{doNotLoad} }

sub getProtocolName         { $_[0]->{_protocol_name} }
sub setProtocolName         { $_[0]->{_protocol_name} = $_[1] }

sub getProtocolParamNames         { $_[0]->{_protocol_param_names} }
sub setProtocolParamNames         { $_[0]->{_protocol_param_names} = $_[1] }

sub getInputProtocolAppNodes         { $_[0]->{_input_protocol_app_nodes} }
sub setInputProtocolAppNodes         { $_[0]->{_input_protocol_app_nodes} = $_[1] }

sub getSourceIdType         { $_[0]->{_source_id_type} }
sub setSourceIdType         { $_[0]->{_source_id_type} = $_[1] }

sub getConfigFilePath         { $_[0]->{_config_file_path} }
sub setConfigFilePath         { $_[0]->{_config_file_path} = $_[1] }

sub createConfigFile {}


# sub createConfigFile {
#   my ($self, $skipRow) = @_;

#   return if($self->getDoNotLoad());

#   my $analysisName = $self->getAnalysisName();
#   my $profileSetName = $self->getProfileSetName();

#   my $mainDir = $self->getMainDirectory();
#   my $dataFile = $self->getOutputFile() ;

#   my $profileElementName= $self->getProfileElementsAsString();
#   my $protocolName = $self->getProtocolName();
#   my $protocolType = $self->getProtocolType();
#   my $configFile = $self->getConfigFile();

#   my $configFileLocation = $mainDir . "/" . $configFile;

#   my @configLineColumns = ($dataFile, $analysisName, $protocolName, $protocolType, $profileSetName, $profileElementName);
#   my $configLine = join("\t", @configLineColumns) . "\n";

#   my $analysisHeader = "dataFile\tanalysisName\tprotocolName\tprotocolType\tprofilesetname\tprofileelementnames\n";

#   if (-e $configFileLocation){
#     open(CFH, ">> $configFileLocation") or die "Cannot open file $configFileLocation for writing: $!";  
#   }
#   else {
#     open(CFH, "> $configFileLocation") or die "Cannot open file $configFileLocation for writing: $!";
#     print CFH $analysisHeader;
#   }

#   print CFH $configLine unless($skipRow);
#   close CFH;
# }


1;
