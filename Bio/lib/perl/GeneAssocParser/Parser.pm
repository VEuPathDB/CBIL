package CBIL::Bio::GeneAssocParser::Parser;

use strict 'vars';

use FileHandle;

use CBIL::Bio::GeneAssocParser::Store;
use CBIL::Bio::GeneAssocParser::Assoc;


#----------------------------------------------------------------------
#new

sub new{
    my ($class, $filePath) = @_;

    my $self = {};
    bless ($self, $class);
    
    $self->init($filePath);
    
    
    return $self;
}

#----------------------------------------------------------------------
#init

sub init {
    my ($self, $filePath) = @_;
    
    $self->setPath ($filePath);
    
}


sub loadAllFiles {
    my $self = shift;

    $self->trimPath();

    
    foreach my $file (qw( .fb .goa_sptr .sgd .wb .tair)) {
	my $fullFile = "gene_association" . "$file";
	print STDERR "parser: loading file $fullFile\n";
	
	$self->loadFile($fullFile);
    }
 
   
    return $self;
}

sub parseAllFiles {
    my ($self) = @_;
    print STDERR "Parser:  Parsing all files\n";
    my $files = $self->getFileStores();
    
    foreach my $file (keys %$files){
	print STDERR "Parser:  Parsing file $file\n";
	my $store = $self->parseFile($file);
    }

    return $self;
}
 



#----------------------------------------------------------------------
#private data accessors
sub setPath{
    my ($self, $path) = @_;
    $self->{Path} = $path;
}

sub getPath{
    my ($self) = @_;
    return $self->{Path};
}

sub setFileStore{
    my ($self, $fileName, $file) = @_;
    $self->{FileStores}->{$fileName} = $file;
}

sub getFileStore{
    my ($self, $fileName) = @_;
    return $self->{FileStores}->{$fileName};
}

sub getFileStores{
    my ($self) = @_;
    return $self->{FileStores};
}

#----------------------------------------------------------------------
#other methods



#This method accepts as input a filename and loads the file into the
#parser's file cache
#different from equivalent method in GoOntology.Parser as that one
#just returns the store rather than caching it.
sub loadFile{
    my ($self, $fileName) = @_; 
    
    my $fullFileName = join ('/', $self->getPath, "$fileName");
    my $fh = FileHandle->new("<$fullFileName");

    print STDERR "Parser: loading file $fileName\n";

    unless($fh){
	print STDERR "Error in Parser::LoadFile() could not open $fullFileName";
	return undef;
    } 
    
    
    my $store = CBIL::Bio::GeneAssocParser::Store->new();
    
    while (<$fh>){
	chomp;
	
	#for now do not worry about comments in file
	unless (/^!/){ 
	    $store->addRecord($_);
	}
    }
    $fh->close;
    $self->setFileStore($fileName, $store);
    return $store;

}

#takes file as input and parses it
sub parseFile{
    my ($self, $fileName) = @_;

    my $fileStore = $self->getFileStore($fileName);

    print STDERR "Parser: Parsing file $fileName\n";
    
    unless ($fileStore){
	print STDERR "Error in Parser::ParseFile(): could not find cached file $fileName";
	return undef;
    }

    my $records = $fileStore->getRecords;
 
    foreach my $record(@$records){
	my $entry = $self->loadGeneAssocEntry($record);
	$fileStore->addParsedEntry($entry);
	$entry->showMyInfo;
	
    }
    $self->setFileStore($fileName, $fileStore);
    
    return $fileStore;
}

sub trimPath{
    my ($self) = @_;

    

    my $path = $self->getPath();
    my $newPath = $path;
   # print STDERR "path is $path\n";
    if ( $path =~ /(\S+)\/$/){
	$newPath = $1;
    }
    
    my $tempFile1 = "gene_association.fb";
    my $tempFile2 = "gene_association.goa_sptr";
    my $tempFile3 = "gene_association.sgd";
    my $tempFile4 = "gene_association.tair";
    my $tempFile5 = "gene_association.wb";

    my ($organism1) = $tempFile1 =~ /gene_association\.(\w+)$/;
    my ($organism2) = $tempFile2 =~ /gene_association\.(\w+)$/;
    my ($organism3) = $tempFile3 =~ /gene_association\.(\w+)$/;
    my ($organism4) = $tempFile4 =~ /gene_association\.(\w+)$/;
    my ($organism5) = $tempFile5 =~ /gene_association\.(\w+)$/;

  #  print STDERR "$organism1 $organism2 $organism3 $organism4 $organism5\n";

   # print STDERR "now path is $newPath\n";
    $self->setPath($newPath);
}

sub loadGeneAssocEntry{
    my ($self, $entry) = @_;

    return CBIL::Bio::GeneAssocParser::Assoc->new($entry);
}

1;
