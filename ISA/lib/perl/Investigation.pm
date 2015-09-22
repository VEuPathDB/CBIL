package CBIL::ISA::Investigation;
use base qw(CBIL::ISA::Study);

use strict;

use CBIL::ISA::InvestigationFileReader;
use CBIL::ISA::OntologySource;
use CBIL::ISA::Study;
use CBIL::ISA::StudyDesign;

use Data::Dumper;

my $INVESTIGATION = "INVESTIGATION";
my $ONTOLOGY_SOURCE_REFERENCE = "ONTOLOGY SOURCE REFERENCE";
my $INVESTIGATION_PUBLICATIONS = "INVESTIGATION PUBLICATIONS";
my $INVESTIGATION_CONTACTS = "INVESTIGATION CONTACTS";
my $STUDY = "STUDY";
my $STUDY_CONTACTS = "STUDY CONTACTS";
my $STUDY_DESIGN_DESCRIPTORS = "STUDY DESIGN DESCRIPTORS";
my $STUDY_PROTOCOLS = "STUDY PROTOCOLS";
my $STUDY_FACTORS = "STUDY FACTORS";
my $STUDY_PUBLICATIONS = "STUDY PUBLICATIONS";
my $STUDY_ASSAYS = "STUDY ASSAYS";

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

#sub addOntologyTerm { push @{$_[0]->{_ontology_terms}}, $_[1] }
#sub getOntologyTerms { $_[0]->{_ontology_terms} }

sub getOntologySources { $_[0]->{_ontology_sources} }
sub setOntologySources { 
  my ($self, $hash, $columnCount) = @_;
  $self->{_ontology_sources} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::OntologySource");

  return $self->getOntologySources();
}

sub makeStudy {
  my ($self, $hash, $columnCounts) = @_;

  my $study = CBIL::ISA::Study->new($hash->{$STUDY});

  $study->setContacts($hash->{$STUDY_CONTACTS}, 
                            $columnCounts->{$STUDY_CONTACTS});

  $study->setPublications($hash->{$STUDY_PUBLICATIONS}, 
                            $columnCounts->{$STUDY_PUBLICATIONS});

  $study->setStudyDesigns($hash->{$STUDY_DESIGN_DESCRIPTORS}, 
                            $columnCounts->{$STUDY_DESIGN_DESCRIPTORS});

  $study->setStudyFactors($hash->{$STUDY_FACTORS}, 
                            $columnCounts->{$STUDY_FACTORS});

  $study->setStudyAssays($hash->{$STUDY_ASSAYS}, 
                         $columnCounts->{$STUDY_ASSAYS});

  $study->setProtocols($hash->{$STUDY_PROTOCOLS}, 
                         $columnCounts->{$STUDY_PROTOCOLS});


  print Dumper $study;
  exit;

  
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


  # "_studies" key is internal and set by the Reader
  foreach my $studyId (keys %{$iHash->{"_studies"}}) {
    my $studyHash = $iHash->{"_studies"}->{$studyId};
    my $studyColumnCounts = $iColumnCounts->{"_studies"}->{$studyId};

    my $study = $self->makeStudy($studyHash, $studyColumnCounts);
    $self->addStudy($study);
  }




}


1;
