#!/usr/bin/perl

# ------------------------------------------------------------------------
# PSL.pm 
#
# Routines for parsing and manipulating alignments in psLayout format
# (the output format used by BLAT.)
#
# Created: Thu Apr 25 10:16:25 EDT 2002
# 
# Jonathan Crabtree
#
# $Revision$ $Date$ $Author$
# ------------------------------------------------------------------------

package CBIL::Bio::BLAT::PSL;

use strict;
use FileHandle;

use CBIL::Bio::BLAT::Alignment;
 
# ------------------------------------------------------------------------
# Constructor
# ------------------------------------------------------------------------

sub new {
   my($class, $file) = @_;
   my $self = {};
   bless $self, $class;
   $self->readFromFile($file) if (defined($file));
   return $self;
}

# ------------------------------------------------------------------------
# Input
# ------------------------------------------------------------------------

# Read and parse a PSL-formatted file.
#
sub readFromFile {
   my($self, $file, $filters) = @_;
   my $fh = FileHandle->new();
   $fh->open($file, "r");

   my $header = undef;
   my $alignments = [];

   while (<$fh>) {
      if (/^psLayout version (\d+)/) {
         $self->{'ps_version'} = $1;
         $header = $_;

         while (<$fh>) {
            last if (/^\d/);
            $header .= $_;
         }
      }
      my $align = CBIL::Bio::BLAT::Alignment->new($_);
      if (!$filters || $filters->($align)) {
         push(@$alignments, $align);
      }
   }
   $fh->close();
   $self->{'header'} = $header;
   $self->{'alignments'} = $alignments;
}

# ------------------------------------------------------------------------
# Accessor methods
# ------------------------------------------------------------------------

sub getHeader {
   my($self) = @_;
   return $self->{'header'};
}

sub getNumAlignments {
   my($self) = @_;
   return scalar(@{$self->{'alignments'}});
}

# Retrieve alignments, optionally filtering by some criteria.
#
sub getAlignments {
   my($self, $filters) = @_;

   if ($filters) {
      my @Rv = grep { $filters->($_) } @{$self->{'alignments'}};
      return \@Rv;
   }

   else {
      return $self->{'alignments'};
   }
}

# ------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------

sub toFile {
   my($self, $fh) = @_;
   my $header = $self->{'header'};
   my $alignments = $self->{'alignments'};

   print $fh $header if (defined($header));
   foreach my $a (@$alignments) {
      print $fh $a->toString(), "\n";
   }
}

1;
