package CBIL::Util::DnaSeqMetrics;

require Exporter;
@ISA = qw(Exporter);
@EXPORT= qw(getCoverage getMappedReads getNumberMappedReads getGenomeFile);

use strict;
use warnings;
use CBIL::Util::Utils;
use Data::Dumper;

# leave this sub - we will calc coverage separately as we don't want to use samtools
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
    #if we are making an object, we don't need to store the stats file
    my $statsHash = {};
    foreach my $line (split(/\n/, &runCmd("samtools stats $bamFile | grep ^SN | cut -f 2-"))) {
       # print Dumper $line;
       # remove ' from attr and value as they are created - the below should work.  Could also remove : from attr here
        my ($attr, $value) = split(/\t/, $line);
        if ($attr eq "raw total sequences:" || $attr eq "reads mapped:" || $attr eq "average length:") {
            $statsHash->{$attr} = $value;
        }
    }
    print Dumper $statsHash;
    return $statsHash;
}

sub getMappedReads {
    my $bamFile = shift;
    my $mappedReads = &getNumberMappedReads($bamFile);
    my $totalReads = &runCmd("samtools view $bamFile | wc -l");
    return ($mappedReads/$totalReads);
}

sub getNumberMappedReads {
    my $bamFile = shift;
    my $mappedReads = &runCmd("samtools view -F 0x04 -c $bamFile");
    return ($mappedReads);
}

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
