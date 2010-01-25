package CBIL::TranscriptExpression::Check::ConsistentIdOrder;
use base qw(CBIL::TranscriptExpression::Check);

use strict;

use CBIL::TranscriptExpression::Utils;
use CBIL::TranscriptExpression::Error;

sub getMappingFile    { $_[0]->{_mapping_file} }
sub setMappingFile    { $_[0]->{_mapping_file} = $_[1] }

sub getDataDirPath     { $_[0]->{_data_dir_path} }
sub setDataDirPath     { $_[0]->{_data_dir_path} = $_[1] }

sub getDataFiles      { $_[0]->{_data_files} }
sub setDataFiles      { $_[0]->{_data_files} = $_[1] }

sub getIdColumnName   { $_[0]->{_id_column_names} }
sub setIdColumnName   { $_[0]->{_id_column_names} = $_[1] }


sub new {
  my ($class, $mappingFile, $dataFiles, $pathToDataFiles, $idColName) = @_;

  my $self = bless {}, $class;

  $self->setMappingFile($mappingFile);
  $self->setDataDirPath($pathToDataFiles);
  $self->setDataFiles($dataFiles);
  $self->setIdColumnName($idColName);

  return $self;
}


sub check {
  my ($self) = @_;

  my $del = qr/\t/;

  my $idColName = $self->getIdColumnName();
  my $mappingFile = $self->getMappingFile();

  my $dataFiles = $self->getDataFiles();
  my $dirPath = $self->getDataDirPath();

  my $mapOrder = $self->readColumn($mappingFile, $idColName, $del);

  foreach my $file (@$dataFiles) {
    my $fullFilePath = $dirPath . "/" . $file;

    my $dataFileOrder = $self->readColumn($fullFilePath, $idColName, $del);

    $self->compare($mapOrder, $dataFileOrder);
  }
  return 1;
}

sub compare {
  my ($self, $array1, $array2) = @_;

  unless(scalar @$array1 == scalar @$array2) {
    CBIL::TranscriptExpression::Error->new("Data files have different number of lines than mapping file")->throw();
  }

  for(my $i = 0; $i < scalar @$array1; $i++) {

    unless($array1->[$i] eq $array2->[$i]) {
      print STDERR $array1->[$i] . "\t" . $array2->[$i] . "\n";
      CBIL::TranscriptExpression::Error->new("Identifiers must be in the same order in the mapping file as in data files")->throw();
    }
  }
}

sub readColumn {
  my ($self, $file, $colName, $del) = @_;

  my @res;

  open(FILE, $file) or die "Cannot open file $file for reading: $!";

  my $header = <FILE>;
  chomp($header);

  my $headerIndexHash = CBIL::TranscriptExpression::Utils::headerIndexHashRef($header, $del);

  my $idIndex = $headerIndexHash->{$colName};

  while(<FILE>) {
    chomp;

    my @a = split($del, $_);

    my $value = $a[$idIndex];

    push @res, $value;
  }

  close FILE;

  return \@res;
}



1;
