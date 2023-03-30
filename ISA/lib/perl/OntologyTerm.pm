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

sub new {
  my ($class, $args) = @_;

  my $seenTerm;

  my $self = bless {}, $class;

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


sub isMultiValued {
  my ($self) = @_;

  if($self->getTermAccessionNumber() =~ /;/) {
    return 1;
  }
  return 0;
}


sub multiValueFactory {
  my ($self) = @_;

  return $self unless($self->isMultiValued());

  my $accessions = $self->getTermAccessionNumber();
  my $sources = $self->getTermSourceRef();
  my $terms = $self->getTerm();

  my @accessions = split(/;/, $accessions);
  my @sources = split(/;/, $sources);
  my @terms = split(/;/, $terms);


  unless(scalar @sources == scalar @accessions) {
    die "Multivalued accessions must have same number of soruces for term:  " . $self->getTerm();
  }

  my @rv;
  for(my $i = 0; $i < scalar @sources; $i++) {
    my $copy = $self->clone();
    $copy->setTermAccessionNumber($accessions[$i]);
    $copy->setTermSourceRef($sources[$i]);
    $copy->setTerm($terms[$i]);

    push @rv, $copy;
  }
  return @rv;
}

sub clone {
    my $self = shift;
    my $copy = bless { %$self }, ref $self;
    return $copy;
}


# @OVERRIDE
sub getAttributeNames {
  return ["TermAccessionNumber", "TermSourceRef"];
}

# @Override
sub getValue { $_[0]->getTerm() }
sub setValue { $_[0]->setTerm($_[1]) }


1;
