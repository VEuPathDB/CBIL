
package CBIL::Bio::DbFfWrapper::Transfac::Matrix;
@ISA = qw( CBIL::Bio::DbFfWrapper::Transfac::Section );

use strict;

use CBIL::Bio::DbFfWrapper::Transfac::Section;
use CBIL::Bio::DbFfWrapper::Transfac::History;
use CBIL::Bio::DbFfWrapper::Transfac::BoundSite;
use CBIL::Bio::DbFfWrapper::Transfac::ObservedCounts;

# ----------------------------------------------------------------------

sub new {
   my $C = shift;
   my $Args = shift;

   my $m = bless {}, $C;

   $m->init($Args);

   return $m
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->parse($Args) if ref $Args eq 'ARRAY';

   return $Self
}

# ----------------------------------------------------------------------

sub getId { $_[0]->{Id} }
sub setId { $_[0]->{Id} = $_[1]; $_[0] }

sub getAccession { $_[0]->{Accession} }
sub setAccession { $_[0]->{Accession} = $_[1]; $_[0] }

sub getHistory { $_[0]->{History} }
sub setHistory { $_[0]->{History} = $_[1]; $_[0] }
sub addHistory { push(@{$_[0]->{History}}, $_[1]); $_[0] }

sub getName { $_[0]->{Name} }
sub setName { $_[0]->{Name} = $_[1]; $_[0] }

sub getDesignation { $_[0]->{Designation} }
sub setDesignation { $_[0]->{Designation} = $_[1]; $_[0] }

sub getBoundFactors { $_[0]->{BoundFactors} }
sub setBoundFactors { $_[0]->{BoundFactors} = $_[1]; $_[0] }
sub addBoundFactor  { push(@{$_[0]->{BoundFactors}},$_[1]); $_[0] }

sub getMatrix     { $_[0]->{Matrix} }
sub setMatrix     { $_[0]->{Matrix} = $_[1]; $_[0] }

sub getBasis      { $_[0]->{Basis} }
sub setBasis      { $_[0]->{Basis} = $_[1]; $_[0] }
sub addBasis      { push(@{$_[0]->{Basis}},$_[1]); $_[0] }

sub getComment    { $_[0]->{Comment} }
sub setComment    { $_[0]->{Comment} = $_[1]; $_[0] }
sub addComment    { push(@{$_[0]->{Comment}},$_[1]); $_[0] }

sub getBoundSites { $_[0]->{BoundSites} }
sub setBoundSites { $_[0]->{BoundSites} = $_[1]; $_[0] }
sub addBoundSite  { push(@{$_[0]->{BoundSites}},$_[1]); $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self = shift;
   my $Lines = shift; # [string] : lines from file

	 $Self->tableParser
	 ( $Lines,

		 #ACTIONS
		 {
			AC   => [ '(M\d{5})', sub { $Self->setAccession($_[1]);        } ],
			ID   => [ '(\S+)'   , sub { $Self->setId($_[1]);               } ],
			DT   => [ '(.+)'    , sub { $Self->addHistory(CBIL::Bio::DbFfWrapper::Transfac::History->new($_[1])); } ],
			NA   => [ '(.+)'    , sub { $Self->setName($_[1]);             } ],
			DE   => [ '(.+)'    , sub { $Self->setDesignation($_[1]);      } ],
			CC   => [ '(.+)'    , sub { $Self->addComment($_[1]);          } ],
			BS   => [ '(.+)'    , sub { $Self->addBoundSite(CBIL::Bio::DbFfWrapper::Transfac::BoundSite->new($_[1])); } ],
			BF   => [ '(T\d{5})', sub { $Self->addBoundFactor($_[1]);      } ],
			P0   => [ '(.+)'    , sub { $Self->setMatrix(CBIL::Bio::DbFfWrapper::Transfac::ObservedCounts->new("$_[0]  $_[1]")); } ],
			'00' => [ '(.+)'    , sub { $Self->getMatrix->parse("$_[0]  $_[1]"); } ],
			BA   => [ '(.+)'    , sub { $Self->addBasis($_[1]);            } ],

			CO   => 1,

			RN   => 1,
			RX   => 1,
			RA   => 1,
			RT   => 1,
			RL   => 1,
			XX   => 1,
		 },

		 # EOL WRAPS
		 { BF => [ '\.$' ],
		 },

		 # LA WRAPS
		 {},

		 # CODE MAPS
		 { '\d\d' => '00' }
	 );

   return $Self
}

# ----------------------------------------------------------------------

1
