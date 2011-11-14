package CBIL::Bio::FastaFileSequential;

use CBIL::Bio::FastaIndex;
use CBIL::Util::TO;
use strict;


sub new {
    my ($class, $fastaFileName) = @_;
    my $self = {};
    bless $self;

    die "Fasta file '$fastaFileName' does not exist or is empty" unless -s $fastaFileName;
    $self->{fastaFileName} = $fastaFileName;
    $self->{cursor} = 0;
    my $fh = open($fastaFileName) || die "Can't open fasta file '$fastaFileName'\n";
    $self->initCursor();

}

sub getCount {
    my ($self) = @_;
    $self->{count}=0;
    open(IN, "$self->{fastaFileName"})  || die "Can't open fasta file '$fastaFileName'\n";
    while (<IN>) {
	$self->{count}++ if /^>/;
    }
    close(IN);
}

# advance into file to the first defline, and remember the defline
sub initCursor {
    my ($self) = @_;
    while (<$fh>) {
	chomp;
	next if /^\s*$/;  # skip empty lines
	die "Error in fasta file '' on line ${.}.  Expected a line starting with >" unless /^>/;
	$self->{cursorDefLine} = $_;
    }
}

sub writeSeqsToFile {
    ($self, $start, $end, $outputFile) = @_;

    die "Error accessing fasta file '$self->{fastaFileName}'.  Not in sequential order.  Cursor=$cursor.  Requested start=$start\n" unless $start == $cursor;

    die "Error accessing fasta file '$self->{fastaFileName}'.  Requested start ($start) is > requested end ($end)\n" unless $start <= $end;

    open(OUT, ">$outputFile") || die "Can't open subtask output fasta file '$outputFile'";
    print OUT "$self->{cursorDefLine}\n";
    while (<$fh>) {
	chomp;
#	next if /^\s*$/;  # skip empty lines
	if (/^>/) {
	    $self->{cursor}++;
	    $self->{cursorDefLine} = $_;
	    last if  $self->{cursor} > $end;
	    print OUT "$_\n";
    	}
    }
}

1;
