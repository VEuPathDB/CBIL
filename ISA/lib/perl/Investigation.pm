package CBIL::ISA::Investigation;
use base qw(CBIL::ISA::Study);

use strict;

use CBIL::ISA::InvestigationFileReader;
use CBIL::ISA::OntologySource;
use Data::Dumper;

my $INVESTIGATION = "INVESTIGATION";
my $ONTOLOGY_SOURCE_REFERENCE = "ONTOLOGY SOURCE REFERENCE";
my $INVESTIGATION_PUBLICATIONS = "INVESTIGATION PUBLICATIONS";
my $INVESTIGATION_CONTACTS = "INVESTIGATION CONTACTS";


sub new {
  my ($class, $investigationFile, $delimiter) = @_;

  # Reader makes a big hash of the investigation file only;  Used for making objects in the parse method
  my $iReader = CBIL::ISA::InvestigationFileReader->new($investigationFile, $delimiter); 
  $iReader->read();

  my $investigation = $iReader->getInvestigationHash()->{$INVESTIGATION};  

  my $self = $class->SUPER::new($investigation);

  $self->setInvestigationReader($iReader);
  return $self;
}

sub setInvestigationReader { $_[0]->{_investigation_reader} = $_[1] }
sub getInvestigationReader { $_[0]->{_investigation_reader} }

sub addStudy { push @{$_[0]->{_studies}}, $_[1] }
sub getStudies { $_[0]->{_studies} }

sub addOntologyTerm { push @{$_[0]->{_ontology_terms}}, $_[1] }
sub getOntologyTerms { $_[0]->{_ontology_terms} }

sub getOntologySources { $_[0]->{_ontology_sources} }
sub setOntologySources { 
  my ($self, $hash, $columnCount) = @_;
  $self->{_ontology_sources} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::OntologySource");

  return $self->getOntologySources();
}

sub parse {
  my ($self) = @_;

  my $iReader = $self->getInvestigationReader();
  my $iHash = $iReader->getInvestigationHash();
  my $iColumnCounts = $iReader->getColumnCounts();

  $self->setOntologySources($iHash->{$ONTOLOGY_SOURCE_REFERENCE}, 
                            $iColumnCounts->{$ONTOLOGY_SOURCE_REFERENCE});

  $self->setPublications($iHash->{$INVESTIGATION_PUBLICATIONS}, 
                            $iColumnCounts->{$INVESTIGATION_PUBLICATIONS});

  $self->setContacts($iHash->{$INVESTIGATION_CONTACTS}, 
                            $iColumnCounts->{$INVESTIGATION_CONTACTS});



}


1;
