#!/usr/bin/perl

use strict;

my @pairFiles = glob("*.pair");

foreach my $pair (@pairFiles) {
  $pair =~ /(.+)\.pair/;
  my $prefix = $1;

  open(PAIR, $pair) or die "Cannot open file $pair for reading: $!";

  my $out = $prefix . ".xys";
  open(OUT, "> $out") or die "Cannot open file $out for writing:$!";

  my $header = <PAIR>;
  print OUT $header;

  my $header2 = <PAIR>;

  my @rows;
  while(<PAIR>) {
    chomp;

    my @a = split(/\t/, $_);

    my $x = $a[5];
    my $y = $a[6];
    my $dat = $a[9];

    my @xys = ($x, $y, $dat);

    push(@rows, \@xys);
  }

  close PAIR;

  my @sorted = sort {$a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] }  @rows;

  print OUT "X\tY\tSIGNAL\tCOUNT\n";

  foreach(@sorted) {
    my $x = $_->[0];
    my $y = $_->[1];
    my $dat = $_->[2];

    print OUT "$x\t$y\t$dat\t1\n";
  }

  close OUT;

}

