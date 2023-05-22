#!/usr/bin/perl

use strict;

use lib "$ENV{GUS_HOME}/lib/perl";

use CBIL::StudyAssayResults::Error;

use Getopt::Long;

use File::Temp qw/ tempfile /;

my ($help, $dataFile1, $dataFile2, $hasHeader, $outputFile, @executableDirectory);

&GetOptions('help|h' => \$help,
            'minuend_file=s' => \$dataFile1,
            'subtrahend_file=s' => \$dataFile2,
            'output_file=s' => \$outputFile,
            'hasHeader' => \$hasHeader,
            'executable_path=s' => \@executableDirectory,
           );


foreach(@executableDirectory) {
  $ENV{PATH} .= ":$_";
}

unless(-e $dataFile1 && -e $dataFile2) {
  &usage("Error:  File dies not exist: $!");
}

my ($tempFh, $tempFn) = tempfile();

my $header = defined($hasHeader) ? 'TRUE' : 'FALSE';


print "OUTPUT FILE : $outputFile\n";

my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/StudyAssayResults/profile_functions.R");

dat1 = read.table("$dataFile1", header=$header, sep="\\t", check.names=FALSE, row.names=1);
dat2 = read.table("$dataFile2", header=$header, sep="\\t", check.names=FALSE, row.names=1);

datDifference = dat1 - dat2;

output = cbind(rownames(dat1), datDifference);

write.table(output, file="$outputFile", quote=FALSE, sep="\\t", row.names=FALSE);

quit("no");
RString

print $tempFh $rString;

my $command = "cat $tempFn  | R --no-save ";

my $systemResult = system($command);

unless($systemResult / 256 == 0) {
  CBIL::StudyAssayResults::Error->new("Error while attempting to run R:\n$command")->throw();
}

unlink($tempFn);

sub usage {
  my $m = shift;

  print STDERR "$m\n\n" if($m);
  print STDERR "usage:  perl profileDifference.pl --minuend_file <DATA> --subtrahend_file <DATA> --output_file <OUT> --executable_path [--hasHeader] --help\n";
  exit(1);
}


1;
