
package CBIL::Bio::KeggDrug::Parser;

use strict 'vars';

use FileHandle;

use CBIL::Bio::KeggDrug::Parser::Store;

use CBIL::Bio::KeggDrug::KeggDrug;
use CBIL::Bio::KeggDrug::EcNumber;
use CBIL::Bio::KeggDrug::DbRef;


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

   $M->setErrMsg   ($A->{ErrMsg}     || undef);
   $M->setFilePath ($A->{FilePath}   || '.');
   $M->setFileCache($A->{FileCache}  || {} );

   return $M
}

# ----------------------------------------------------------------------

sub getErrMsg     { $_[0]->{ErrMsg} }
sub setErrMsg     { $_[0]->{ErrMsg} = $_[1]; $_[0] }
sub clrErrMsg     { $_[0]->{ErrMsg} = undef; $_[0] }

sub getFilePath   { $_[0]->{FilePath} }
sub setFilePath   { $_[0]->{FilePath} = $_[1]; $_[0] }

sub getLoaded     { $_[0]->{Loaded} }
sub setLoaded     { $_[0]->{Loaded} = $_[1]; $_[0] }

sub getParsed     { $_[0]->{Parsed} }
sub setParsed     { $_[0]->{Parsed} = $_[1]; $_[0] }

sub getFileCache  { $_[0]->{FileCache} }
sub setFileCache  { $_[0]->{FileCache} = $_[1]; $_[0]}

# ----------------------------------------------------------------------

sub loadFile {
  my $M = shift;


  my $F = $M->getFilePath;

  $M->clrErrMsg;

  # prepare to read file
  # ........................................
  # get name,
  # get handle,
  # make sure handle's ok
  # save and adjust record separator

  my $fh = FileHandle->new("<$F");

  unless ($fh) {
    $M->setErrMsg(join("\t",'Unable to open loadFile',$F,$!));
    print  STDERR $M->getErrMsg;
    return undef;
  }

  my $saved_input_record_separator = $/;
  $/ = "///\n";

  # read file
  # ........................................
  # read entries.

  # file store
  my $store = CBIL::Bio::KeggDrug::Parser::Store->new();

  $store->addRecord($_) for (<$fh>);

  $fh->close;
  $/ = $saved_input_record_separator;

  $M->setFileCache($store);
  
  $M->setLoaded(1);
  $M->setParsed(0);

  # return value;
  # $store
}

# ----------------------------------------------------------------------

sub parseFile {
  my $M = shift;

  $M->loadFile unless $M->getLoaded;

#  foreach my $file (sort keys %{$M->getFileCache}) {
     my $good_n = 0;
     my $bad_n  = 0;
     my $store = $M->getFileCache();
        foreach my $record (@{$store->getRecords}) {
           if (my $entry = CBIL::Bio::KeggDrug::KeggDrug->new($record)) {
              $good_n++;
              $store->setEntry($entry);
           }
           else {
              $bad_n++;
           }
        } # eo entry scan
#  } # eo file scan

	$M->setParsed(1);

  # return value
  undef
}

# ----------------------------------------------------------------------



1;

# ======================================================================

__END__

$| = 1;

my $p = CBIL::Bio::KeggDrug::Parser
->new({ FilePath => shift @ARGV,
      });
$p->loadFile;
$p->parseFile;
