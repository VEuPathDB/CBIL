
package CBIL::Bio::GenBank::Reference;
@ISA = qw( CBIL::Bio::GenBank::BaseObject );

use CBIL::Bio::GenBank::Authors;

use strict 'vars';

sub setOrdinal { $_[0]->{ORD} = $_[1]; $_[0] }
sub setFrom    { $_[0]->{FRM} = $_[1]; $_[0] }
sub setTo      { $_[0]->{TO } = $_[1]; $_[0] }
sub setAuthors { $_[0]->{AUT} = $_[1]; $_[0] }
sub setTitle   { $_[0]->{TIT} = $_[1]; $_[0] }
sub setJournal { $_[0]->{JOU} = $_[1]; $_[0] }
sub setMEDLINE { $_[0]->{MED} = $_[1]; $_[0] }
sub setPubMed  { $_[0]->{PUB} = $_[1]; $_[0] }
sub setRemark  { $_[0]->{REM} = $_[1]; $_[0] };

sub getFrom    { $_[0]->{FRM} }
sub getTo      { $_[0]->{TO } }
sub getAuthors { $_[0]->{AUT} }
sub getAuthorString { $_[0]->{AUT}->getString() }
sub getTitle   { $_[0]->{TIT} }
sub getJournal { $_[0]->{JOU} }
sub getMEDLINE { $_[0]->{MED}->[0] }
sub getPubMed  { $_[0]->{PUB} }
sub getRemark  { $_[0]->{REM} }
sub getOrdinal { $_[0]->{ORD} }
sub getString  { $_[0]->{STR} }

# ........................................

sub parse {
  my $M   = shift;
  my $IOS = shift;

  $M->parseAsText('REFERENCE', $IOS);

  $_ = $M->getString();

  my ( $ordinal ) = ( $_ =~ /^(\d+)/ );
  $M->setOrdinal( $ordinal );

  my ( $from, $to ) = ( $_ =~ /bases (\d+) to (\d+)/ );
  $M->setFrom( $from );
  $M->setTo( $to );

  $M->setAuthors( CBIL::Bio::GenBank::Authors->new( { ios => $IOS }  ) );
  $M->setTitle(     $M->extractItem('\s+TITLE',   $IOS, ' ') );
  $M->setJournal(   $M->extractItem('\s+JOURNAL', $IOS, ' ') );
  $M->setMEDLINE(   $M->extractItem('\s+MEDLINE', $IOS) );
  $M->setPubMed(    $M->extractItem('\s+PUBMED',  $IOS) );
  $M->setRemark(    $M->extractItem('\s+REMARK',  $IOS, ' ' ) );

  $M;
}

1;

