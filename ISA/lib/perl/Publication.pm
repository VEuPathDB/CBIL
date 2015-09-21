package CBIL::ISA::Publication;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setPubmedId { $_[0]->{_pubmed_id} = $_[1] }
sub getPubmedId { $_[0]->{_pubmed_id} }

sub setPublicationDoi { $_[0]->{_publication_doi} = $_[1] }
sub getPublicationDoi { $_[0]->{_publication_doi} }

sub setStatus { $_[0]->{_status} = $_[1] }
sub getStatus { $_[0]->{_status} }

sub setPublicationAuthorList { $_[0]->{_publication_author_list} = $_[1] }
sub getPublicationAuthorList { $_[0]->{_publication_author_list} }

sub setPublicationTitle { $_[0]->{_publication_title} = $_[1] }
sub getPublicationTitle { $_[0]->{_publication_title} }


sub setOntologyTerm {
  my ($self, $ot) = @_;
  $self->setStatus($ot);
}
sub getOntologyTerm { $_[0]->getStatus }




1;
