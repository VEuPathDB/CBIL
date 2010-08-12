package CBIL::TranscriptExpression::DataMunger::Normalization::TwoChannelLoess;
use base qw(CBIL::TranscriptExpression::DataMunger::Normalization);

use strict;

use CBIL::TranscriptExpression::Utils;
use CBIL::TranscriptExpression::Error;

use CBIL::TranscriptExpression::Check::ConsistentIdOrder;

use File::Basename;
use File::Temp qw/ tempfile /;

#--------------------------------------------------------------------------------

sub getGridRows                            { $_[0]->{gridRows} }
sub getGridColumns                         { $_[0]->{gridColumns} }
sub getSpotRows                            { $_[0]->{spotRows} }
sub getSpotColumns                         { $_[0]->{spotColumns} }

sub getIdColumnName                        { $_[0]->{idColumnName} }
sub getGreenColumnName                     { $_[0]->{greenColumnName} }
sub getRedColumnName                       { $_[0]->{redColumnName} }
sub getFlagColumnName                      { $_[0]->{flagColumnName} }

sub getExcludeSpotsByFlagValue             { $_[0]->{excludeSpotsByFlagValue} }
sub getWithinSlideNormalizationType        { $_[0]->{withinSlideNormalizationType} }
sub getDoAcrossSlideNormalization          { $_[0]->{doAcrossSlideNormalization} }

sub getMappingFileOligoColumn              { $_[0]->{mappingFileOligoColumn} }
sub setMappingFileOligoColumn              { $_[0]->{mappingFileOligoColumn} = $_[1] }

sub getMappingFileGeneColumn               { $_[0]->{mappingFileGeneColumn} }
sub setMappingFileGeneColumn               { $_[0]->{mappingFileGeneColumn} = $_[1] }

sub getMappingFileHasHeader                { $_[0]->{mappingFileHasHeader} }
sub setMappingFileHasHeader                { $_[0]->{mappingFileHasHeader} = $_[1] }

#--------------------------------------------------------------------------------

my $MAP_HAS_HEADER = 0;
my $MAP_GENE_COL = 'first';
my $MAP_OLIGO_COL = 'second';

#--------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $self = $class->SUPER::new($args);

  my $additionalRequiredParams = ['greenColumnName',
                                  'redColumnName',
                                  'idColumnName',
                                  'flagColumnName',
                                  'withinSlideNormalizationType',
                                  'gridRows',
                                  'gridColumns',
                                  'spotRows',
                                  'spotColumns',
                                 ];

  CBIL::TranscriptExpression::Utils::checkRequiredParams($additionalRequiredParams, $args);

  my $normType = $self->getWithinSlideNormalizationType();
  if($normType ne 'loess' && $normType ne 'printTipLoess' && $normType ne 'median') {
    CBIL::TranscriptExpression::Error->new("within slide normalizationType must be one of [loess,printTipLoess, or median]")->throw();
  }

  $self->setMappingFileHasHeader($MAP_HAS_HEADER) unless(defined $self->getMappingFileHasHeader());
  $self->setMappingFileGeneColumn($MAP_GENE_COL) unless(defined $self->getMappingFileGeneColumn());
  $self->setMappingFileOligoColumn($MAP_OLIGO_COL) unless(defined $self->getMappingFileOligoColumn());

  my $oligoColumn = $self->getMappingFileOligoColumn();
  my $geneColumn = $self->getMappingFileGeneColumn();
  my $hasHeader = $self->getMappingFileHasHeader();

  if($oligoColumn eq $geneColumn) {
    CBIL::TranscriptExpression::Error->new("oligo column cannot be the same as gene column")->throw();
  }

  unless($oligoColumn eq 'first' || $oligoColumn eq 'second') {
    CBIL::TranscriptExpression::Error->new("oligo column must equal first or second")->throw();
  }

  unless($geneColumn eq 'first' || $geneColumn eq 'second') {
    CBIL::TranscriptExpression::Error->new("gene column must equal first or second")->throw();
  }


  my $dataFiles = $self->getDataFiles();
  my $idColumnName = $self->getIdColumnName();
  my $mainDirectory = $self->getMainDirectory();

  my $checker = CBIL::TranscriptExpression::Check::ConsistentIdOrder->new($dataFiles, $mainDirectory, $idColumnName);
  $self->setChecker($checker);

  return $self;
}

sub munge {
  my ($self) = @_;

  my $checker = $self->getChecker();
  my $idArray = $checker->getIdArray();

  my $tmpMappingFile = $self->mappingFileForR($idArray);

  my $dataFilesRString = $self->makeDataFilesRString();

  my $rFile = $self->writeRScript($dataFilesRString, $tmpMappingFile);

  $self->runR($rFile);

  unlink($rFile, $tmpMappingFile);
}

sub mappingFileForR {
  my ($self, $idArray) = @_;

  my ($fh, $filename) = tempfile();

  my $mappingFile = $self->getMappingFile();  

  my $oligoColumn = $self->getMappingFileOligoColumn();

  my $oligoIndex = $oligoColumn eq 'first' ? 0 : 1;
  my $geneIndex = $oligoColumn eq 'first' ? 1 : 0;

  open(MAP, $mappingFile) or die "Cannot open file $mappingFile for reading: $!";

  # remove the first line if there is a header
  <MAP> if($self->getMappingFileHasHeader() == 1);

  my %oligoToGene;

  while(<MAP>) {
    chomp;
    my @cols = split(/\t/, $_);

    my $oligoString = $cols[$oligoIndex];
    my $geneString = $cols[$geneIndex];

    my @oligos = split(',', $oligoString);
    my @genes =  split(',', $geneString);

    foreach my $oligo (@oligos) {
      my @seenGenes;
      @seenGenes = @{$oligoToGene{$oligo}} if($oligoToGene{$oligo});

      foreach my $gene (@genes) {
        next if(&alreadyExists($gene, \@seenGenes));
        push @{$oligoToGene{$oligo}}, $gene;
      }
    }
  }

  print $fh "ID\tGENES\n";
  foreach my $oligo (@$idArray) {
    my @genes;
    @genes = @{$oligoToGene{$oligo}} if($oligoToGene{$oligo});
    my $genesString = join(',', @genes);

    print $fh "$oligo\t$genesString\n";
  }

  close $fh;

  return $filename;
}

# static method
sub alreadyExists {
  my ($val, $ar) = @_;

  foreach(@$ar) {
    return 1 if($_ eq $val);
  }
  return 0;
}


sub writeRScript {
  my ($self, $dataFilesString, $mappingFile) = @_;

  my $outputFile = $self->getOutputFile();
  my $outputFileBase = basename($outputFile);
  my $pathToDataFiles = $self->getMainDirectory();

  my $ngr = $self->getGridRows();
  my $ngc = $self->getGridColumns();
  my $nsr = $self->getSpotRows();
  my $nsc = $self->getSpotColumns();

  my $gf = $self->getGreenColumnName();
  my $rf = $self->getRedColumnName();
  my $flags = $self->getFlagColumnName();

  my $normalizationType = $self->getWithinSlideNormalizationType();
  my $excludeFlagValue = $self->getExcludeSpotsByFlagValue();

  my $doAcrossSlideScaling = $self->getDoAcrossSlideNormalization() ? "TRUE" : "FALSE";


  my ($rfh, $rFile) = tempfile();

  my $rString = <<RString;
load.marray = library(marray, logical.return=TRUE);

if(load.marray) {

source("$ENV{GUS_HOME}/lib/R/TranscriptExpression/normalization_functions.R");

my.layout = read.marrayLayout(ngr=$ngr, ngc=$ngc, nsr=$nsr, nsc=$nsc);
my.gnames = read.marrayInfo("$mappingFile", info.id=c(1,2), labels=1, na.strings=c(""))

data.files = vector();
$dataFilesString

raw.data = read.marrayRaw(data.files, path="$pathToDataFiles", name.Gf="$gf", name.Rf="$rf", name.W="$flags", layout=my.layout, gnames=my.gnames, skip=0);

# Rb and Gb slots need to hold a matrix of same dim as the Rf and Gf slots
raw.data\@maRb = raw.data\@maRf * 0;
raw.data\@maGb = raw.data\@maGf * 0;

# vector of rows to normalize on (ie. spots to use when drawing the loesss curve)
subsetOfGenes = !is.na(raw.data\@maGnames\@maInfo[,2]);

# set raw values for any flags to NA
flagged.values = setFlaggedValuesToNA(rM=raw.data\@maRf, gM=raw.data\@maGf, wM=raw.data\@maW, fv="$excludeFlagValue");
raw.data\@maRf = flagged.values\$R;
raw.data\@maGf = flagged.values\$G;

norm.data = maNorm(raw.data, norm=c("$normalizationType"), subset=subsetOfGenes, span=0.4, Mloc=TRUE, Mscale=TRUE, echo=FALSE);

if($doAcrossSlideScaling) {
 norm.data = maNormScale(norm.data, norm=c("globalMAD"), subset=TRUE, geo=TRUE,  Mscale=TRUE, echo=FALSE);
}

# Avg Spotted Replicates based on "genes" in Mapping File
avgM = averageSpottedReplicates(m=norm.data\@maM, nm=norm.data\@maGnames\@maInfo[,2]);
avgRed = averageSpottedReplicates(m=raw.data\@maRf, nm=norm.data\@maGnames\@maInfo[,2]);
avgGreen = averageSpottedReplicates(m=raw.data\@maGf, nm=norm.data\@maGnames\@maInfo[,2]);

allRaw = cbind(avgRed[,1], avgRed[,2:ncol(avgRed)], avgGreen[,2:ncol(avgGreen)]);

colnames(avgM) = c("ID", data.files);
colnames(avgRed) = c("ID", data.files);
colnames(avgGreen) = c("ID", data.files);
colnames(allRaw) = c("ID", paste(data.files, ".red", sep=""), paste(data.files, ".green", sep=""));

# write data
write.table(avgM, file="$outputFile", quote=F, sep="\\t", row.names=FALSE);
write.table(avgRed, file=paste("$outputFile", ".red", sep=""), quote=F, sep="\\t", row.names=FALSE);
write.table(avgGreen, file=paste("$outputFile", ".green", sep=""), quote=F, sep="\\t", row.names=FALSE);
write.table(allRaw, file=paste("$outputFile", ".all_raw", sep=""), quote=F, sep="\\t", row.names=FALSE);


} else {
  stop("ERROR:  could not load required marray library");
}
RString

  print $rfh $rString;

  close $rfh;

  return $rFile;
}


1;
