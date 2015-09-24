package CBIL::ISA::StudyAssayFileReader;

use strict;

use Data::Dumper;

sub setStudyAssayFile { $_[0]->{_study_assay_file} = $_[1] }
sub getStudyAssayFile { $_[0]->{_study_assay_file} }

sub getFh {$_[0]->{_fh}}
sub setFh {$_[0]->{_fh} = $_[1]}

sub setDelimiter { $_[0]->{_delimiter} = $_[1] }
sub getDelimiter { $_[0]->{_delimiter} }

sub setStudyAssayHash { $_[0]->{_study_assay_hash} = $_[1] }
sub getStudyAssayHash { $_[0]->{_study_assay_hash} }

sub setHeaderValues { $_[0]->{_header_values} = $_[1] }
sub getHeaderValues { $_[0]->{_header_values} }

sub setEntityNames { $_[0]->{_entity_names} = $_[1] }
sub getEntityNames { $_[0]->{_entity_names} }

sub setQualifierNames { $_[0]->{_qualifier_names} = $_[1] }
sub getQualifierNames { $_[0]->{_qualifier_names} }

sub new {
  my ($class, $file, $delimiter) = @_;

  my $self = bless {}, $class;

  $self->setDelimiter($delimiter);
  $self->setStudyAssayFile($file);

  my ($fh);

  open($fh, $file) or die "Cannot open file $file for reading: $!";

  $self->setFh($fh);

  my $header = $self->readNextLine();

  $self->setHeaderValues($header);

  my @entityNames;
  my @qualifierNames;

  foreach my $headerValue (@$header) {
    my ($entity, $junk, $qualifier) = $headerValue =~ m/([\w|\s]+)(\[(.+)\])?/;
    my @words = map {ucfirst(lc($_))} split(/\s+/, $entity);
    $entity = join("", @words);

    # Map Header Values to objects
    $entity =~ s/Name$//;
    $entity = "Characteristic" if($entity eq "Characteristics");
    $entity = "ProtocolApplication" if($entity eq "ProtocolRef");
    $entity = "ArrayDesignFile" if($entity eq "ArrayDesignFileRef");

    push @entityNames, $entity;
    push @qualifierNames, $qualifier;
  }

  $self->setEntityNames(\@entityNames);
  $self->setQualifierNames(\@qualifierNames);



  return $self;
}


sub readNextLine {
  my ($self) = @_;

  my $fh = $self->getFh();

  # handle empty lines or whatever
  while(!eof($fh)) {
    my $line = readline($fh);
    chomp($line);

    my $delimiter = $self->getDelimiter();
    my @a = map { s/^"(.*)"$/$1/; $_; } split($delimiter, $line);

    return(\@a);
  }

  close $fh;
  return(0);
}


sub readLineToObjects {
  my ($self) = @_;

  my @rv;

  my @headerValues = @{$self->getHeaderValues()};
  my @entityNames = @{$self->getEntityNames()};
  my @qualifierNames=  @{$self->getQualifierNames()};

  my @lineValues = $self->readNextLine();

  for(my $i = 0; $i < scalar @headerValues; $i++) {
    my $class = "CBIL::ISA::StudyAssayEntity::" . $entityNames[$i];
    my $lineValue = $lineValues[$i];



  }



  return \@rv;
}

1;
