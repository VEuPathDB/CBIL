# ======================================================================

package CBIL::Bio::KeggDrug::Parser::Store;

use strict;

sub new {
   my $C = shift;
   my $A = shift;

   my $m = bless {}, $C;

   $m->init($A);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $M = shift;
   my $A = shift;

   $M->setRecords($A->{Records});
   $M->setEntries($A->{Entries});

   return $M
}

# ----------------------------------------------------------------------

sub getRecords { $_[0]->{Records} || [] }
sub setRecords { $_[0]->{Records} = $_[1]; $_[0] }
sub addRecord  { push(@{$_[0]->{Records}},$_[1]); $_[0] }

sub getEntries { $_[0]->{Entries} }
sub setEntries { $_[0]->{Entries} = $_[1]; $_[0] }

sub setEntry   { $_[0]->{Entries}->{$_[1]->getId} = $_[1]; $_[0] }
sub getEntry   { $_[0]->{Entries}->{$_[1]} }

1;

