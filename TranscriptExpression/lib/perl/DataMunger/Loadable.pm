package CBIL::TranscriptExpression::DataMunger::Loadable;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;
use CBIL::TranscriptExpression::Error;

my $CONFIG_BASE_NAME = "insert_study_results_config.txt";

sub getDoNotLoad               { $_[0]->{doNotLoad} }

sub getSourceIdType         { $_[0]->{sourceIdType} }
sub setSourceIdType         { $_[0]->{sourceIdType} = $_[1] }

sub getDisplaySuffix {$_[0]->{displaySuffix}}
sub setDisplaySuffix {$_[0]->{displaySuffix} = $_[1]}

#--------------------------------------------------------------------------------


sub getProtocolName         { 
  my $self = shift;

  if($self->{_protocol_name}) {
    return $self->{_protocol_name};
  }

  return ref $self;
}
sub setProtocolName         { $_[0]->{_protocol_name} = $_[1] }

sub getProtocolParamsHash         { $_[0]->{_protocol_params_hash} }
sub addProtocolParamValue {
  my ($self, $key, $value) = @_;

  return $self->{_protocol_params_hash}->{$key} = $value;
}

sub getConfigFilePath         { 
  my ($self) = @_;

  my $mainDir = $self->getMainDirectory();
  my $configBaseName = $self->getConfigFileBaseName();

  return $mainDir . "/" . $configBaseName;
}

sub getConfigFileBaseName {
  my $self = shift;
  if($b = $self->{_config_file_base_name}) {
    return $b;
  }

  # Default
  return $CONFIG_BASE_NAME;
} 
sub setConfigFileBaseName         { $_[0]->{_config_file_base_name} = $_[1] }

sub getNames         { $_[0]->{_names} }
sub setNames         { $_[0]->{_names} = $_[1] }

sub getFileNames         { $_[0]->{_file_names} }
sub setFileNames         { $_[0]->{_file_names} = $_[1] }

sub getInputProtocolAppNodesHash         { $_[0]->{_input_protocol_app_nodes} }
sub setInputProtocolAppNodesHash         { $_[0]->{_input_protocol_app_nodes} = $_[1] }

sub createConfigFile { 
  my ($self) = @_;

  return if($self->getDoNotLoad());

  my $configFilePath = $self->getConfigFilePath();

  if(-e $configFilePath) {
    open(CONFIG, ">> $configFilePath") or die "Cannot open config file for writing: $!";
  }
  else {
    open(CONFIG, "> $configFilePath") or die "Cannot open config file for writing: $!";
    $self->printConfigHeader(\*CONFIG);
  }

  my $names = $self->getNames();

  my $fileNames = $self->getFileNames();
  my $inputProtocolAppNodesHash = $self->getInputProtocolAppNodesHash();

  unless(scalar @$names == scalar @$fileNames && scalar @$names > 0) {
    CBIL::TranscriptExpression::Error->new("AppNode Names and/or file name not specified correctly")->throw();
  }


  for(my $i = 0; $i < scalar @$names; $i++) {
    my $name = $names->[$i];


    my $fileName = $fileNames->[$i];
    my $inputProtocolAppNodes = $inputProtocolAppNodesHash->{$name};

    my $inputProtocolAppNodesString = join(";", @$inputProtocolAppNodes);

    if(my $displaySuffix = $self->getDisplaySuffix()) {
      $name .= $displaySuffix;
    }

    $self->printConfigLine(\*CONFIG, $name, $fileName, $inputProtocolAppNodesString);
  }

  close CONFIG;
}

sub printConfigLine {
  my ($self, $fh, $name, $fileName, $inputProtocolAppNodesString) = @_;

  my $protocolParamsHash = $self->getProtocolParamsHash();

  my @protocolParamValues = map {"$_|$protocolParamsHash->{$_}"} keys %{$protocolParamsHash};
  my $ppvString = join(";", @protocolParamValues);


  my @line = ($name,
              $fileName,
              $self->getSourceIdType(),
              $inputProtocolAppNodesString,
              $self->getProtocolName(),
              $ppvString,
      );

  print $fh join("\t", @line) . "\n";
}

sub printConfigHeader {
  my ($self, $fh) = @_;

  my @header = ("Name",
                "File Name",
                "Source ID Type",
                "Input ProtocolAppNodes",
                "Protocol",
                "ProtocolParams"
      );

  print $fh join("\t", @header) . "\n";
}



1;
