package CBIL::ISA::Functions;
require Exporter;
@ISA = qw(Exporter);

@EXPORT_OK = qw(makeObjectFromHash makeOntologyTerm);

use Scalar::Util 'blessed';

use strict;

use CBIL::ISA::OntologyTerm;
use Date::Parse qw/strptime/;

use File::Basename;

use Data::Dumper;

sub getOntologyMapping {$_[0]->{_ontology_mapping} }
sub getOntologySources {$_[0]->{_ontology_sources} }
sub getValueMappingFile {$_[0]->{_valueMappingFile} }

sub getValueMapping {$_[0]->{_valueMapping} }
sub setValueMapping {$_[0]->{_valueMapping} = $_[1] }

sub new {
  my ($class, $args) = @_;

  my $self = bless $args, $class;

  my $valueMappingFile = $self->getValueMappingFile();

  my $valueMapping = {};
  if($valueMappingFile) {
    open(FILE, $valueMappingFile) or die "Cannot open file $valueMappingFile for reading: $!";

    while(<FILE>) {
      chomp;

      my ($qualName, $qualSourceId, $in, $out) = split(/\t/, $_);
      $valueMapping->{$qualSourceId}->{$in} = $out;
    }
  }
  $self->setValueMapping($valueMapping);

  return $self;
}


sub valueIsMappedValue {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();
  my $qualSourceId = $obj->getQualifier();

  my $valueMapping = $self->getValueMapping();

  my $qualifierValues = $valueMapping->{$qualSourceId};

  if($qualifierValues) {
    my $newValue = $qualifierValues->{$value};

    if($newValue) {
      $obj->setValue($newValue);
    }
  }
}


sub valueIsOntologyTerm {
  my ($self, $obj) = @_;

  my $value = $obj->getValue();

  my $omType = blessed($obj) eq 'CBIL::ISA::StudyAssayEntity::Characteristic' ? 'characteristicValue' : 'protocolParameterValue';

  $value = basename $value; # strip prefix if IRI
  my ($valuePrefix) = $value =~ /^(\w+)_|:/;

  my $om = $self->getOntologyMapping();
  my $os = $self->getOntologySources();

  if($os->{lc($valuePrefix)}) {
    $obj->setTermAccessionNumber($value);
    $obj->setTermSourceRef($valuePrefix);
  }
  elsif(my $hash = $om->{lc($value)}->{$omType}) {
    my $sourceId = $hash->{source_id};
    my ($termSource) = $sourceId =~ /^(\w+)_|:/;

    $obj->setTermAccessionNumber($sourceId);
    $obj->setTermSourceRef($termSource);
  }
  else {
    die "Could not determine Accession Number for: [$value]";
  }
}

sub splitUnitFromValue {
  my ($self, $obj) = @_;

  my $om = $self->getOntologyMapping();
  my $value = $obj->getValue();

  my ($value, $unitString) = split(/\s+/, $value);
  $obj->setValue($value);

  my $class = "CBIL::ISA::StudyAssayEntity::Unit";

  my $unitSourceId = $om->{lc($unitString)}->{unit}->{source_id};
  if (defined $value) {
    unless($unitSourceId) {
      die "Could not find onotlogyTerm for Unit:  $unitString";
    }

    my $unit = &makeOntologyTerm($unitSourceId, $unitString, $class);

    $obj->setUnit($unit);
  }
  else {
    $obj->setUnit(undef);
  }
}


sub formatDate {
  my ($self, $obj) = @_;

  my $date = $obj->getValue();
  return undef unless $date;

  my  ($junk1,$junk2,$junk3,$day,$month,$year) = strptime($date);

  $month += 1;
  die "invalid month $date, $year-$month-$day " unless (0< $month &&  $month<13);
  die "invalid day for $date, $year-$month-$day " unless (0< $day &&  $day <32);
  $day = "0".$day if length($day) == 1;
  $month = "0".$month if $month <10;
  $year = $year < 16 ? $year +2000 : $year+1900;
  my $formatted_date = $year.$month.$day;
  die "date is messed up $formatted_date"  unless (length($year.$month.$day) == 8);

  $obj->setValue($formatted_date);

  return $formatted_date;
}


sub makeOntologyTerm {
  my ($sourceId, $termName, $class) = @_;

  my ($termSource) = $sourceId =~ /^(\w+)_|:/;

  $class = "CBIL::ISA::OntologyTerm" unless($class);

  my $hash = {term_source_ref => $termSource,
              term_accession_number => $sourceId,
              term => $termName
  };
  
  
  return &makeObjectFromHash($class, $hash);
  
}


sub makeObjectFromHash {
  my ($class, $hash) = @_;

  eval "require $class";
  my $obj = eval {
    $class->new($hash);
  };
  if ($@) {
    die "Unable to create class $class: $@";
  }

  return $obj;
}


1;

