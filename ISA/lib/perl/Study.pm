package CBIL::ISA::Study;
use base qw(CBIL::ISA::Commentable);

use strict;

use CBIL::ISA::Publication;
use CBIL::ISA::Contact;
use CBIL::ISA::OntologyTerm;
use CBIL::ISA::StudyDesign;
use CBIL::ISA::StudyFactor;
use CBIL::ISA::StudyAssay;
use CBIL::ISA::Protocol;
use CBIL::ISA::Edge;

use CBIL::ISA::StudyAssayEntity::ProtocolApplication;

use Data::Dumper;

sub setIdentifier { $_[0]->{_identifier} = $_[1] }
sub getIdentifier { $_[0]->{_identifier} }

sub setTitle { $_[0]->{_title} = $_[1] }
sub getTitle { $_[0]->{_title} }

sub setSubmissionDate { $_[0]->{_submission_date} = $_[1] }
sub getSubmissionDate { $_[0]->{_submission_date} }

sub setPublicReleaseDate { $_[0]->{_public_release_date} = $_[1] }
sub getPublicReleaseDate { $_[0]->{_public_release_date} }

sub setDescription { $_[0]->{_description} = $_[1] }
sub getDescription { $_[0]->{_description} }

sub setFileName { $_[0]->{_file_name} = $_[1] }
sub getFileName { $_[0]->{_file_name} }

sub setPublications { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_publication_status"];
  my $otIsList = [ 0 ];
  $self->{_publications} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::Publication", $otRegexs, $otIsList);

  return $self->getPublications();
}
sub getPublications { $_[0]->{_publications} || [] }
sub addPublication { push @{$_[0]->{_publications}}, $_[1] }

sub setContacts { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_person_roles"];
  my $otIsList = [ 1 ];

  $self->{_contacts} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::Contact", $otRegexs, $otIsList);

  return $self->getContacts();
}
sub getContacts { $_[0]->{_contacts}  || [] }
sub addContact { push @{$_[0]->{_contacts}}, $_[1] }

sub setProtocols { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_protocol_type", "_protocol_parameters", "_protocol_components_type"];
  my $otIsList = [ 0, 1,1 ];
  $self->{_protocols} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::Protocol", $otRegexs, $otIsList);

  return $self->getProtocols();
}
sub getProtocols { $_[0]->{_protocols}  || [] }
sub addProtocol { push @{$_[0]->{_protocols}}, $_[1] }

sub setStudyDesigns { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_design_type"];
  my $otIsList = [ 0 ];
  $self->{_study_designs} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::StudyDesign", $otRegexs, $otIsList);

  return $self->getStudyDesigns();
}
sub getStudyDesigns { $_[0]->{_study_designs}  || [] }
sub addStudyDesign { push @{$_[0]->{_study_design}}, $_[1] }

sub setStudyFactors { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_factor_type"];
  my $otIsList = [ 0 ];
  $self->{_study_factors} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::StudyFactor", $otRegexs, $otIsList);

  return $self->getStudyFactors();
}
sub getStudyFactors { $_[0]->{_study_factors}  || [] }
sub addStudyFactor { push @{$_[0]->{_study_factors}}, $_[1] }

sub setStudyAssays { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_assay_measurement_type", "_assay_technology_type"];
  my $otIsList = [ 0, 0 ];
  $self->{_study_assays} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::StudyAssay", $otRegexs, $otIsList);

  return $self->getStudyAssays();
}
sub getStudyAssays { $_[0]->{_study_assays} or [] }
sub addStudyAssay { push @{$_[0]->{_study_assays}}, $_[1] }

sub addNode { 
  my ($self, $node) = @_;

  foreach(@{$self->getNodes()}) {
    return $_ if($node->equals($_));
  }
  
  push @{$self->{_nodes}}, $node;
  return $node;
}
sub getNodes { $_[0]->{_nodes} or [] }

sub addEdge { 
  my ($self, $input, $protocolApplications, $output, $fileName) = @_;

  my $edge = CBIL::ISA::Edge->new($input, $protocolApplications, $output, $fileName);

  foreach my $existingEdge (@{$self->getEdges()}) {
    if($edge->equals($existingEdge)) {
      $existingEdge->addInput($input);
      $existingEdge->addOutput($output);
      return $existingEdge;
    }
  }

  foreach my $protocolApp (@$protocolApplications) {
    my $protocolName = $protocolApp->getValue();
    foreach my $studyProtocol (@{$self->getProtocols()}) {
      if($studyProtocol->getProtocolName() eq $protocolName) {
        $protocolApp->setProtocol($studyProtocol);
      }
    }
    die "Protocol Not defined in the investigation file for [$protocolName]" if(!$protocolApp->getProtocol() && $protocolName ne 'IMPLICIT PROTOCOL');

    foreach my $paramValue (@{$protocolApp->getParameterValues()}) {
      my $paramName = $paramValue->getQualifier();
      foreach my $protocolParam (@{$protocolApp->getProtocol()->getProtocolParameters()}) {
        if($protocolParam->getTerm() eq $paramName) {
          $paramValue->setProtocolParam($protocolParam);
        }
      }
      die "ProtocolParam [$paramName] Not defined in the investigation file for protocol [$protocolName]" unless($paramValue->getProtocolParam());
    }
  }

  push @{$self->{_edges}}, $edge; 
  return $edge;
}
sub getEdges { $_[0]->{_edges} or [] }


# Handle a chunk of the Investigation File
#  Each section is made into an object
#    OntologyEntry objects are made based on the otRegex
#    values which are semi-colon separated  are handled
sub makeStudyObjectsFromHash {
  my ($self, $hash, $columnCount, $class, $otRegexs, $otAreLists) = @_;

  my @rv;

  $otRegexs = [] unless($otRegexs);
  $otAreLists = [] unless($otAreLists);

  my @keys = keys%{$hash};
  my %otKeys;

  foreach my $otRegex (@$otRegexs) {
    my @otKeys = grep {/$otRegex/} @keys;
    push @{$otKeys{$otRegex}}, @otKeys;

    @keys = grep {!/$otRegex/} @keys;
  }

  for(my $i = 0; $i < $columnCount; $i++) {
    my %hash = map { $_ => $hash->{$_}->[$i] } @keys;

    my $obj = eval {
           $class->new(\%hash);
    };
    if ($@) {
      die "Unable to create class $class: $@";
    }

    for(my $j = 0; $j < scalar @$otRegexs; $j++) {
      my $otRegex = $otRegexs->[$j];
      my $otIsList = $otAreLists->[$j];

      my $setOrAdd = $otIsList == 1 ? "add" : "set";
      my $setterName = $setOrAdd . join("", map { ucfirst } split("_", $otRegex));

      my %initOtHash = map { $_ => $hash->{$_}->[$i] } @{$otKeys{$otRegex}};

      my %otHash;

      if($otIsList) {
        foreach my $otKey (keys %initOtHash) {
          my @values = split(";", $initOtHash{$otKey});
          for(my $k = 0; $k < scalar @values; $k++) {
            $otHash{$k}->{$otKey} = $values[$k];
          }
        }
      }
      else {
        $otHash{1} = \%initOtHash;
      }

      foreach my $n (keys %otHash) {
        my $ontologyTerm = CBIL::ISA::OntologyTerm->new($otHash{$n});
        eval {
          $obj->$setterName($ontologyTerm);

        };
        if ($@) {
          die "Unable to $setterName for class $class: $@";
        }
      }
    }
    push @rv, $obj;
  }

  return \@rv;
}


sub addNodesAndEdges {
  my ($self, $saEntities, $fileName) = @_;

  my $wasNodeContext;
  my @protocolApplications;
  my $lastNode;
  my $start;

  foreach my $entity (@$saEntities) {
    my $entityName = $entity->getEntityName();

    next unless($entity->isNode() || $entityName eq 'ProtocolApplication');

    if($entity->isNode()) {
      # add node unless it already exists.  If exists we get the ref to that object
      $entity = $self->addNode($entity);

      if($wasNodeContext) {
        print STDERR "WARNING:  Study/Assay file contained consecutive Node Columns (" . $lastNode->getEntityName() . " and " . $entity->getEntityName() . ").  Creating Edge to connect these\n";
        my $protocolApp = CBIL::ISA::StudyAssayEntity::ProtocolApplication->new({_value => 'IMPLICIT PROTOCOL'});
        push @protocolApplications, $protocolApp;
      }


      my @edgeProtocolApplications = @protocolApplications;
      $self->addEdge($lastNode, \@edgeProtocolApplications, $entity, $fileName) if($start);

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


1;

=pod

=head1 NAME

CBIL::ISA::Study - module for storing object related to a Study

=head1 SYNOPSIS

    use CBIL::ISA::Study;
    my $study = CBIL::ISA::Study->new();
    $study->setIdentifier("ID:1234");
    my $identifier = $study->getIdentifier();   


=head1 DESCRIPTION

Study Objects will be created by L<CBIL::ISA::Invstigation> module.


=head2 Composition

    CBIL::ISA::Study
        ISA CBIL::ISA::Commentable


All methods and attributes not mentioned here are
inherited from L<CBIL::ISA::Commentable>


=head2 Methods

=over 12

=item C<setIdentifier>

=item C<getIdentifier>

=item C<setTitle>

=item C<getTitle>

=item C<setSubmissionDate>

=item C<getSubmissionDate>

=item C<setPublicReleaseDate>

=item C<getPublicReleaseDate>

=item C<setDescription>

=item C<getDescription>

=item C<setFileName>

=item C<getFileName>

=item C<addPublication>

@param L<CBIL::ISA::Publication>

=item C<getPublications>

@return array of L<CBIL::ISA::Publication>

=item C<addContact>

@param L<CBIL::ISA::Contact>

=item C<getContacts>

@return array of L<CBIL::ISA::Contact>

=item C<addProtocol>

@param L<CBIL::ISA::Protocol>

=item C<getProtocols>

@return array of L<CBIL::ISA::Protocol>

=item C<addStudyDesign>

@param L<CBIL::ISA::StudyDesign>

=item C<getStudyDesigns>

@return array of L<CBIL::ISA::StudyDesign>

=item C<addStudyFactor>

@param L<CBIL::ISA::StudyFactors>

=item C<getStudyFactors>

@return array of L<CBIL::ISA::StudyFactor>

=item C<addStudyAssay>

@param L<CBIL::ISA::StudyAssay>

=item C<getStudyAssays>

@return array of L<CBIL::ISA::StudyAssay>

=item C<addNode>

@param L<CBIL::ISA::StudyAssayEntity> object of type Node onto list of Nodes.  Will not add if another Node exists w/ same Name and Value

=item C<getNodes>

@return array of L<CBIL::ISA::StudyAssayEntity> (or subclass)

=item C<addEdge>

Makes a new L<CBIL::ISA::Edge> object from input L<CBIL::ISA::StudyAssayEntity> object(s) of type Node, output L<CBIL::ISA::StudyAssayEntity> object(s) of type Node AND L<CBIL::ISA::ProtocolApplication> objects.  Use existing Edges when appropriate and add input or output.  Push a L<CBIL::ISA::Edge> Object onto array unless already exists

=item C<getEdges>

@return array of L<CBIL::ISA::Edge>

=item C<makeStudyObjectsFromHash>

This method does most of the work when creating objects from the hash made from the "i_" / investigation file.

=item C<addNodesAndEdges>

Works on one array of objects from a Study/Assay File.  Adds L<CBIL::ISA::StudyAssayEntity> Nodes, L<CBIL::ISA::Edge>

=back

=cut 
