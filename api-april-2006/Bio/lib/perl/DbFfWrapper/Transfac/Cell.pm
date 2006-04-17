
package CBIL::Bio::DbFfWrapper::Transfac::Cell;

use strict;

use CBIL::Bio::DbFfWrapper::Transfac::History;
use CBIL::Bio::DbFfWrapper::Transfac::DbRef;
use CBIL::Bio::DbFfWrapper::Transfac::Species;

# ----------------------------------------------------------------------

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

   $M->parse($A) if ref $A eq 'ARRAY';

   return $M
}

# ----------------------------------------------------------------------

sub getAccession { $_[0]->{Accession} }
sub setAccession { $_[0]->{Accession} = $_[1]; $_[0] }

sub getId        { $_[0]->{Accession} }

sub getHistory { $_[0]->{History} }
sub setHistory { $_[0]->{History} = $_[1]; $_[0] }
sub addHistory { push(@{$_[0]->{History}}, $_[1]); $_[0] }

sub getSource { $_[0]->{Source} }
sub setSource { $_[0]->{Source} = $_[1]; $_[0] }

sub getSpecies { $_[0]->{Species} }
sub setSpecies { $_[0]->{Species} = $_[1]; $_[0] }

sub getDescription { $_[0]->{Description} }
sub setDescription { $_[0]->{Description} = $_[1]; $_[0] }
sub addDescription { push(@{$_[0]->{Description}},$_[1]); $_[0] }
sub fixDescription {
   $_[0]->{Description} = join(' ', @{$_[0]->{Description}})
   if ref $_[0]->{Description} eq 'ARRAY';
   $_[0]
}

sub getDbRef    { $_[0]->{DbRef} }
sub setDbRef    { $_[0]->{DbRef} = $_[1]; $_[0] }
sub addDbRef    { push(@{$_[0]->{DbRef}},$_[1]); $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $M = shift;
   my $E = shift; # [string] : lines from file

   my $line;
   my $code;
   my $text;

   my $actions =
   {
    AC => [ '(\d{4})'         , sub { $M->setAccession($_[0]);        } ],
    DT => [ '(.+)'            , sub { my $history = CBIL::Bio::DbFfWrapper::Transfac::History
																			->new();
																			$history->parse($_[0]);
																			$M->addHistory($history);
																	 } ],
		CO => 0,
    SO => [ '(.+)'            , sub { $M->setSource($_[0]);           } ],
    CD => [ '(.+)'            , sub { $M->addDescription($_[0]);      } ],
    OS => [ '(.+)\.?'         , sub { $M->setSpecies(CBIL::Bio::DbFfWrapper::Transfac::Species
																										 ->new($_[0])); } ],
    DR => [ '(.+)(\.|;)'      , sub { $M->addDbRef(CBIL::Bio::DbFfWrapper::Transfac::DbRef
																									 ->new($_[0])); } ],
		BS => [ '(R\d{5}); (.+)\.', sub { } ],
    XX => 0,
   };

   my $map = { '\d\d' => '00' };
 
 LINE_SCAN:
   for (my $i = 0; $i < @$E; $i++) {
      $line = $E->[$i];
      $code = substr($line,0,2);
      last if $code eq '//';

      foreach my $pat (keys %$map) {
         $code = $map->{$pat} if $code =~ /$pat/;
      }

      my $act  = $actions->{$code};
      if (defined $act) {
         if ($act) {
            $text = substr($line,4);
            if ($text =~ /$act->[0]/) {
               $act->[1]->($1,$2,$3,$4,$5,$6,$7,$8,$9);
            }
            else {
               print STDERR "Poor format in Cell: '$line'\n";
            }
         }
      }
      else {
         print STDERR "Unexpected line in Cell: '$line'\n";
      }
   }

   $M
   ->fixDescription
   ;

   #Disp::Display($M);

   return $M
}

# ----------------------------------------------------------------------

1
