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

sub new {
  my ($class, $args) = @_;
  return bless $args, $class;
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

