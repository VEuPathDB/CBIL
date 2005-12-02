# ======================================================================

package CBIL::Bio::DbFfWrapper::Transfac::Parser::Store;

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

   $M->setVersion($A->{Version} || 'unknown' );
   $M->setRecords($A->{Records});
   $M->setEntries($A->{Entries});

   return $M
}

# ----------------------------------------------------------------------

sub getVersion { $_[0]->{Version} }
sub setVersion { $_[0]->{Version} = $_[1]; $_[0] }

sub getRecords { $_[0]->{Records} }
sub setRecords { $_[0]->{Records} = $_[1]; $_[0] }
sub addRecord  { push(@{$_[0]->{Records}},$_[1]); $_[0] }

sub getEntries { $_[0]->{Entries} }
sub setEntries { $_[0]->{Entries} = $_[1]; $_[0] }

sub setEntry   { $_[0]->{Entries}->{$_[1]->getId} = $_[1]; $_[0] }
sub getEntry   { $_[0]->{Entries}->{$_[1]} }

1;

