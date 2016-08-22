package CBIL::ISA::Publication;
use base qw(CBIL::ISA::Commentable);

use strict;

sub setPubmedId { $_[0]->{_pubmed_id} = $_[1] }
sub getPubmedId { $_[0]->{_pubmed_id} }

sub setPublicationDoi { $_[0]->{_publication_doi} = $_[1] }
sub getPublicationDoi { $_[0]->{_publication_doi} }

# OntologyTerm obj
sub setPublicationStatus { $_[0]->{_publication_status} = $_[1] }
sub getPublicationStatus { $_[0]->{_publication_status} }

sub setPublicationAuthorList { $_[0]->{_publication_author_list} = $_[1] }
sub getPublicationAuthorList { $_[0]->{_publication_author_list} }

sub setPublicationTitle { $_[0]->{_publication_title} = $_[1] }
sub getPublicationTitle { $_[0]->{_publication_title} }


1;
