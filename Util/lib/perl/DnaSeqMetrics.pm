package CBIL::Util::DnaSeqMetrics;

require Exporter;
@ISA = qw(Exporter);
@EXPORT= qw(getCoverage getMappedReads getNumberMappedReads getGenomeFile runSamtoolsStats);

use strict;
use warnings;
use CBIL::Util::Utils;
use Data::Dumper;

#calc coverage separately as samtools coverage is screwy
sub getCoverage {
    my ($analysisDir, $bamFile) = @_;
    my $genomeFile = &getGenomeFile($bamFile, $analysisDir);
    my @coverage = split(/\n/, &runCmd("bedtools genomecov -ibam $bamFile -g $genomeFile"));
    my $genomeCoverage = 0;
    my $count = 0;
    foreach my $line (@coverage) {
        if ($line =~ /^genome/) {
            my ($identifier, $depth, $freq, $size, $proportion) = split(/\t/, $line);
            $genomeCoverage += ($depth*$freq);
            $count += $freq;
        }
    }
    return ($genomeCoverage/$count);
}

sub runSamtoolsStats {
    my $bamFile = shift;
    my $statsHash = {};
    foreach my $line (split(/\n/, &runCmd("samtools stats $bamFile | grep ^SN | cut -f 2-"))) {
        my ($attr, $value) = split(/\t/, $line);
        $attr =~ s/\:$//;
        if ($attr eq "raw total sequences" || $attr eq "reads mapped" || $attr eq "average length") {
            $statsHash->{$attr} = $value;
        }
    }
    return $statsHash;
}

#required for coverage
sub getGenomeFile {
    my ($bamFile, $workingDir) = @_;
    open (G, ">$workingDir/genome.txt") or die "Cannot open genome file $workingDir/genome.txt for writing\n";
    my @header = split(/\n/, &runCmd("samtools view -H $bamFile"));
    foreach my $line (@header) {
        if ($line =~ m/\@SQ\tSN:/) {
            $line =~ s/\@SQ\tSN://;
            $line =~ s/\tLN:/\t/;
            print G "$line\n";
        }
    }
    close G;
    return "$workingDir/genome.txt";
}
    

1;
