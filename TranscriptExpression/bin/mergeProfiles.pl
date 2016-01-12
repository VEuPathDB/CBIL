#!/usr/bin/perl

use strict;

use warnings;

use Getopt::Long;

use Data::Dumper;

use lib "$ENV{GUS_HOME}/lib/perl";

my @input_files;
my ($help, $output_file, $noHeader) = undef;

&GetOptions('help|h' => \$help,
                      'input_files=s' => \@input_files,
                      'output_file=s' => \$output_file,
                      'no_header' => \$noHeader,
           );

my $hasHeader= defined $noHeader? 0 : 1 ;
my $fileHash = {};
my $outputColsHash = {};
for my  $inFile (@input_files) {
  my $isHeader= 1;
  open (INFILE, "<$inFile") or die "unable to open input file $inFile: $!";
  my $header=undef;
  for my $row (<INFILE>){
    chomp $row;
    $row=~s/\r//g;
    my @columns = split ("\t",$row);
    if ($hasHeader && !$header) {
      $header = \@columns;
      next;
    }
    
    my $id = $columns[0];
    for (my $i =1; $i< scalar(@columns); $i++) {
      my $outputCol;
      if ($hasHeader) {
        $outputCol = $inFile."_".$header->[$i];
      }
      else {
        $outputCol = $inFile."_".$i;
      }
      $fileHash->{$id}->{$outputCol} = $columns[$i];
      $outputColsHash->{$outputCol} = 1;
    }
  }
}
close INFILE;

open (OUT, ">$output_file") or die "Unable to open output file $output_file for writing : $!";
my @outputHeaders = sort(keys(%$outputColsHash));
print OUT join("\t", @outputHeaders)."\n";
for my $key (keys %{$fileHash}) {
  my $outline = $key;
  for my $outputHeader (@outputHeaders){
    $outline = $outline."\t".$fileHash->{$key}->{$outputHeader};
  }
  print OUT $outline."\n";
}
close OUT
