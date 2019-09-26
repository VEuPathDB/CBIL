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

=head2 getDebugContext setDebugContext

Getter/setter for a string that gives an idea where the ontology term was attempted to be loaded from.
This can help debugging poorly constructed ISA-Tab.

=cut

sub setDebugContext { $_[0]->{_debug_context} = $_[1] }
sub getDebugContext { $_[0]->{_debug_context} }

sub new {
  my ($class, $args) = @_;

  my $seenTerm;

  my $self = bless {}, $class;

  $self->setDebugContext(delete $args->{_debug_context});

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
