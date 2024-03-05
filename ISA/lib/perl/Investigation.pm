package CBIL::ISA::Investigation;
use base qw(CBIL::ISA::Study);

use strict;
use Scalar::Util 'blessed';
use feature 'say';

use CBIL::ISA::InvestigationFileReader;
use CBIL::ISA::StudyAssayFileReader;

use CBIL::ISA::OntologySource;
use CBIL::ISA::Study;
use CBIL::ISA::StudyDesign;

use CBIL::ISA::Protocol;
use CBIL::ISA::StudyAssayEntity::ProtocolApplication;

use CBIL::ISA::OntologyTerm qw(@allOntologyTerms);

use Carp;
use Digest::MD5 qw(md5_hex);
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


sub setRowLimit {$_[0]->{_row_limit} = $_[1]}
sub getRowLimit {$_[0]->{_row_limit} }

sub new {
  my ($class, $investigationFile, $investigationDirectory, $delimiter) = @_;
  $delimiter //= "\t";

  @allOntologyTerms = ();

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

  $self->setOntologyAccessionsHash({});

  $self->setRowLimit(500);

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

sub setOnError { $_[0]->{_on_error} = $_[1] }
sub handleError {
  my ($self, $error) = @_;
  if ($self->{_on_error}){
    $self->{_on_error}->($error);
  } else {
    confess $error;
  }
}
sub setOnLog { $_[0]->{_on_log} = $_[1] }
sub log {
  my ($self, @args) = @_;
  if ($self->{_on_log}){
    $self->{_on_log}->(@args);
  } else {
    say @args;
  }
}
sub logOnce {
  my ($self, $msg) = @_;
  my $cksum = md5_hex($msg);
  unless($self->{_log_once}->{$cksum}){
    say $msg;
    $self->{_log_once}->{$cksum} = 1;
  }
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


sub parseInvestigation {
  my ($self) = @_;

  my $iReader = $self->getInvestigationReader();
  my $iHash = $iReader->getInvestigationHash();
  my $iColumnCounts = $iReader->getColumnCounts();



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

    $study->setHasMoreData(1);

    $self->addStudy($study);

    my $studyFileName = $investigationDirectory . "/" . $study->getFileName();
    $study->setFileName($studyFileName);
  }

  $self->dealWithAllOntologies();
}

sub getStudyAssayFileReader {
  my ($self, $fileName, $delimiter, $studyAssay) = @_;

  if(my $fileReader = $self->{_study_assay_file_readers}->{$fileName}) {
    return $fileReader;
  }
  my $fileReader = CBIL::ISA::StudyAssayFileReader->new($fileName, $delimiter, $studyAssay);

  $self->{_study_assay_file_readers}->{$fileName} = $fileReader;
  return $fileReader;
}

sub parseStudy {
  my ($self, $study) = @_;

  my $delimiter = $self->getDelimiter();
  my $investigationDirectory = $self->getInvestigationDirectory();

  my $studyFileName = $study->getFileName();


  my $studyFileReader = $self->getStudyAssayFileReader($studyFileName, $delimiter, undef);

  my $rowLimit = $self->getRowLimit();
  my $rowCount = 0;


  @allOntologyTerms = ();
  $study->{_nodes} = [];
  $study->{_edges} = [];

  while($studyFileReader->hasNextLine()) {
    $self->addNodesAndEdgesToStudy($study, $studyFileReader->readLineToObjects());
    $rowCount++;
    
    if($rowCount == $rowLimit) {

      $self->dealWithAllOntologies();
      return;
    }
  }
  
  my $studyAssays = $study->getStudyAssays();

  foreach my $assay (@$studyAssays) {
    next unless($assay->getAssayFileName());

    my $assayFileName = $investigationDirectory . "/" . $assay->getAssayFileName();
    
    my $assayFileReader = $self->getStudyAssayFileReader($assayFileName, $delimiter, $assay);

    while($assayFileReader->hasNextLine()) {
      $self->addNodesAndEdgesToStudy($study, $assayFileReader->readLineToObjects());
      $rowCount++;

      if($rowCount == $rowLimit) {

        $self->dealWithAllOntologies();
       return;
      }
    }

  }

  foreach my $f (keys %{$self->{_study_assay_file_readers}}) {
    my $safr = $self->getStudyAssayFileReader($f);
    close $safr->getFh();
  }


  $self->dealWithAllOntologies();
  $study->setHasMoreData(0);
}


sub addNodesAndEdgesToStudy {
  my ($self, $study, $saEntities) = @_;

  my $wasNodeContext;
  my @protocolApplications;
  my $lastNode;
  my $start;

  foreach my $entity (@$saEntities) {
    my $entityName = $entity->getEntityName();

    next unless($entity->isNode() || $entityName eq 'ProtocolApplication');

    if($entity->isNode()) {
      # add node unless it already exists.  If exists we get the ref to that object
      $entity = $study->addNode($entity);

      if($wasNodeContext) {
        $self->log("WARNING:  Study/Assay file contained consecutive Node Columns (" . $lastNode->getEntityName() . " and " . $entity->getEntityName() . ").  Creating Edge to connect these\n");

        my $implicitProtocolString = $lastNode->getEntityName() . "to" . $entity->getEntityName();
        my $protocol = CBIL::ISA::Protocol->new({_value => 'IMPLICIT PROTOCOL', _protocol_name => $implicitProtocolString });
        my $protocolApp = CBIL::ISA::StudyAssayEntity::ProtocolApplication->new({_value => 'IMPLICIT PROTOCOL'});
        $protocolApp->setProtocol($protocol);
        push @protocolApplications, $protocolApp;
      }


      my @edgeProtocolApplications = @protocolApplications;
      $study->addEdge($lastNode, \@edgeProtocolApplications, $entity) if($start);

      $lastNode = $entity;
      @protocolApplications = ();
    }
    else {
      push @protocolApplications, $entity;
    }

    $start = 1;
    $wasNodeContext = $entity->isNode();
  }
}

sub dealWithAllOntologies {
  my ($self) = @_;

  my $ontologyTerms = $self->getOntologyAccessionsHash();


  foreach my $ontologyTerm(@allOntologyTerms) {
    my $hasAccession = defined $ontologyTerm->getTermAccessionNumber();

    if($hasAccession) {
      if($ontologyTerm->isMultiValued()) {
        foreach my $clone ($ontologyTerm->multiValueFactory()) {
          $ontologyTerms->{$clone->getTermSourceRef()}->{$clone->getTermAccessionNumber()}++;
        }
      }
      else {
        $ontologyTerms->{$ontologyTerm->getTermSourceRef()}->{$ontologyTerm->getTermAccessionNumber()}++;
      }
    }

    # Characteristic Qualifiers are a special case.  Their term/accession/source is not defined in the investigation file
    if(blessed($ontologyTerm) eq 'CBIL::ISA::StudyAssayEntity::Characteristic' || blessed($ontologyTerm) eq 'CBIL::ISA::StudyAssayEntity::ParameterValue') {
      $ontologyTerms->{"QUALIFIER"}->{$ontologyTerm->getQualifier()}++;

#      print $ontologyTerm->getQualifier() . "\t" . $ontologyTerm->getQualifier() . "\n";
    }

    my $accession = $ontologyTerm->getTermAccessionNumber();
    my $source = $ontologyTerm->getTermSourceRef();
    my $term = $ontologyTerm->getTerm();


    if($accession && !$source) {
      $self->log("BLESSED=" . blessed($ontologyTerm));
      $self->log(Dumper($ontologyTerm));
      $self->handleError("OntologyTerm $term is required to have source when accession is defined.");

    }

    unless(($accession && $source) || blessed($ontologyTerm) eq 'CBIL::ISA::StudyAssayEntity::Characteristic' || blessed($ontologyTerm) eq 'CBIL::ISA::StudyAssayEntity::ParameterValue') {
#      carp "OntologyTerm $term is required to have accession and source."
          # TODO:  not sure where this is from 
      $self->log("BLESSED=" . blessed($ontologyTerm));
      $self->log(Dumper($ontologyTerm));
      $self->handleError("OntologyTerm $term is required to have accession and source.");

    }

#    print "$accession\t$term\n" if($accession);
  }
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


