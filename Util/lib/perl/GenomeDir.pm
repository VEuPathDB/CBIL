package CBIL::Util::GenomeDir;

use strict;

# read a directory containing genomic sequence,
#  on fasta file per chr, named as in chr9[_random].fa

sub new {
    my ($class, $genomeDir) = @_;

    my $self = { genomeDir=>$genomeDir };
    $self->{chrs} = &_readChromosomes($genomeDir);
    bless($self, $class);
}

sub getGenomeDir {
    my $self = shift;
    return $self->{genomeDir};
}

sub getChromosomes {
    my ($self) = @_;
    return @{ $self->{chrs} };
}

sub getChromosomeFiles {
    my ($self, $outFile) = @_;

    my $gDir = $self->getGenomeDir;
    my @chrs = $self->getChromosomes;

    return map { $gDir . '/chr' . $_ . '.fa' } @chrs;
}

sub makeChromosomeList {
    my ($self, $outFile) = @_;

    my $gDir = $self->getGenomeDir;
    my @chrs = $self->getChromosomes;

    if ($outFile) {
	open(F, ">$outFile") or die "could not open $outFile for write";
    }

    foreach my $c (@chrs) {
	if ($outFile) {
	    print F "$gDir/chr${c}.fa\n";
	} else {
	    print "$gDir/chr${c}.fa\n";
	}
    }

    close F if $outFile;
}

sub makeGusVirtualSequenceXml {
    my ($self, $taxon_id, $ext_db_rel, $outFile) = @_;

    my $gDir = $self->getGenomeDir;
    my @chrs = $self->getChromosomes;
    my %chrs; foreach (@chrs) { $chrs{$_} = 1; }

    my $max = 100;
    my $chr;
    my @ordered_chrs;

    # regular chromosome numbers:
    for ($chr=1; $chr<=$max; $chr++) {
	push @ordered_chrs, $chr if $chrs{$chr};
    }
    # X, Y, 'M', 'Un'
    foreach $chr ('X', 'Y', 'M', 'Un', 'X_random', 'Y_random', 'M_random', 'Un_random') {
	push @ordered_chrs, $chr if $chrs{$chr};
    }
    # random nerds
    for (my $i=1; $i<=$max; $i++) {
	$chr = $i . '_random';
	push @ordered_chrs, $chr if $chrs{$chr};
    }

    my $xml = &_getGusXMLStr(\@ordered_chrs, $taxon_id, $ext_db_rel);

    if ($outFile) {
	open F, ">$outFile" or die "could not open $outFile for write";
	print F $xml;
	close F;
    }
    $xml;
}

# file scoped subs

sub _getGusXMLStr {
    my ($ordered_chrs, $taxon_id, $ext_db_rel_id) = @_;

    my $chr_ord_num = 0;
    my $res;
    foreach my $chr (@$ordered_chrs) {
        $chr_ord_num++;
        $res .= "<DOTS::VirtualSequence>\n";
	$res .= "  <sequence_version>1</sequence_version>\n";
        $res .=  "  <sequence_type_id>3</sequence_type_id>\n";
        $res .=  "  <source_id>chr$chr</source_id>\n";
        $res .=  "  <external_database_release_id>$ext_db_rel_id</external_database_release_id>\n";
        $res .=  "  <taxon_id>$taxon_id</taxon_id>\n";
        $res .=  "  <chromosome>$chr</chromosome>\n";
        $res .=  "  <chromosome_order_num>$chr_ord_num</chromosome_order_num>\n";
        $res .=  "</DOTS::VirtualSequence>\n";
    }
    $res;
}

sub _readChromosomes {
    my ($genomeDir) = @_;

    opendir(GD, $genomeDir) or die "could not opendir $genomeDir";
    my @all = readdir(GD);
    closedir(GD);

    my @chrs;
    my @chr_files = grep(/chr\S+\.(fa|fasta)/, @all);
    foreach (@chr_files) {
	push @chrs, $1 if /chr(\S+)\./;
    }
    \@chrs;
}

1;
