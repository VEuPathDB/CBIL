package CBIL::Bio::FastaFileSequential;

use strict;


sub new {
    my ($class, $fastaFileName) = @_;
    my $self = {};
    bless $self;

    die "Fasta file '$fastaFileName' does not exist or is empty" unless -s $fastaFileName;
    $self->{fastaFileName} = $fastaFileName;
    $self->{cursor} = 0;
    open(FA, $fastaFileName) || die "Can't open fasta file '$fastaFileName'\n";
    $self->initCursor();
    return $self;
}

sub getCount {
    my ($self) = @_;
    if(!defined($self->{count})){
      $self->{count}=0;
      open(IN, $self->{fastaFileName})  || die "Can't open fasta file '$self->{fastaFileName}'\n";
      while (<IN>) {
	$self->{count}++ if /^>/;
      }
      close(IN);
    }
    return $self->{count};
}

# advance into file to the first defline, and remember the defline
sub initCursor {
  my ($self) = @_;
  die "cursor already initialized\n" if $self->{cursor};
    while (<FA>) {
	chomp;
	next if /^\s*$/;  # skip empty lines
	die "Error in fasta file '' on line ${.}.  Expected a line starting with >" unless /^>/;
	$self->{cursorDefLine} = $_;
#        $self->{cursor} = 1;  ## if indexed from  one
        last;
    }
}

##note that this is 0 indexed for both start and end
sub writeSeqsToFile {
    my ($self, $start, $end, $outputFile) = @_;

    die "Error accessing fasta file '$self->{fastaFileName}'.  Not in sequential order.  Cursor=$self->{cursor}.  Requested start=$start\n" unless $start >= $self->{cursor};

    die "Error accessing fasta file '$self->{fastaFileName}'.  Requested start ($start) is > requested end ($end)\n" unless $start <= $end;

    open(OUT, ">$outputFile") || die "Can't open subtask output fasta file '$outputFile'";
    do {
      while (<FA>) {
	if (/^>/) {
          $self->{cursor}++;
          $self->{cursorDefLine} = $_;
        }
      }
    } until $self->{cursor} == $start;

    print OUT "$self->{cursorDefLine}\n";
    while (<FA>) {
	chomp;
#	next if /^\s*$/;  # skip empty lines
	if (/^>/) {
	    $self->{cursor}++;
	    $self->{cursorDefLine} = $_;
            last if($self->{cursor} == $end);
    	}
        print OUT "$_\n";
    }
    close OUT;
}

1;
