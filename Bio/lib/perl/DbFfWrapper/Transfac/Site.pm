
package CBIL::Bio::DbFfWrapper::Transfac::Site;
@ISA = qw( CBIL::Bio::DbFfWrapper::Transfac::Section );

=pod

=head1 Purpose

To provide an object for a TRANSFAC site record and to parse such
records to set the attributes of the object.

=head1 To Do

Here is a list of things that are known to be 'wrong' with this package.

=over 4

=item *

The C<BF> line parsing does not take into account trailing lines which
happen often.  It appears however that there is no non-redundant
information on these continuation lines.

=back

=cut

# ----------------------------------------------------------------------

use strict;

use CBIL::Util::Disp;

use CBIL::Bio::DbFfWrapper::Transfac::Section;
use CBIL::Bio::DbFfWrapper::Transfac::History;
use CBIL::Bio::DbFfWrapper::Transfac::BoundFactor;

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

sub getId { $_[0]->{Id} }
sub setId { $_[0]->{Id} = $_[1]; $_[0] }

sub getAccession { $_[0]->{Accession} }
sub setAccession { $_[0]->{Accession} = $_[1]; $_[0] }

sub getHistory { $_[0]->{History} }
sub setHistory { $_[0]->{History} = $_[1]; $_[0] }
sub addHistory { push(@{$_[0]->{History}}, $_[1]); $_[0] }

sub getType { $_[0]->{Type} }
sub setType { $_[0]->{Type} = $_[1]; $_[0] }

sub getGene { $_[0]->{Gene} }
sub setGene { $_[0]->{Gene} = $_[1]; $_[0] }

sub getRegion { $_[0]->{Region} }
sub setRegion { $_[0]->{Region} = $_[1]; $_[0] }

sub getSequence  { $_[0]->{Sequence} }
sub setSequence  { $_[0]->{Sequence} = $_[1]; $_[0] }
sub addSequence  { push(@{$_[0]->{Sequence}},$_[1]); $_[0] }

sub getElement { $_[0]->{Element} }
sub setElement { $_[0]->{Element} = $_[1]; $_[0] }

sub getStart { $_[0]->{Start} }
sub setStart { $_[0]->{Start} = $_[1]; $_[0] }

sub getStop { $_[0]->{Stop} }
sub setStop { $_[0]->{Stop} = $_[1]; $_[0] }

sub getOrigin { $_[0]->{Origin} }
sub setOrigin { $_[0]->{Origin} = $_[1]; $_[0] }

sub getBoundFactors { $_[0]->{BoundFactors} }
sub setBoundFactors { $_[0]->{BoundFactors} = $_[1]; $_[0] }
sub addBoundFactor  { push(@{$_[0]->{BoundFactors}},$_[1]); $_[0] }

sub getMatrix  { $_[0]->{Matrix} }
sub setMatrix  { $_[0]->{Matrix} = $_[1]; $_[0] }
sub addMatrix  { push(@{$_[0]->{Matrix}},$_[1]); $_[0] }

sub getSpecies { $_[0]->{Species} }
sub setSpecies { $_[0]->{Species} = $_[1]; $_[0] }

sub getTaxonomy { $_[0]->{Taxonomy} }
sub setTaxonomy { $_[0]->{Taxonomy} = $_[1]; $_[0] }
sub addTaxonomy { push(@{$_[0]->{Taxonomy}},$_[1]); $_[0] }
sub fixTaxonomy {
   $_[0]->{Taxonomy} = 
   [map { lc $_ } split(/;\s+/, join(' ',@{$_[0]->{Taxonomy}}))]
   if $_[0]->{Taxonomy};
   $_[0]
}

sub getSource    { $_[0]->{Source} }
sub setSource    { $_[0]->{Source} = $_[1]; $_[0] }
sub addSource    { push(@{$_[0]->{Source}},$_[1]); $_[0] }

sub getMethod    { $_[0]->{Method} }
sub setMethod    { $_[0]->{Method} = $_[1]; $_[0] }
sub addMethod    { push(@{$_[0]->{Method}},$_[1]); $_[0] }

sub getComment    { $_[0]->{Comment} }
sub setComment    { $_[0]->{Comment} = $_[1]; $_[0] }
sub addComment    { push(@{$_[0]->{Comment}},$_[1]); $_[0] }
sub fixComment {
   $_[0]->{Comment} = 
   [map { lc $_ } split(/;\s+/, join(' ',@{$_[0]->{Comment}}))]
   if $_[0]->{Comment};
   $_[0]
}

sub getDbRef    { $_[0]->{DbRef} }
sub setDbRef    { $_[0]->{DbRef} = $_[1]; $_[0] }
sub addDbRef    { push(@{$_[0]->{DbRef}},$_[1]); $_[0] }

# ----------------------------------------------------------------------

sub parse {
   my $Self  = shift;
   my $Lines = shift; # [string] : lines from file

   $Self->tableParser
   ( $Lines,

     # ACTIONS
     {
      AC => ['(R\d{5})'          , sub { $Self->setAccession($_[1]) } ],
      ID => ['(\S+)'             , sub { $Self->setId($_[1]) } ],
      DT => ['(.+)'              , sub { $Self->addHistory(CBIL::Bio::DbFfWrapper::Transfac::History->new($_[1])) } ],
      TY => ['(.+)'              , sub { $Self->setType($_[1])} ],
      DE => ['(.+); Gene: (G\d+)', sub { $Self->setElement($_[1]);
                                         $Self->setGene($_[1]);},
             'Gene: (G\d+)'      , sub { $Self->setGene($_[1]); },
             '(.+)'              , sub { $Self->setElement($_[1]); },
            ],
      RE => ['(.+?)'             , sub { $Self->setRegion($_[1]);} ],
      SQ => [ '(.+)\.'           , sub { $Self->addSequence($_[1]);},
              '\.'               , sub { }, # blank line
              '(.+)'             , sub { $Self->addSequence($_[1]);},
            ],
      EL => ['(.+)'              , sub { $Self->setElement($_[1]);} ],
      SF => ['(.+)'              , sub { $Self->setStart($_[1]); } ],
      ST => ['(.+)'              , sub { $Self->setStop($_[1]); } ],
      S1 => ['(.+)'              , sub { $Self->setOrigin($_[1]); } ],
      BF => ['(.+)'              , sub { $Self->addBoundFactor(CBIL::Bio::DbFfWrapper::Transfac::BoundFactor->new($_[1])); } ],
      MX => ['(M\d{5})'          , sub { $Self->addMatrix($_[1]); } ],
      OS => ['(.+)\.?'           , sub { $Self->setSpecies(CBIL::Bio::DbFfWrapper::Transfac::Species->new($_[1])); } ],
      OC => ['(.+)'              , sub { my $tax = $_[1]; $tax =~ s/\.$//;
                                         $Self->addTaxonomy($_[1]);
                                      } ],
      SO => ['(\d+);'            , sub { $Self->addSource($_[1]); } ],
      MM => ['(.+);?'            , sub { $Self->addMethod($_[1]); } ],
      CC => ['(.+)'              , sub { $Self->addComment($_[1]); } ],
      DR => ['(.+)'              , sub { $Self->addDbRef(CBIL::Bio::DbFfWrapper::Transfac::DbRef->new($_[1])); } ],
      CO => 1,
      RN => 1,
      RX => 1,
      RA => 1,
      RT => 1,
      RL => 1,
      XX => 1,
     },

     # END OF LINE WRAPS
     { DE => [ '\.$' ] },

     # LOOK AHEAD WRAPS
     { BF => 'T\d+' },

     # CODE MAPS
     { },
   );

   # CLEAN UP PHASE
   # ..................................................

   $Self
   ->fixTaxonomy
   ->fixComment
   ;

   ConstDebugFlag && CBIL::Util::Disp::Display($Self);

   return $Self
}

# ----------------------------------------------------------------------

1;

