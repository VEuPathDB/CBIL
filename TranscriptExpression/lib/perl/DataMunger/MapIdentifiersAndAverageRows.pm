package CBIL::TranscriptExpression::DataMunger::MapIdentifiersAndAverageRows;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use CBIL::TranscriptExpression::Error;
use File::Temp qw/ tempfile /;
use File::Basename;

#-------------------------------------------------------------------------------

sub getMappingFile          { $_[0]->{mappingFile} }
sub getInputFile            { $_[0]->{inputFile} }
sub hasHeader               { $_[0]->{filesHaveHeaderRows} }

#--------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['mappingFile',
                        'inputFile',
                        'outputFile',
                        'filesHaveHeaderRows',
                        ];

  my $self = $class->SUPER::new($args, $requiredParams);

  my $mappingFile = $args->{mappingFile};
  unless(-e $mappingFile) {
    CBIL::TranscriptExpression::Error->new("mapping file $mappingFile does not exist")->throw();
  }

  my $inputFile = $args->{inputFile};
  unless(-e $inputFile) {
    CBIL::TranscriptExpression::Error->new("input file $inputFile does not exist")->throw();
  }

  return $self;
}

#--------------------------------------------------------------------------------

sub munge {
  my ($self) = @_;

  my $tempFileName = $self->makeOrderedMapFile();

  my $rFile = $self->writeRScript($tempFileName);

  $self->runR($rFile);

  unlink($rFile, $tempFileName);
}

#--------------------------------------------------------------------------------

sub makeOrderedMapFile {
  my ($self) = @_;

  my ($fh, $filename) = tempfile();

  my $map = $self->readMappingFile();

  my $inputFile = $self->getInputFile();

  open(FILE, $inputFile) or CBIL::TranscriptExpression::Error->new("Cannot open file $inputFile for reading: $!")->throw();


  if($self->hasHeader()) {
    my $header = <FILE>;
    print $fh $header;
  }

  while(<FILE>) {
    chomp;

    my @a = split(/\t/, $_);
    my $new = $map->{$a[0]} ? $map->{$a[0]} : 'UNKNOWN';

    $a[0] = $new;

    print $fh join("\t", @a) . "\n";
  }
  close FILE;

  return $filename;
}

#--------------------------------------------------------------------------------

sub readMappingFile {
  my ($self) = @_;

  my $mappingFile = $self->getMappingFile();
  open(MAP, $mappingFile) or CBIL::TranscriptExpression::Error->new("Cannot open file $mappingFile for reading: $!")->throw();

  if($self->hasHeader()) {
    <MAP>;
  }

  my %rv;

  while(<MAP>) {
    chomp;

    my ($unique, $nonUnique) = split(/\t/, $_);
    $rv{$unique} = $nonUnique;
  }
  close MAP;

  return \%rv;
}

#--------------------------------------------------------------------------------


sub writeRScript {
  my ($self, $file) = @_;

  my $outputFile = $self->getOutputFile();

  my $outputFileBase = basename($outputFile);
  my $rFile = "/tmp/$outputFileBase.R";

  my $header = $self->hasHeader() ? "TRUE" : "FALSE";

  open(RCODE, "> $rFile") or die "Cannot open $rFile for writing:$!";

  my $rString = <<RString;
source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/normalization_functions.R");

input = read.table("$file", header=$header, sep="\\t");

v = as.vector(input[,1]);
dat = input[,2:ncol(input)];

# Avg Rows
avg.data = averageSpottedReplicates(m=dat, nm=v, nameIsList=FALSE);

colnames(avg.data) = colnames(input);

# write data
write.table(avg.data, file="$outputFile", quote=F, sep="\\t", row.names=FALSE);
RString

  print RCODE $rString;

  close RCODE;

  return $rFile;
}


1;


