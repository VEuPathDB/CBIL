package CBIL::TranscriptExpression::DataMunger::Normalization::AffymetrixGCRMA;
use base qw(CBIL::TranscriptExpression::DataMunger::Normalization);

use strict;

use File::Basename;

sub getCdfFile     { $_[0]->getMappingFile }
sub getCelFilePath { $_[0]->getPathToDataFiles }

sub munge {
  my ($self) = @_;

  my $dataFilesRString = $self->makeDataFilesRString();

  my $rFile = $self->writeRScript($dataFilesRString);

  $self->runR($rFile);

  system("rm $rFile");
}

sub writeRScript {
  my ($self, $samples) = @_;

  my $compress = "FALSE";
  if($self->isMappingFileZipped()) {
    $compress = "TRUE";
  }

  my $celFilePath = $self->getCelFilePath();

  my $cdfFile = $self->getCdfFile();
  my $cdfFileBasename = basename($cdfFile);
  my $cdfFileDirname = dirname($cdfFile);

  my $outputFile = $self->getOutputFile();
  my $outputFileBase = basename($outputFile);
  my $rFile = "/tmp/$outputFileBase.R";

  open(RCODE, "> $rFile") or die "Cannot open $rFile for writing:$!";

  my $rString = <<RString;

load.makecdfenv = library(makecdfenv, logical.return=TRUE)
load.gcrma = library(gcrma, logical.return=TRUE)

if(load.makecdfenv && load.gcrma) {

  data.files = list();
  $samples

  pkgpath = tempdir();
  my.cdf <- make.cdf.package("$cdfFileBasename", species="Who_cares", cdf.path="$cdfFileDirname", package.path =pkgpath, compress=$compress);

  files = rownames(summary(data.files));

  dat = justGCRMA(filenames=files, normalize=TRUE, affinity.info=NULL, type="fullmodel", verbose=TRUE, fast=FALSE, cdfname=my.cdf, celfile.path="$celFilePath");

  files[1] = paste("ID\t", files[1], sep="");
  colnames(exprs(dat)) = files;

  write.table(exprs(dat), file="$outputFile",quote=F,sep="\\t", row.names=TRUE);

  unlink(pkgpath, recursive=TRUE);

  quit("no");
} else {
  stop("ERROR:  could not load required libraries makecdfenv and gcrma");
}

RString


  print RCODE $rString;

  close RCODE;

  return $rFile;
}




1;
