package CBIL::ISA::Investigation;
use base qw(CBIL::ISA::Study);

use strict;
use Scalar::Util 'blessed';

use CBIL::ISA::InvestigationFileReader;
use CBIL::ISA::StudyAssayFileReader;

use CBIL::ISA::OntologySource;
use CBIL::ISA::Study;
use CBIL::ISA::StudyDesign;

use CBIL::ISA::OntologyTerm qw(@allOntologyTerms);

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
  my ($class, $investigationFile, $investigationDirectory, $delimiter) = @_;

  my $investigationFileFullPath = "$investigationDirectory/$investigationFile";

  # Reader makes a big hash of the investigation file only;  Used for making objects in the parse method
  my $iReader = CBIL::ISA::InvestigationFileReader->new($investigationFileFullPath, $delimiter); 
  $iReader->read();

  my $initInvestigationHash = $iReader->getInvestigationHash()->{$INVESTIGATION};  

  # the values of this hash are arrays.  Just want the first element for these
  my %investigationHash = map { $_ => $initInvestigationHash->{$_}->[0] } keys %$initInvestigationHash;

  my $self = $class->SUPER::new(\%investigationHash);

  $self->setInvestigationReader($iReader);
  $self->setInvestigationDirectory($investigationDirectory);
  $self->setDelimiter($delimiter);

  return $self;
}

sub setOntologyAccessionsHash { $_[0]->{_ontology_accessions} = $_[1] }
sub getOntologyAccessionsHash { $_[0]->{_ontology_accessions} }

sub setDelimiter { $_[0]->{_delimiter} = $_[1] }
sub getDelimiter { $_[0]->{_delimiter} }

sub setInvestigationReader { $_[0]->{_investigation_reader} = $_[1] }
sub getInvestigationReader { $_[0]->{_investigation_reader} }

sub setInvestigationDirectory { $_[0]->{_investigation_directory} = $_[1] }
sub getInvestigationDirectory { $_[0]->{_investigation_directory} }

sub addStudy { push @{$_[0]->{_studies}}, $_[1] }
sub getStudies { $_[0]->{_studies}  || [] }

sub getOntologySources { $_[0]->{_ontology_sources} }
sub setOntologySources { 
  my ($self, $hash, $columnCount) = @_;
  $self->{_ontology_sources} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::OntologySource");

  return $self->getOntologySources();
}

sub makeStudy {
  my ($self, $hash, $columnCounts) = @_;

  my %studyHash = map { $_ => $hash->{$STUDY}->{$_}->[0] } keys %{$hash->{$STUDY}};

  my $study = CBIL::ISA::Study->new(\%studyHash);

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

  return $study;
}

sub parse {
  my ($self) = @_;

  my $iReader = $self->getInvestigationReader();
  my $iHash = $iReader->getInvestigationHash();
  my $iColumnCounts = $iReader->getColumnCounts();

  my $delimiter = $self->getDelimiter();

  my $investigationDirectory = $self->getInvestigationDirectory();

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

    my $studyFileName = $investigationDirectory . "/" . $study->getFileName();

    my $studyFileReader = CBIL::ISA::StudyAssayFileReader->new($studyFileName, $delimiter);


    while($studyFileReader->hasNextLine()) {
      my $studyObjects = $studyFileReader->readLineToObjects();
      $study->addNodesAndEdges($studyObjects, $studyFileName);
    }
    $studyFileReader->closeFh();


    my $studyAssays = $study->getStudyAssays();
    foreach my $assay (@$studyAssays) {
      my $assayFileName = $investigationDirectory . "/" . $assay->getAssayFileName();
      
      my $assayFileReader = CBIL::ISA::StudyAssayFileReader->new($assayFileName, $delimiter);

      while($assayFileReader->hasNextLine()) {
        my $assayObjects = $assayFileReader->readLineToObjects();
        $study->addNodesAndEdges($assayObjects, $assayFileName);
      }
      $assayFileReader->closeFh();
    }
  }

  my %ontologyTerms;
  foreach my $ontologyTerm(@allOntologyTerms) {
    if(blessed($ontologyTerm) eq 'CBIL::ISA::StudyAssayEntity::Characteristic' || 
       blessed($ontologyTerm) eq 'CBIL::ISA::StudyAssayEntity::ParameterValue' || 
       blessed($ontologyTerm) eq 'CBIL::ISA::StudyAssayEntity::FactorValue' ) {

      unless($ontologyTerm->getTermAccessionNumber()) {
        $ontologyTerms{"QUALIFIER"}->{$ontologyTerm->getQualifier()}++;
      }
    }

    next unless $ontologyTerm->getTermAccessionNumber();
    $ontologyTerms{$ontologyTerm->getTermSourceRef()}->{$ontologyTerm->getTermAccessionNumber()}++;
  }

  $self->setOntologyAccessionsHash(\%ontologyTerms);

}

1;

=pod

=head1 NAME

CBIL::ISA::Investigation - module for parsing ISA Tab files

=head1 SYNOPSIS

    use CBIL::ISA::Investigation;
    my $investigation = CBIL::ISA::Investigation->new($i_file, $directory, $delimiter);
    $investigation->parse();

    my $ontologySources = $investigation->getOntologySources();
    my $publications = $investigation->getPublications();
    my $title = $investigation->getTitle();
    ....


    my $studies = $investigation->getStudies();
    foreach my $study (@$studies) {
        my $studyTitle = $study->getTitle();
        my $studyPublications = $study->getPublications();
        ....
        my $nodes = $study->getNodes();
        my $edges = $study->getEdges();
    }


=head1 DESCRIPTION

This module reads creates readers for an investigation, study, and assay files
and translates into value objects.


=head2 Composition

    CBIL::ISA::Investigation
        ISA CBIL::ISA::Study


All methods and attributes not mentioned here are
inherited from L<CBIL::ISA::Study>


=head2 Methods

=over 12

=item C<getStudies>

Returns an array of CBIL::ISA::Study objects

=item C<getOntologySources>

Returns an array of CBIL::ISA::OntologySource objects


=back

=cut 


