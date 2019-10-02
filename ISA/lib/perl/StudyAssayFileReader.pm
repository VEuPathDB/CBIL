package CBIL::ISA::StudyAssayFileReader;

use strict;

use Scalar::Util qw(blessed);

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
    $entity = "ArrayDesignFile" if($entity eq "ArrayDesignRef");
    
    push @entityNames, $entity;
    push @qualifierNames, $qualifier;
  }

  $self->setEntityNames(\@entityNames);
  $self->setQualifierNames(\@qualifierNames);

  return $self;
}

sub hasNextLine {
  my ($self) =  @_;

  my $fh = $self->getFh();

  return !eof($fh);
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

  $self->closeFh();
  return(0);
}


sub closeFh {
  my $self = shift;

  my $fh = $self->getFh();
  close $fh;
}

sub readLineToObjects {
  my ($self) = @_;

  my @rv;

  my @entityNames = @{$self->getEntityNames()};
  my @qualifierNames=  @{$self->getQualifierNames()};

  my $lineValues = $self->readNextLine();

  for(my $i = 0; $i < scalar @entityNames; $i++) {
    my $class = "CBIL::ISA::StudyAssayEntity::" . $entityNames[$i];
    my $lineValue = $lineValues->[$i];

    next unless($lineValue);

    my %hash = ( "_value" => $lineValue);

    eval "require $class";
    my $obj = eval {
      $class->new(\%hash);
    };
    if ($@) {
      die "Unable to create class $class: $@";
    }

    if ($obj->can('setDebugContext')) {
      $obj->setDebugContext("Column: $i, entity: $entityNames[$i], qualifier: ".($qualifierNames[$i]||'').", value: $lineValue, file: ".$self->getStudyAssayFile());
    }

    if(my $qualifierName = $qualifierNames[$i]) {
      $obj->setQualifier($qualifierName);
    }

    my $found;
  OUTER:
    foreach my $possibleParent (reverse @rv) {
      foreach my $expectedParent (@{$obj->getParents()}) {
        $expectedParent = "CBIL::ISA::StudyAssayEntity::" . $expectedParent;

        if($possibleParent->isa($expectedParent)) {
          my $qualifierContextMethod = $obj->qualifierContextMethod();

          my $attribute = $entityNames[$i] =~ /File$/ ? "File" :$entityNames[$i];
          
          if($possibleParent->hasAttribute($attribute)) {
          
            eval {
              if($obj->hasAttributes()) {
                $possibleParent->$qualifierContextMethod($obj);
              }
              else {
                $possibleParent->$qualifierContextMethod($obj->getValue());
              }
            };
            if ($@) {
              my $parentClass = blessed($possibleParent);
              die "Unable to call $qualifierContextMethod on $parentClass.  Trying to add or set $class: $@";
            }
          }
          $found = 1;
          last OUTER;
        }
      }
    }

    if($obj->hasAttributes()) {
      push @rv, $obj;
    }
  }

  return \@rv;
}

1;
