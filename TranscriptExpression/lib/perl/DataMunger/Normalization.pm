package CBIL::TranscriptExpression::DataMunger::Normalization;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use CBIL::TranscriptExpression::Error;

#-------------------------------------------------------------------------------

sub getMappingFile          { $_[0]->{mappingFile} }
sub getOutputFile           { $_[0]->{outputFile} }
sub getDataFiles            { $_[0]->{dataFiles} }
sub getPathToExecutable     { $_[0]->{pathToExecutable} }
sub getPathToDataFiles      { $_[0]->{pathToDataFiles} }

sub isMappingFileZipped     {
  my ($self) = @_;
  my $mappingFile = $self->getMappingFile();

  if($mappingFile =~ /\.gz$/) {
    return 1;
  }
  return 0;
}

#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['mappingFile',
                        'outputFile',
                        'dataFiles',
                        'pathToDataFiles',
                        ];

  my $self = $class->SUPER::new($args, $requiredParams);

  my $mappingFile = $args->{mappingFile};
  unless(-e $mappingFile) {
    CBIL::TranscriptExpression::Error->new("input file $mappingFile does not exist")->throw();
  }

  return $self;
}

sub makeDataFilesRString {
  my ($self) = @_;

  my $dataFilesHash = $self->groupListHashRef($self->getDataFiles());

  my $rv = "";

  my $n = 1;
  # this is an ordered hash
  foreach my $filename (keys %$dataFilesHash) {
    $rv .= "data.files[$n] = \"$filename\";\n";
    $n++;
  }
  return $rv;
}



1;
