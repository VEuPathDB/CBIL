#!/usr/bin/perl

use strict;

use lib "$ENV{GUS_HOME}/lib/perl";

use CBIL::StudyAssayResults::Error;

use Getopt::Long;

use File::Temp qw/ tempfile /;

my ($help, $dataFile, $ties, $hasHeader, $outputFile, @executableDirectory);

&GetOptions('help|h' => \$help,
            'input_file=s' => \$dataFile,
            'output_file=s' => \$outputFile,
            'ties=s' => \$ties,
            'hasHeader' => \$hasHeader,
            'executable_path=s' => \@executableDirectory,
           );


foreach(@executableDirectory) {
  $ENV{PATH} .= ":$_";
}

unless(-e $dataFile) {
  &usage("Error:  File $dataFile dies not exist");
  die;
}

unless($ties eq "average" || $ties eq "first" || $ties eq "random" || $ties eq "max" || $ties eq "min") {
  &usage("Error:  ties must be specified as one of (average, first, random, max, or min)");
}


my ($tempFh, $tempFn) = tempfile();

my $header = defined($hasHeader) ? 'TRUE' : 'FALSE';

my $rString = <<RString;

source("$ENV{GUS_HOME}/lib/R/StudyAssayResults/profile_functions.R");

dat = read.table("$dataFile", header=$header, sep="\\t", check.names=FALSE, row.names=1);

pct = percentileMatrix(m=dat, ties="$ties");

output = cbind(rownames(dat), pct);

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
  print STDERR "usage:  perl percentile.pl --input_file <DATA> --output_file <OUT> --ties=s --executable_path [--hasHeader] --help\n";
  exit(1);
}


1;
