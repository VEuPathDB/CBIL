package CBIL::TranscriptExpression::DataMunger::MapIdentifiersAndAverageRows;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use CBIL::TranscriptExpression::Error;
use CBIL::TranscriptExpression::Check::ConsistentIdOrder;

use File::Temp qw/ tempfile /;
use File::Basename;

#-------------------------------------------------------------------------------

sub getDataDirPath             { $_[0]->{_data_dir_path} }
sub setDataDirPath             { $_[0]->{_data_dir_path} = $_[1] }

sub getMainDirectory           { $_[0]->{mainDirectory} }
sub setMainDirectory           { $_[0]->{mainDirectory} = $_[1] }

sub getIdColumnName            { $_[0]->{idColumnName} }

#--------------------------------------------------------------------------------

my $MAP_HAS_HEADER = 1;
my $MAP_GENE_COL = 'first';
my $MAP_OLIGO_COL = 'second';

#--------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $self = $class->SUPER::new($args);

  $self->setMappingFileHasHeader($MAP_HAS_HEADER) unless(defined $self->getMappingFileHasHeader());
  $self->setMappingFileGeneColumn($MAP_GENE_COL) unless(defined $self->getMappingFileGeneColumn());
  $self->setMappingFileOligoColumn($MAP_OLIGO_COL) unless(defined $self->getMappingFileOligoColumn());

  my $oligoColumn = $self->getMappingFileOligoColumn();
  my $geneColumn = $self->getMappingFileGeneColumn();
  my $hasHeader = $self->getMappingFileHasHeader();

  if($oligoColumn eq $geneColumn) {
    CBIL::TranscriptExpression::Error->new("oligo column cannot be the same as gene column")->throw();
  }

  unless($oligoColumn eq 'first' || $oligoColumn eq 'second') {
    CBIL::TranscriptExpression::Error->new("oligo column must equal first or second")->throw();
  }

  unless($geneColumn eq 'first' || $geneColumn eq 'second') {
    CBIL::TranscriptExpression::Error->new("gene column must equal first or second")->throw();
  }

  my $dataFiles = $self->getDataFiles();
  my $idColumnName = $self->getIdColumnName();  ##BB need $idColumnName ??
  my $mainDirectory = $self->getMainDirectory();

  my $checker = CBIL::TranscriptExpression::Check::ConsistentIdOrder->new($dataFiles, $mainDirectory, $idColumnName);
  $self->setChecker($checker);

  return $self;
}

#--------------------------------------------------------------------------------

sub munge {
  my ($self) = @_;

  my $checker = $self->getChecker();
  my $idArray = $checker->getIdArray();

  my $tmpMappingFile = $self->mappingFileForR($idArray);


  my $dataDirPath = $self->getMainDirectory();
  my $dataFile = $dataDirPath . ($self->getDataFiles())->[0]; # only 1 file


  print STDOUT "\n\n*** call to writeRScript(with $dataFile, AND $tmpMappingFile)\n";

  my $rFile = $self->writeRScript($dataFile, $tmpMappingFile);
  $self->runR($rFile);

  unlink($rFile, $tmpMappingFile);
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

## input : got from reading data file (which already should have genes mapped)
## v = as.vector(inputt[,1]);  (gene_ids column)
## dat = dat[,2:ncol(input)]   (half-life-value matrix)

sub writeRScript {
  my ($self, $dataFile,$mappingFile) = @_;

  print STDOUT "\n\n*** inside writeRScript(dataFile =$dataFile, AND mappingFile=$mappingFile\n";

  my $outputFile = $self->getOutputFile();
  my $outputFileBase = basename($outputFile);
  my $pathToDataFiles = $self->getMainDirectory();

  my ($rfh, $rFile) = tempfile();

  my $rString = <<RString;
source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/normalization_functions.R");

# reading in the mapping file; in which the 2nd coln is the gene_list...
idMap = read.table("$mappingFile", sep="\\t", header=TRUE);
v = as.vector(idMap[,2]);


dat = read.table("$dataFile", sep="\\t", header=TRUE);
dataMatrix = dat[,2:ncol(dat)];

# Avg Rows
avg.data = averageSpottedReplicates(m=dataMatrix, nm=v, nameIsList=FALSE);

colnames(avg.data) = colnames(dat);

# write data
write.table(avg.data, file="$outputFile", quote=F, sep="\\t", row.names=FALSE);
RString

  print $rfh $rString;

  close $rfh;

  return $rFile;
}

1;


