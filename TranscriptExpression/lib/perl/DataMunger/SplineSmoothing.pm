package CBIL::TranscriptExpression::DataMunger::SplineSmoothing;
use base qw(CBIL::TranscriptExpression::DataMunger);

use strict;

use File::Temp qw/ tempfile /;

use CBIL::TranscriptExpression::Error;

#-------------------------------------------------------------------------------

sub getInterpolationN { $_[0]->{interpolation_n} }
sub setInterpolationN { $_[0]->{interpolation_n} = $_[1] }

#-------------------------------------------------------------------------------

sub new {
  my ($class, $args) = @_;

  my $requiredParams = ['inputFile',
                        'outputFile',
                        ];

  my $self = $class->SUPER::new($args, $requiredParams);

  my $inputFile = $args->{inputFile};
  unless(-e $inputFile) {
    CBIL::TranscriptExpression::Error->new("input file $inputFile does not exist")->throw();
  }

  return $self;
}


#-------------------------------------------------------------------------------

sub munge {
  my ($self) = @_;

  my $rFile = $self->writeRFile();

  $self->runR($rFile);

  unlink($rFile);
}

#-------------------------------------------------------------------------------

sub writeRFile {
  my ($self) = @_;

  my $inputFile = $self->getInputFile();
  my $outputFile = $self->getOutputFile();
  my $interpN = $self->getInterpolationN();


  my $doInterp = 'FALSE';
  my $interpFile;
  if(defined($interpN)) {
    $doInterp = 'TRUE';

    $interpFile = "$outputFile" . "_" . $interpN;
  }


  my ($fh, $file) = tempfile();



 my $rString = <<RString;
dat = read.table("$inputFile", header=T, sep="\\t", check.names=FALSE);
numHeader = as.numeric(sub(" *[a-z-A-Z]+ *", "", colnames(dat), perl=T));

ids = as.character(dat[,1]);

newHeader = vector();
newDat = vector();
xCoords = vector();

for(i in 2:length(numHeader)) {
 if(!is.na(numHeader[i])) {
    newDat = cbind(newDat, dat[,i]);
    newHeader[length(newHeader)+1] = colnames(dat)[i]; 
    xCoords[length(xCoords)+1] = numHeader[i]; 
  }
}

colnames(newDat) = newHeader;


splines = vector();
interpolatedSplines = vector();

predictX = round(approx(xCoords, n=$interpN)\$y, 1);

for(i in 1:nrow(newDat)) {
  spline = smooth.spline(xCoords, newDat[i,]);
  splines = rbind(splines, spline\$y);

  if($doInterp) {
    interpolatedSplines = rbind(interpolatedSplines, predict(spline, predictX)\$y);
  }
}

colnames(splines) = as.character(newHeader);
colnames(interpolatedSplines) = as.character(predictX);

colnames(splines)[1] = paste("ID\t", colnames(splines)[1], sep="");
colnames(interpolatedSplines)[1] = paste("ID\t", colnames(interpolatedSplines)[1], sep="");


write.table(splines, file="$outputFile",quote=FALSE,sep="\\t", row.names=ids);

if($doInterp) {
  write.table(interpolatedSplines, file="$interpFile",quote=FALSE,sep="\\t", row.names=ids);
}

RString


  print $fh $rString;

  close $fh;

  return $file;
}
1;
