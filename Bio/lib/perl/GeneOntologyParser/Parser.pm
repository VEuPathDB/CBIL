package CBIL::Bio::GeneOntologyParser::Parser;

use strict 'vars';

use FileHandle;

use CBIL::Bio::GeneOntologyParser::Store;
use CBIL::Bio::GeneOntologyParser::Term;

# ----------------------------------------------------------------------

sub new {
    my ($class, $filePath) = @_;
    
    
    my $self = bless {}, $class;
    
    $self->init($filePath);
    $self->{levelGraph} = {};
    return $self;
}

# ----------------------------------------------------------------------

sub init {
   my ($self, $filePath) = @_;
 
   $self->setPath ($filePath);

   $self->setLoaded(0);
   $self->setParsed(0);

   return $self;
}

# ----------------------------------------------------------------------


sub loadAllFiles {
    my $self = shift;
    
    $self->clrErrMsg;
    
    foreach my $file (qw( component process function )) {
	my $fullFile = "$file.ontology";
	
	$self->loadFile($fullFile);
    }
    
    $self->setLoaded(1);
    $self->setParsed(0);
    
    return $self;
}

# ----------------------------------------------------------------------
sub parseAllFiles {
    my ($self) = @_;

    my $files = $self->getFileCaches();
    
    foreach my $file (keys %$files){

	my $store = $self->parseFile($file);
    }
    $self->setParsed(1);
    return $self;
}
 

# ----------------------------------------------------------------------

sub loadFile {
  my $self = shift;
  my $fileName = shift;

  # prepare to read file
  # ........................................
  # get name,
  # get handle,
  # make sure handle's ok
  # save and adjust record separator

  my $fullFileName  = join('/', $self->getPath, "$fileName");
  my $fh = FileHandle->new("<$fullFileName");

  unless ($fh) {
 
      print STDERR "Note: did not find file $fileName in directory $self->getPath.\n To load this branch of the ontology specified by $fileName,\n please put that file in the directory.\n"; 
 
    return undef;
  }

  # read file
  # ........................................
  # read version information.
  # read entries.

  # file store
  my $store = CBIL::Bio::GeneOntologyParser::Store->new();

  my @version_lines;
  while (<$fh>) {
      
     chomp;
     if (/^!/) {
        if (/!version:.+Revision:\s*(\d+\.\d+)/) {
           $store->setVersion($1);
        }
     }
     else {

        $store->addRecord($_);
    }
  }
  
  $fh->close;
  $self->setFileCache($fileName, $store);

  $self->setLoaded(1);
  # return value;
  return $store;
}

# ----------------------------------------------------------------------

sub parseFile {
    my ($self, $file) = @_;
    open (LOG, ">>logs/tempLog");
    
    my $good_n      = 0;
    my $bad_n       = 0;
    my $dup_n       = 0;

    # initialize parent path stack
  CBIL::Bio::GeneOntologyParser::Term::setPath();
    my $parentPathStack = CBIL::Bio::GeneOntologyParser::Term::Path;
    my $store   = $self->getFileCache($file);
	unless ($store){ print STDERR "could not find store\n"; next;}
       
    my $records = $store->getRecords || [];
    foreach my $record (@$records) {
	
	if (my $entry = $self->loadTableGeneOntologyEntry($record)) {
	    
	    $store->setRoot($entry->getId()) if $entry->getRoot();
	    my $earlier = $store->getEntry($entry->getId);
	    if ($earlier) { #duplicate term, presumably different path
		$dup_n++;
		if ($entry->getName ne $earlier->getName) {
		    print STDERR join("\t",
				      'ERROR',
				      'non-matching names for same GO id'
				      ), "\n";
		  Disp::Display([$entry,$earlier],'[$entry, $earlier] ');
		}
	    }
	    else {
		
		$store->addEntry($entry);
		$good_n++;
	    }
	}
	else {
	    $bad_n++;
	}
    } # eo entry scan
    
    #hack to set branch root
    my $entries = $store->getEntries();
    my $rootEntry = $store->getRoot();
    
    foreach my $finalEntryId (keys %$entries){
	my $finalEntry = $entries->{$finalEntryId};
	my @parents = (@{$finalEntry->getClasses()}, @{$finalEntry->getContainers()} );
	if (@parents){
	    if ($parents[0] eq $rootEntry){
		$finalEntry->setBranchRoot(1);
		$store->setBranchRoot($finalEntryId);
		last;	
	    }
	}
    }
	       
    $store->clrRecords();
    
    $self->setParsed(1);
    $self->setFileCache($file, $store);
    # return value
    return $store; #undef
}

# ----------------------------------------------------------------------

sub loadTableGeneOntologyEntry {
  my $self = shift;
  my $entry = shift;

  return CBIL::Bio::GeneOntologyParser::Term->new($entry);
}

# ----------------------------------------------------------------------

sub setPath{
    my ($self, $path) = @_;
    $self->{Path} = $path;
}
sub setFileCache{
    my ($self, $fileName, $fileCache) = @_;
    $self->{FileCaches}->{$fileName} = $fileCache;
}

sub getPath{
    my ($self) = @_;
    return $self->{Path};
}
sub getFileCache{
    my ($self, $file) = @_;
    return $self->{FileCaches}->{$file};
}

sub getFileCaches{
    my ($self) = @_;
    return $self->{FileCaches};
}


sub getErrMsg     { $_[0]->{ErrMsg} }
sub setErrMsg     { $_[0]->{ErrMsg} = $_[1]; $_[0] }
sub clrErrMsg     { $_[0]->{ErrMsg} = undef; $_[0] }


sub getLoaded     { $_[0]->{Loaded} }
sub setLoaded     { $_[0]->{Loaded} = $_[1]; $_[0] }

sub getParsed     { $_[0]->{Parsed} }
sub setParsed     { $_[0]->{Parsed} = $_[1]; $_[0] }

# ----------------------------------------------------------------------


1;

# ======================================================================

__END__

$| = 1;

use Disp;

my $p = GeneOntologyParser::Parser
->new({ Path => shift @ARGV,
      });
$p->loadAllFiles;
$p->parseAllFiles;


