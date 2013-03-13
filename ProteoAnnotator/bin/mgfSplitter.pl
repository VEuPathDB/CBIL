#!/usr/local/bin/perl
#
# This script is to split a set of MGF files into multiple splices depending on their sizes.
# The limit is set for 1 million (or till the next "End Ions" tag is found) lines/mgf file.
#
# @author - Ritesh Krishna 

use strict;

use Getopt::Long qw(GetOptions);

use File::Basename;
my ($help, $inputMgfFile, $outputMgfDirectory, $LIMIT);

GetOptions("inputMgfFile=s" => \$inputMgfFile,
           "outputDir=s" => \$outputMgfDirectory,
           "limit=s" => \$LIMIT,
           "help|h" => \$help,
          );

my $endTag = "END IONS";

if($help) {
  &usage();
}

unless ($LIMIT)
  {
    $LIMIT = 1000000;
  }

# get arguments and perform basic error checking


mkdir($outputMgfDirectory, 0777) || die "can't create output dir: $!";

open(FILE, $inputMgfFile) || die "can't open file $inputMgfFile: $!"; 

my ($inputMgfFilename ,$dir, $ext) = fileparse($inputMgfFile);

$inputMgfFilename = $inputMgfFilename.$ext;

my $fileCounter = 0;



open (INFILE,  "<$inputMgfFile")  || die "Error: cannot open $inputMgfFile";

my $chunk = '';
my $lineCounter = 0;

foreach my $line (<INFILE>) {
  #chomp($line);
  $lineCounter++;
  
  if(index($line,$endTag) >= 0){ 
    print "$lineCounter \t $line \t $endTag\n";
  }
  
  $chunk = $chunk . $line;
  
  if( $lineCounter >= $LIMIT){ 
    if (index($line,$endTag) >= 0){
      $lineCounter = 0;
      $fileCounter++;
      my $outputFile = $fileCounter . "_$inputMgfFilename"; 
      print STDERR "$outputMgfDirectory/$outputFile";
      open (OUTFILE, ">$outputMgfDirectory/$outputFile")  || die "Error: cannot open output file: $!";
      print OUTFILE $chunk;
      close($outputFile);
      $chunk = '';
    }
  } 
}

# The last remaining bit which might be less than the LIMIT...
if($lineCounter > 0){
  $fileCounter++;
  my $outputFile = $fileCounter . "_$inputMgfFilename"; 
  open (OUTFILE, ">$outputMgfDirectory/$outputFile")  || die "Error: cannot open output file  $!";
  print OUTFILE $chunk;
  close($outputFile);
}	

close(INFILE);

