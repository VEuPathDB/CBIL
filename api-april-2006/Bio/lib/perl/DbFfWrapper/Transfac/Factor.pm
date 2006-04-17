
package CBIL::Bio::DbFfWrapper::Transfac::Factor;
@ISA = qw( CBIL::Bio::DbFfWrapper::Transfac::Section );

use strict;

use CBIL::Bio::DbFfWrapper::Transfac::BoundSite;
use CBIL::Bio::DbFfWrapper::Transfac::DbRef;
use CBIL::Bio::DbFfWrapper::Transfac::Expression;
use CBIL::Bio::DbFfWrapper::Transfac::Feature;
use CBIL::Bio::DbFfWrapper::Transfac::History;
use CBIL::Bio::DbFfWrapper::Transfac::Section;
use CBIL::Bio::DbFfWrapper::Transfac::Species;

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

# ======================================================================
=pod

=head1 Attributes

=over 4

=cut

sub getId         { $_[0]->{Id} }
sub setId         { $_[0]->{Id} = $_[1]; $_[0] }

sub getAccession  { $_[0]->{Accession} }
sub setAccession  { $_[0]->{Accession} = $_[1]; $_[0] }

sub getHistory    { $_[0]->{History} }
sub setHistory    { $_[0]->{History} = $_[1]; $_[0] }
sub addHistory    { push(@{$_[0]->{History}}, $_[1]); $_[0] }

sub getName       { $_[0]->{Name} }
sub setName       { $_[0]->{Name} = $_[1]; $_[0] }

sub getSpecies    { $_[0]->{Species} }
sub setSpecies    { $_[0]->{Species} = $_[1]; $_[0] }

sub getTaxonomy   { $_[0]->{Taxonomy} }
sub setTaxonomy   { $_[0]->{Taxonomy} = $_[1]; $_[0] }
sub addTaxonomy   { push(@{$_[0]->{Taxonomy}},$_[1]); $_[0] }
sub fixTaxonomy   {
   $_[0]->{Taxonomy} = [map { lc $_ } split(/;\s+/, join(' ',@{$_[0]->{Taxonomy} || []}))];
   $_[0]
}

sub getSize       { $_[0]->{Size} }
sub setSize       { $_[0]->{Size} = $_[1]; $_[0] }

sub getMatrix     { $_[0]->{Matrix} }
sub setMatrix     { $_[0]->{Matrix} = $_[1]; $_[0] }
sub addMatrix     { push(@{$_[0]->{Matrix}},$_[1]); $_[1] }

sub getHomolog    { $_[0]->{Homolog} }
sub setHomolog    { $_[0]->{Homolog} = $_[1]; $_[0] }
sub fixHomolog     {
	 $_[0]->{Homolog} =~ s/\.$//;
   $_[0]->{Homolog} = [ split(/,\s*/, $_[0]->{Homolog})]
   if $_[0]->{Homolog};
   $_[0]
}

sub getSynonym     { $_[0]->{Synonym} }
sub setSynonym     { $_[0]->{Synonym} = $_[1]; $_[0] }
sub addSynonym     { push(@{$_[0]->{Synonym}},$_[1]); $_[1] }
sub fixSynonym     {
	 $_[0]->{Synonym} =~ s/\.$//;
   $_[0]->{Synonym} = [split(/;\s+/,
                             join(' ',@{$_[0]->{Synonym}}))
                      ] if $_[0]->{Synonym};
   $_[0]
}

sub getBoundSites { $_[0]->{BoundSites} }
sub setBoundSites { $_[0]->{BoundSites} = $_[1]; $_[0] }
sub addBoundSite  { push(@{$_[0]->{BoundSites}},$_[1]); $_[0] }

sub getClass      { $_[0]->{Class} }
sub setClass      { $_[0]->{Class} = $_[1]; $_[0] }

sub getComment    { $_[0]->{Comment} }
sub setComment    { $_[0]->{Comment} = $_[1]; $_[0] }
sub addComment    { push(@{$_[0]->{Comment}},$_[1]); $_[0] }
sub fixComment    {
   $_[0]->{Comment} = join(' ', $_[0]->{Comment}) if $_[0]->{Comment};
   $_[0]
}

sub getSequence    { $_[0]->{Sequence} }
sub setSequence    { $_[0]->{Sequence} = $_[1]; $_[0] }
sub addSequence    { push(@{$_[0]->{Sequence}},$_[1]); $_[0] }
sub fixSequence    {
	 my $Self = shift;
	 if (ref $Self->{Sequence} eq 'ARRAY') {
			$Self->{Sequence} = join('', @{$Self->{Sequence}});
	 };
   $Self
}

sub getInteraction    { $_[0]->{Interaction} }
sub setInteraction    { $_[0]->{Interaction} = $_[1]; $_[0] }
sub addInteraction    { push(@{$_[0]->{Interaction}},$_[1]); $_[0] }

sub getExpression    { $_[0]->{Expression} }
sub setExpression    { $_[0]->{Expression} = $_[1]; $_[0] }
sub addExpression    { push(@{$_[0]->{Expression}},$_[1]); $_[0] }

sub getDbRef    { $_[0]->{DbRef} }
sub setDbRef    { $_[0]->{DbRef} = $_[1]; $_[0] }
sub addDbRef    { push(@{$_[0]->{DbRef}},$_[1]); $_[0] }

sub getFunctionalFeature    { $_[0]->{FunctionalFeature} }
sub setFunctionalFeature    { $_[0]->{FunctionalFeature} = $_[1]; $_[0] }
sub addFunctionalFeature    { push(@{$_[0]->{FunctionalFeature}},$_[1]); $_[0] }
sub fixFunctionalFeature     {
   $_[0]->{FunctionalFeature} = 
   [split(/;\s+/, join(' ',@{$_[0]->{FunctionalFeature}}))]
   if $_[0]->{FunctionalFeature};
   $_[0]
}

sub getStructuralFeature    { $_[0]->{StructuralFeature} }
sub setStructuralFeature    { $_[0]->{StructuralFeature} = $_[1]; $_[0] }
sub addStructuralFeature    { push(@{$_[0]->{StructuralFeature}},$_[1]); $_[0] }
sub fixStructuralFeature     {
   $_[0]->{StructuralFeature} = 
   [split(/;\s+/, join(' ',@{$_[0]->{StructuralFeature}}))]
   if $_[0]->{StructuralFeature};
   $_[0]
}

sub getFeature    { $_[0]->{Feature} }
sub setFeature    { $_[0]->{Feature} = $_[1]; $_[0] }
sub addFeature    { push(@{$_[0]->{Feature}},$_[1]); $_[0] }
sub fixFeature {
   my $Self = shift;

   return $Self unless $Self->{Feature};

   my @features;
   my $pf;
   foreach (@{$Self->{Feature}}) {
      if ($_ =~ /                 (.+)/) {
         $pf->setDescription($pf->getDescription. " $1");
      }
      else {
         $pf = CBIL::Bio::DbFfWrapper::Transfac::Feature->new($_);
         push(@features,$pf);
      }
   }

   $Self->{Feature} = \@features;

   return $Self
}

sub getCellPositive    { $_[0]->{CellPositive} }
sub setCellPositive    { $_[0]->{CellPositive} = $_[1]; $_[0] }
sub addCellPositive    { push(@{$_[0]->{CellPositive}},$_[1]); $_[0] }

sub getCellNegative    { $_[0]->{CellNegative} }
sub setCellNegative    { $_[0]->{CellNegative} = $_[1]; $_[0] }
sub addCellNegative    { push(@{$_[0]->{CellNegative}},$_[1]); $_[0] }

sub getGenes           { $_[0]->{Genes} }
sub setGenes           { $_[0]->{Genes} = $_[1]; $_[0] }
sub addGenes {
	my $Self = shift;
	push(@{$Self->{Genes}}, @_);
	return $Self;
}

=pod

=back

=cut

# ----------------------------------------------------------------------

sub parse {
   my $Self  = shift;
   my $Lines = shift; # [string] : lines from file

	 $Self->tableParser
	 ( $Lines,

		 # ACTIONS
		 {
			AC => [ '(T\d{5})', sub { $Self->setAccession($_[1]); } ],
			ID => [ '(\S+)'   , sub { $Self->setId($_[1]);        } ],
			DT => [ '(.+)'    , sub { my $history = CBIL::Bio::DbFfWrapper::Transfac::History->new($_[1]);
																$Self->addHistory($history);
														 } ],
			FA => [ '(.+)'    , sub { $Self->setName($_[1]);      } ],
			OS => [ '(.+)\.?' , sub { $Self->setSpecies(CBIL::Bio::DbFfWrapper::Transfac::Species->new($_[1])); } ],
			OC => [ '(.+)'    , sub { my $tax = $_[1]; $tax =~ s/\.$//;
																$Self->addTaxonomy($1);
														 } ],
			CO => 1,
			SZ => [ '(.+)'    , sub { $Self->setSize($_[1]);      } ],
			CL => [ '(.+?)(;|\.)' , sub { $Self->getClass($_[1]);     } ],
			SY => [ '(.+)'    , sub { $Self->addSynonym($_[1]);   } ],
			HO => [ '(.+)'    , sub { $Self->setHomolog($_[1]);   } ],
			CC => [ '(.+)'    , sub { $Self->addComment($_[1]);   } ],
			SQ => [ '(.+)'    , sub { $Self->addSequence($_[1]);  } ],
			FF => [ '(.+)'    , sub { $Self->addFunctionalFeature($_[1]); },
							'^\s*$'   , sub {},
						],
			SF => [ '(.+)'    , sub { $Self->addStructuralFeature($_[1]); },
							'^\s*$'   , sub {},
						],
			CP => [ '(.+)'    , sub { $Self->addCellPositive($_[1]);      } ],
			CN => [ '(.+)'    , sub { $Self->addCellNegative($_[1]);      } ],
			IN => [ '(T\d{5})', sub { $Self->addInteraction($_[1]);       } ],
			BS => [ '(.+)'    , sub { $Self->addBoundSite(CBIL::Bio::DbFfWrapper::Transfac::BoundSite->new($_[1])); } ],
			FT => [ '(.+)'    , sub { $Self->addFeature($_[1]);   } ],
			DR => [ '(.+)\.'  , sub { $Self->addDbRef(CBIL::Bio::DbFfWrapper::Transfac::DbRef->new($_[1])); } ],
			MX => [ '(M\d{5})', sub { $Self->setMatrix($_[1]); } ],
			GE => [ '(G\d+)'  , sub { $Self->addGenes($_[1]); } ],
			EX => [ '(.+)'    , sub { $Self->addExpression(CBIL::Bio::DbFfWrapper::Transfac::Expression->new($_[1])); } ],
			RN => 1,
			RX => [ '(.+)',     sub { $Self->addDbRef(CBIL::Bio::DbFfWrapper::Transfac::DbRef->new($_[1])); } ],
			RA => 1,
			RT => 1,
			RL => 1,
			XX => 1,
			SC => 1,
		 },

		 # EOL WRAPS
		 { BS => [ '\.$' ],
			 FT => [ '\.$' ],
			 EX => [ '\.$' ],
		 },

		 # LA WRAPS
		 { 'BS' => 'R\d+',
			 'DR' => ':', # as in DBNAME:
			 'IN' => 'T\d+',
		 },

		 # CODE MAPS
		 {}
	 );

   $Self
   ->fixTaxonomy
   ->fixSynonym
   ->fixComment
   ->fixSequence
   ->fixHomolog
   ->fixFeature
   ->fixFunctionalFeature
   ->fixStructuralFeature
   ;

   #Disp::Display($Self);

   return $Self
}

# ----------------------------------------------------------------------

1
