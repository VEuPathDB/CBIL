# ======================================================================

package CBIL::Bio::GeneOntologyParser::Store;

use strict;

sub new {
   my $class = shift;
   my $args = shift;

   my $self = bless {}, $class;

   $self->init($args);

   return $self
}

# ----------------------------------------------------------------------

sub init {
   my $self = shift;
   my $args = shift;

   $self->setVersion($args->{Version} || 'unknown' );
   $self->setParseMethod($args->{ParseMethod});
   $self->setRecords($args->{Records});
   $self->setEntries($args->{Entries});

   return $self
}

# ----------------------------------------------------------------------

sub getVersion { $_[0]->{Version} }
sub setVersion { $_[0]->{Version} = $_[1]; $_[0] }

sub getDescription { $_[0]->{Description} }
sub setDescription { $_[0]->{Description} = $_[1]; $_[0] }

sub getReleaseDate { $_[0]->{Date} }
sub setReleaseDate { $_[0]->{Date} = $_[1]; $_[0] }


sub getRecords { $_[0]->{Records} }
sub setRecords { $_[0]->{Records} = $_[1]; $_[0] }
sub addRecord  { push(@{$_[0]->{Records}},$_[1]); $_[0] }
sub clrRecords { $_[0]->{Records} = [] }

sub getEntries { $_[0]->{Entries} }
sub setEntries { $_[0]->{Entries} = $_[1]; $_[0] }

sub addEntry   { $_[0]->{Entries}->{$_[1]->getId} = $_[1]; $_[0] }
sub getEntry   { $_[0]->{Entries}->{$_[1]} }

sub getRoot { $_[0]->{Root} }
sub setRoot { $_[0]->{Root} = $_[1]; $_[0] }

sub getBranchRoot { $_[0]->{BranchRoot} }
sub setBranchRoot { $_[0]->{BranchRoot} = $_[1]; $_[0] }

sub getParseMethod { $_[0]->{ParseMethod} }
sub setParseMethod { $_[0]->{ParseMethod} = $_[1]; $_[0] }

1;

