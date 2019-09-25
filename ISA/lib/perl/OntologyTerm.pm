package CBIL::ISA::OntologyTerm;
use base qw(CBIL::ISA::StudyAssayEntity Exporter);

use strict;

use Data::Dumper;

our @EXPORT = qw(@allOntologyTerms);

our @allOntologyTerms;

sub setTerm { $_[0]->{_term} = $_[1] }
sub getTerm { $_[0]->{_term} }

sub setTermAccessionNumber { $_[0]->{_term_accession_number} = $_[1] }
sub getTermAccessionNumber { $_[0]->{_term_accession_number} }

sub setTermSourceRef { $_[0]->{_term_source_ref} = $_[1] }
sub getTermSourceRef { $_[0]->{_term_source_ref} }

=head2 get/setContext



=cut

sub setContext { $_[0]->{_context} = $_[1] }
sub getContext { $_[0]->{_context} }

sub new {
  my ($class, $args) = @_;

  my $seenTerm;

  my $self = bless {}, $class;

  $self->setContext(delete $args->{_context});

  foreach my $key (keys %$args) {
    if($key =~ /term_source_ref/) {
      $self->setTermSourceRef($args->{$key});
    }
    elsif($key =~ /term_accession_number/) {
      $self->setTermAccessionNumber($args->{$key});
    }
    else {
      $seenTerm++;
      $self->setTerm($args->{$key});
    }
  }

  unless($seenTerm == 1) {
    print STDERR Dumper $args;
    die "Unable to set term";
  }

  push @allOntologyTerms, $self;

  return $self;
}

# @OVERRIDE
sub getAttributeNames {
  return ["TermAccessionNumber", "TermSourceRef"];
}

# @Override
sub getValue { $_[0]->getTerm() }
sub setValue { $_[0]->setTerm($_[1]) }


1;
