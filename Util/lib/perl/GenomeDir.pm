package CBIL::Util::GenomeDir;

use strict;
use Bio::SeqIO;
use Carp;

# read a directory containing genomic sequence,
#  on fasta file per chr, named as in chr9[_random].fa

sub new {
    my ($class, $genomeDir, $srcIdRegEx) = @_;

    my $self = { genomeDir=>$genomeDir, srcIdRegEx=>$srcIdRegEx };

    bless($self, $class);
}

sub splitUp {
  my ($self) = @_;

  my $genomeDir = $self->getGenomeDir();
  my $srcIdRegEx = $self->getSrcIdRegEx();

#  opendir(GD, $genomeDir) or die "could not opendir $genomeDir";
#  my @all = readdir(GD);
#  closedir(GD);

#  my @fastaFiles = grep(/\.(fa|fasta)$/, @all);
  my @fastaFiles = $self->getSequenceFiles();
  foreach my $fastaFile (@fastaFiles) {
    $fastaFile = $genomeDir . '/' . $fastaFile;
    my $tempfile = $fastaFile . '.tmp';
    rename($fastaFile, $tempfile);

    # read and parse with BioPerl
    my $fa = Bio::SeqIO->new(-file => $tempfile, '-format' => 'Fasta');

    while (my $entry = $fa->next_seq()) {

      my $id = $entry->id;
      my $desc = $entry->desc;
      my $seq = $entry->seq;

      # parse source id from defline with regex
      my $srcId = $1 if $id =~ /$srcIdRegEx/;

      # if it isn't in the id, look in the desc
      if (! $srcId) {
	my $srcId = $1 if $desc =~ /$srcIdRegEx/;
      }

      confess "Cannot parse source id from defline \"$id $desc\" with regEx $srcIdRegEx"
	if ! $srcId;

      # write out as <src_id>.fasta
      my $outfile = $genomeDir . '/' . $srcId . '.fasta';
      confess "file already exists: $outfile" if -e $outfile;

      open OUT, "> $outfile" or confess "can't open $outfile to write";
      print OUT ">$srcId $id $desc\n$seq\n";
      close OUT;
    }
    system("rm $tempfile");
  }

}

sub getGenomeDir {
    my $self = shift;
    return $self->{genomeDir};
}

sub getSrcIdRegEx {
    my $self = shift;
    return $self->{srcIdRegEx};
}

sub getChromosomes {
  my ($self) = @_;

  confess "It appears that this genome does not have complete chromosomes.  Use getSequencePieces instead."
    if ($self->{srcIdRegEx});

  return $self->getSequencePieces();
}

sub getSequencePieces {
    my ($self) = @_;

    if ( ! $self->{seqs} ) {
      $self->{seqs} = $self->_readSeqPieces($self->getGenomeDir());
    }

    return @{ $self->{seqs} };
}

sub getSequenceFiles {
  my ($self) = @_;

  if (! $self->{sequenceFiles} ) {
    my $genomeDir = $self->getGenomeDir();
    opendir(GD, $genomeDir) or die "could not opendir $genomeDir";
    my @all = readdir(GD);
    closedir(GD);

    my @fastaFiles = map { $genomeDir . '/' . $_ } grep(/\.(fa|fasta)$/, @all);

    $self->{sequenceFiles} = \@fastaFiles;
  }

  return @{$self->{sequenceFiles}};
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
    my ($self, $taxon_id, $ext_db_rel, $outFile, $regEx) = @_;

    my $gDir = $self->getGenomeDir;
    my @seqs = $self->getSequencePieces;

    if ($regEx) {
      my $xml = &_getGusXMLStr(\@seqs, $taxon_id, $ext_db_rel);
      if ($outFile) {
	open F, ">$outFile" or die "could not open $outFile for write";
	print F $xml;
	close F;
      }
      return $xml;
    }

    my @chrs = $self->getChromosomes;
    my %chrs; foreach (@chrs) { $chrs{$_} = 1; }

    my $max = 100;
    my $chr;
    my @ordered_chrs;

    # regular chromosome numbers:
    for ($chr=1; $chr<=$max; $chr++) {
	if ($chrs{$chr}) {
	    push @ordered_chrs, $chr;
	    delete $chrs{$chr};
	}
    }
    # X, Y, 'M', 'Un'
    foreach $chr ('X', 'Y', 'M', 'Un', 'X_random', 'Y_random', 'M_random', 'Un_random') {
	if ($chrs{$chr}) {
	    push @ordered_chrs, $chr;
	    delete $chrs{$chr};
	}
    }
    # random nerds
    for (my $i=1; $i<=$max; $i++) {
	$chr = $i . '_random';
	if ($chrs{$chr}) {
	    push @ordered_chrs, $chr;
	    delete $chrs{$chr};
	}
    }
    # anything remaining
    foreach my $chr (keys %chrs) { push @ordered_chrs, $chr; }

    my $xml = &_getGusXMLStr(\@ordered_chrs, $taxon_id, $ext_db_rel, 'chr');

    if ($outFile) {
	open F, ">$outFile" or die "could not open $outFile for write";
	print F $xml;
	close F;
    }
    $xml;
}

# file scoped subs

sub _getGusXMLStr {
    my ($ordered_chrs, $taxon_id, $ext_db_rel_id, $filePrefix) = @_;

    my $chr_ord_num = 0;
    my $res;
    foreach my $chr (@$ordered_chrs) {
        $chr_ord_num++;
        $res .= "<DOTS::VirtualSequence>\n";
	$res .= "  <sequence_version>1</sequence_version>\n";
        $res .=  "  <sequence_type_id>3</sequence_type_id>\n";
        $res .=  "  <source_id>$filePrefix$chr</source_id>\n";
        $res .=  "  <external_database_release_id>$ext_db_rel_id</external_database_release_id>\n";
        $res .=  "  <taxon_id>$taxon_id</taxon_id>\n";
        $res .=  "  <chromosome>$chr</chromosome>\n";
        $res .=  "  <chromosome_order_num>$chr_ord_num</chromosome_order_num>\n";
        $res .=  "</DOTS::VirtualSequence>\n";
    }
    $res;
}

sub _readSeqPieces {
    my ($self, $genomeDir) = @_;

#    opendir(GD, $genomeDir) or die "could not opendir $genomeDir";
#    my @all = readdir(GD);
#    closedir(GD);

    my @seqs;
#    my @seq_files = grep([^/]+\.(fa|fasta)/, @all);
    my @seq_files = $self->getSequenceFiles();
    foreach (@seq_files) {
	push @seqs, $1 if /([^\/]+)\.(fa|fasta)$/;
    }
    \@seqs;
}

1;
