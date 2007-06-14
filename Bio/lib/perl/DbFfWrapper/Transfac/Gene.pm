
package CBIL::Bio::DbFfWrapper::Transfac::Gene;
@ISA = qw( CBIL::Bio::DbFfWrapper::Transfac::Section );

use strict;

use CBIL::Util::Disp;

use CBIL::Bio::DbFfWrapper::Transfac::Section;
use CBIL::Bio::DbFfWrapper::Transfac::History;
use CBIL::Bio::DbFfWrapper::Transfac::BindingSite;

# ----------------------------------------------------------------------

use constant ConstDebugFlag => 0;

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

sub getAccession    { $_[0]->{Accession} }
sub setAccession    { $_[0]->{Accession} = $_[1]; $_[0] }

sub getId           { $_[0]->{Id} }
sub setId           { $_[0]->{Id} = $_[1]; $_[0] }

sub getHistory      { $_[0]->{History} }
sub setHistory      { $_[0]->{History} = $_[1]; $_[0] }
sub addHistory      { push(@{$_[0]->{History}}, $_[1]); $_[0] }

sub getSpecies      { $_[0]->{Species} }
sub setSpecies      { $_[0]->{Species} = $_[1]; $_[0] }

sub getName         { $_[0]->{Name} }
sub setName         { $_[0]->{Name} = $_[1]; $_[0] }

sub getDesignation  { $_[0]->{Designation} }
sub setDesignation  { $_[0]->{Designation} = $_[1]; $_[0] }

sub getSynonyms     { $_[0]->{Synonyms} }
sub setSynonyms     { $_[0]->{Synonyms} = $_[1]; $_[0] }
sub addSynonyms     {
	 my $Self = shift;
	 push(@{$Self->{Synonyms}}, @_);
	 return $Self;
}

sub getTaxonomy     { $_[0]->{Taxonomy} }
sub setTaxonomy     { $_[0]->{Taxonomy} = $_[1]; $_[0] }
sub addTaxonomy     { push(@{$_[0]->{Taxonomy}},$_[1]); $_[0] }
sub fixTaxonomy     {
   $_[0]->{Taxonomy} = 
   [map { lc $_ } split(/;\s+/, join(' ',@{$_[0]->{Taxonomy}}))]
   if $_[0]->{Taxonomy};
   $_[0]
}

sub getBucherClass  { $_[0]->{BucherClass} }
sub setBucherClass  { $_[0]->{BucherClass} = $_[1]; $_[0] }

sub getBindingSites { $_[0]->{BindingSites} }
sub setBindingSites { $_[0]->{BindingSites} = $_[1]; $_[0] }
sub addBindingSite  { push(@{$_[0]->{BindingSites}},$_[1]); $_[0] }

sub getTrrdId { $_[0]->{TrrdId} }
sub setTrrdId { $_[0]->{TrrdId} = $_[1]; $_[0] }

sub getCompelId { $_[0]->{CompelId} }
sub setCompelId { $_[0]->{CompelId} = $_[1]; $_[0] }

sub getDbRefs    { $_[0]->{DbRefs} || [] }
sub setDbRefs    { $_[0]->{DbRefs} = $_[1]; $_[0] }
sub addDbRefs    { push(@{$_[0]->{DbRefs}},$_[1]); $_[0] }

sub getChromosome { $_[0]->{Chromosome} }
sub setChromosome { $_[0]->{Chromosome} = $_[1]; $_[0] }

sub getFactor { $_[0]->{Factor} }
sub setFactor { $_[0]->{Factor} = $_[1]; $_[0] }

sub getRegulation { $_[0]->{Regulation} }
sub setRegulation { $_[0]->{Regulation} = $_[1]; $_[0] }
sub addRegulation { $_[0]->{Regulation} .= $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self  = shift;
   my $Lines = shift; # [string] : lines from file

   $Self->tableParser
   ($Lines,

    # ACTIONS
    {
     AC   => [ '(G\d{6})'  , sub { $Self->setAccession($_[1]);        } ],

     ID   => [ '(\S+)'     , sub { $Self->setId($_[1]);               } ],

     DT   => [ '(.+)'      , sub { my $history = CBIL::Bio::DbFfWrapper::Transfac::History->new($_[1]);
                                   $Self->addHistory($history);
                                } ],

     SD   => [ '(.+)'      , sub { $Self->setName($_[1]);             } ],

     DE   => [ '(.+)'      , sub { $Self->setDesignation($_[1]);      } ],

     OS   => [ '(.+)\.?'   , sub { $Self->setSpecies
                                   (CBIL::Bio::DbFfWrapper::Transfac::Species->new($_[1]));
                                } ],

     OC   => [ '(.+)'      , sub { my $tax = $_[1]; $tax =~ s/\.$//;
                                   $Self->addTaxonomy($1);
                                } ],

     BS   => [ '(.+)'      , sub { $Self->addBindingSite
                                   (CBIL::Bio::DbFfWrapper::Transfac::BindingSite->new($_[1]));
                                } ],

     BC   => [ '(.+)'      , sub { $Self->setBucherClass($_[1]) } ],

     TR   => [ '(\d+)'     , sub { $Self->setTrrdId($_[1]) } ],

     FA   => [ '(T\d+)'    , sub { $Self->setFactor($_[1]) } ],

     CH   => [ '(.+)'      , sub { $Self->getChromosome($_[1]) } ],

     CO   => [ 'Copyright' , sub { },
               '(\d+)'     , sub { $Self->setCompelId($_[1]) },
             ],

     CE   => [ 'TRANSCOMPEL: (C\d+)' , sub { $Self->setCompelId($_[1]) },
               '(\d+)'               , sub { $Self->setCompelId($_[1]) } ],

     DR   => [ '(.+)'       , sub { $Self->addDbRefs
                                    (CBIL::Bio::DbFfWrapper::Transfac::DbRef->new($_[1]));
                                 } ],

     SY   => [ '(.+)(\.|;)' , sub { $Self->addSynonyms(split(/;\s*/, $_[1])); } ],

     RG   => [ '(.+)'       , sub { $Self->addRegulation($_[1]) } ],

     RN => 1,
     RX => 1,
     RA => 1,
     RT => 1,
     RL => 1,
     XX => 1,

     # new in v10.2
     AS => 1, # TBD
     BR => 1, # TBD
    },

    # END OF LINE WRAPS
    { SY  => [ '\.$' ],
      BS  => [ '\.$' ],
    },

    # LOOK AHEAD WRAPS
    { BF  => 'T\d+',
    },

    # MAPS
    { '\d\d' => '00',
    },
   );

   # CLEAN UP PHASE
   # ..................................................

   $Self
   ->fixTaxonomy
   ;

   ConstDebugFlag && Disp::Display($Self);

   return $Self
}

# ----------------------------------------------------------------------

1;

