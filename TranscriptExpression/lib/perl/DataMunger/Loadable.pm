package CBIL::TranscriptExpression::DataMunger::Loadable;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

sub getDoNotLoad               { $_[0]->{doNotLoad} }

sub getProtocolName         { 
  my $self = shift;

  return $self->{_protocol_name} if($self->{_protocol_name});

  my $protocolByClassName = ref $self;
  $protocolByClassName =~ /\:\:(.+)$/;
  my $protocolName = $1;

  return $protocolName
}
sub setProtocolName         { $_[0]->{_protocol_name} = $_[1] }

sub getProtocolParamNames         { $_[0]->{_protocol_param_names} }
sub setProtocolParamNames         { $_[0]->{_protocol_param_names} = $_[1] }

sub getInputProtocolAppNodes         { $_[0]->{_input_protocol_app_nodes} }
sub setInputProtocolAppNodes         { $_[0]->{_input_protocol_app_nodes} = $_[1] }

sub getSourceIdType         { $_[0]->{_source_id_type} }
sub setSourceIdType         { $_[0]->{_source_id_type} = $_[1] }

sub getConfigFilePath         { $_[0]->{_config_file_path} }
sub setConfigFilePath         { $_[0]->{_config_file_path} = $_[1] }

sub createConfigFile { }

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

# sub createConfigFile{
#   my ($self) = @_;
#   my $profileString = '';
#   my $percentileString = '';
#   my $standardErrorString = '';
#   my $redPercentileString = '';
#   my $greenPercentileString = '';
#   my $isLogged = 1;
#   my $base = 2;
#   if (defined $self->getIsLogged()){
#     $isLogged = $self->getIsLogged();
#   }
#   if ($isLogged && defined $self->getBase() ) {
#       $base= $self->getBase();
#     }
#   if (!$isLogged) {
#     $base = undef;
#   }
  
#   my $sourceIdType = $self->getSourceIdType;
#   my $loadProfileElement = $self->getLoadProfileElement();
#   my $baseCols = [$sourceIdType,$SKIP_SECOND_ROW,$loadProfileElement];
#   my $mainDir = $self->getMainDirectory();
#   my $PROFILE_CONFIG_FILE_LOCATION = $mainDir. "/" . $PROFILE_CONFIG_FILE_NAME;
#   unless(-e $PROFILE_CONFIG_FILE_LOCATION){
#    open(PCFH, "> $PROFILE_CONFIG_FILE_LOCATION") or die "Cannot open file $PROFILE_CONFIG_FILE_NAME for writing: $!"; 
#   }
#   else {
#    open(PCFH, ">> $PROFILE_CONFIG_FILE_LOCATION") or die "Cannot open file $PROFILE_CONFIG_FILE_NAME for writing: $!";
#    }
#   $profileString = $self->createConfigLine('',$baseCols, $isLogged, $base );
#   print PCFH "$profileString\n" ;
#   if ($self->getMakePercentiles() && !$self->getHasRedGreenFiles()) {
#     $percentileString = $self->createConfigLine('pct',$baseCols, 0, undef );
#     print PCFH "$percentileString\n";
#   }
#   if ($self->getMakeStandardError()) {
#     $standardErrorString = $self->createConfigLine('stderr',$baseCols, 0, undef );
#     print PCFH "$standardErrorString\n";
#   }
#   if ($self->getMakePercentiles() && $self->getHasRedGreenFiles()) {
#     $greenPercentileString = $self->createConfigLine('greenPct',$baseCols, 0, undef );
#     $redPercentileString = $self->createConfigLine('redPct',$baseCols, 0, undef );
#     print PCFH "$greenPercentileString\n$redPercentileString\n";
#   close PCFH;
#   }
# }

# sub createConfigLine {
#   my ($self,$type,$baseCols, $logged, $baseX) = @_;
#   my $dataFileBase = $self->getOutputFile();
#   my $profileSetName = $self->getProfileSetName();
#   my $profileSetDescription = $self->getProfileSetDescription();
#   my @base = (@$baseCols, $logged, $baseX);
#   my $prefix = '';
#   if ($type eq 'pct') {
#     $prefix = 'percentile - ';
#     if (!$self->getHasRedGreenFiles()) {
#       $self->setPercentileSetPrefix($prefix);
#     }
#   }
#   elsif ($type eq 'stderr') {
#     $prefix = 'standard error - ';}
#   elsif ($type eq 'greenPct') {
#     $prefix = 'green percentile - ';
#     if ($self->getPercentileChannel() =='green') {
#       $self->setPercentileSetPrefix($prefix);
#     }
#   }
#   elsif ($type eq 'redPct') {
#     $prefix = 'red percentile - ';
#       if ($self->getPercentileChannel()=='red') {
#       $self->setPercentileSetPrefix($prefix);
#     }
#   }
#   else { $prefix = '';}
#   if ($prefix) {
#     $type = '.' . $type;
#   }
#   my $dataFile = $dataFileBase . $type; 
#   my $profileSetName = $prefix . $profileSetName;
#   my $profileSetDescription = $prefix . $profileSetDescription;
#   my @cols = ("$dataFile", "$profileSetName",  "$profileSetDescription",);
#   push(@cols, @base);
#   my $configString = join("\t", @cols);
  
#   return $configString;
# }

1;
