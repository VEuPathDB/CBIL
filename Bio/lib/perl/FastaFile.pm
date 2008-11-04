package CBIL::Bio::FastaFile;

use CBIL::Bio::FastaIndex;
use CBIL::Util::TO;
use strict;


sub new {
    my ($class, $fastaFileName) = @_;
    my $self = {};
    bless $self;

    my $fiArgs = { seq_file => $fastaFileName };

    ##want to test to see if there is already a valid index .. if so, do not recreate rather use existing
    my @ls = `ls -rt $fastaFileName $fastaFileName.db`;

    map { chomp } @ls;
    if (scalar(@ls) != 2 || $ls[0] ne $fastaFileName) { 
#      print STDERR "failed time stamp test\n";
      $self->{fastaIndex} = CBIL::Bio::FastaIndex->new(CBIL::Util::TO->new($fiArgs));
      $self->runCreateIndex();
    }else {  ##already have an appropriate index file so check to see that counts are the same... if so, don't reindex 
#      $fiArgs->{index_file} = "$fastaFileName.db";
      $self->{fastaIndex} = CBIL::Bio::FastaIndex->new(CBIL::Util::TO->new($fiArgs));
      $self->{fastaIndex}->open();
      ##count sequences in file
      my $ctSeqsFromFile = `fgrep -c '>' $fastaFileName`;
      chomp $ctSeqsFromFile;
#      print STDERR "From file = $ctSeqsFromFile\nFrom index = ".$self->{fastaIndex}->getCount()."\n";
      
      if($ctSeqsFromFile != $self->{fastaIndex}->getCount()){
        print "Creating index for $fastaFileName (may take a while)\n";
        $self->runCreateIndex();
      }else{
        print "Index exists .. using $fastaFileName.db\n";
        $self->{count} = $self->{fastaIndex}->getCount();
      }
    }



    return $self;
}

sub runCreateIndex {
  my($self) = @_;
  $self->{count} = 1;  # must be base 1 (0 is a bummer key)
  my $whatever = sub { $self->{count}++ };
  my $ciArgs = {echo => 0, get_key => $whatever};
  $self->{fastaIndex}->createIndex(CBIL::Util::TO->new($ciArgs));
  $self->{count}--;
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
