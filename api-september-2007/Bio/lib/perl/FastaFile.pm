package CBIL::Bio::FastaFile;

use CBIL::Bio::FastaIndex;
use CBIL::Util::TO;
use strict;


sub new {
    my ($class, $fastaFileName) = @_;
    my $self = {};
    bless $self;

    $self->{count} = 1;  # must be base 1 (0 is a bummer key)

    my $fiArgs = { seq_file => $fastaFileName };
    $self->{fastaIndex} = CBIL::Bio::FastaIndex->new(CBIL::Util::TO->new($fiArgs));

    my $whatever = sub { $self->{count}++ };

    my $ciArgs = {echo => 0, get_key => $whatever};
    $self->{fastaIndex}->createIndex(CBIL::Util::TO->new($ciArgs));

    $self->{count}--;

    return $self;
}

sub getCount {
    my ($self) = @_;
    return $self->{count};

}

# start - index of starting seq (0 based)
# stop  - index of seq to stop before.
sub writeSeqsToFile {
    my ($self, $start, $stop, $fileName) = @_;

    
    $self->{fastaIndex}->open();
    open(F, ">$fileName") || die "Couldn't open fasta file $fileName for writing";
    $stop = $self->{count} if $stop > $self->{count};
    for (my $i=$start+1; $i<$stop+1; $i++) {
	my $gsArgs = {accno => $i };
	my $seq = $self->{fastaIndex}->getSequence(CBIL::Util::TO->new($gsArgs));
	print F "$seq->{hdr}\n";
	print F "$seq->{seq}";
    }
    close(F);
    $self->{fastaIndex}->close();
}

1;
