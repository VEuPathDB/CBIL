package CBIL::ISA::Study;
use base qw(CBIL::ISA::Commentable);

use strict;

use CBIL::ISA::Publication;
use CBIL::ISA::Contact;
use CBIL::ISA::OntologyTerm;

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

  my $otRegex = qr/_publication_status/;
  $self->{_publications} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::Publication", $otRegex);

  return $self->getPublications();
}
sub getPublications { $_[0]->{_publications} }

sub setContacts { 
  my ($self, $hash, $columnCount) = @_;

  my $otRegex = qr/_person_roles/;
  $self->{_contacts} = $self->makeStudyObjectsFromHash($hash, $columnCount, "CBIL::ISA::Contact", $otRegex);

  return $self->getContacts();
}
sub getContacts { $_[0]->{_contacts} }

sub addProtocol { push @{$_[0]->{_protocols}}, $_[1] }
sub getProtocols { $_[0]->{_protocols} }

sub addStudyDesign { push @{$_[0]->{_study_designs}}, $_[1] }
sub getStudyDesigns { $_[0]->{_study_designs} }

sub addStudyFactor { push @{$_[0]->{_study_factors}}, $_[1] }
sub getStudyFactors { $_[0]->{_study_factors} }

sub setStudyFile { $_[0]->{_study_file} = $_[1] }
sub getStudyFile { $_[0]->{_study_file} }

sub addAssayFile { push @{$_[0]->{_assay_files}}, $_[1] }
sub getAssayFiles { $_[0]->{_assay_files} }

sub addFactorValue { push @{$_[0]->{_factor_values}}, $_[1] }
sub getFactorValues { $_[0]->{_factor_values} }

sub addNode { push @{$_[0]->{_nodes}}, $_[1] }
sub getNodes { $_[0]->{_nodes} }

sub addEdge { push @{$_[0]->{_edges}}, $_[1] }
sub getEdges { $_[0]->{_edges} }



sub makeStudyObjectsFromHash {
  my ($self, $hash, $columnCount, $class, $otRegex) = @_;

  my @rv;

  my @keys = keys%{$hash};

  my @otKeys;
  if($otRegex) {
    @keys = grep {!/$otRegex/} keys%{$hash};
    @otKeys = grep {/$otRegex/} keys%{$hash};
  }

  for(my $i = 0; $i < $columnCount; $i++) {
    my %hash = map { $_ => $hash->{$_}->[$i] } @keys;

    my $obj = eval {
           $class->new(\%hash);
    };
    if ($@) {
      die "Unable to create class $class: $@";
    }

    if($otRegex) {
      my %otHash = map { $_ => $hash->{$_}->[$i] } @otKeys;
      my $ontologyTerm = CBIL::ISA::OntologyTerm->new(\%otHash);
      $obj->setOntologyTerm($ontologyTerm);
    }

    push @rv, $obj;
  }

  return \@rv;
}

1;
