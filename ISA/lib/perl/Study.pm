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
sub getPublications { $_[0]->{_publications} }

sub setContacts { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_person_roles"];
  my $otIsList = [ 1 ];

  $self->{_contacts} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::Contact", $otRegexs, $otIsList);

  return $self->getContacts();
}
sub getContacts { $_[0]->{_contacts} }


sub setProtocols { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_protocol_type", "_protocol_parameters", "_protocol_components_type"];
  my $otIsList = [ 0, 1,1 ];
  $self->{_protocols} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::Protocol", $otRegexs, $otIsList);

  return $self->getProtocols();
}
sub getProtocols { $_[0]->{_protocols} }

sub setStudyDesigns { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_design_type"];
  my $otIsList = [ 0 ];
  $self->{_study_designs} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::StudyDesign", $otRegexs, $otIsList);

  return $self->getStudyDesigns();
}
sub getStudyDesigns { $_[0]->{_study_designs} }


sub setStudyFactors { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_factor_type"];
  my $otIsList = [ 0 ];
  $self->{_study_factors} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::StudyFactor", $otRegexs, $otIsList);

  return $self->getStudyFactors();
}
sub getStudyFactors { $_[0]->{_study_factors} }

sub setStudyAssays { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegexs = ["_assay_measurement_type", "_assay_technology_type"];
  my $otIsList = [ 0, 0 ];
  $self->{_study_assays} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::StudyAssay", $otRegexs, $otIsList);

  return $self->getStudyAssays();
}
sub getStudyAssays { $_[0]->{_study_assays} }

sub addFactorValue { push @{$_[0]->{_factor_values}}, $_[1] }
sub getFactorValues { $_[0]->{_factor_values} }

sub addNode { push @{$_[0]->{_nodes}}, $_[1] }
sub getNodes { $_[0]->{_nodes} }

sub addEdge { push @{$_[0]->{_edges}}, $_[1] }
sub getEdges { $_[0]->{_edges} }


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

1;
