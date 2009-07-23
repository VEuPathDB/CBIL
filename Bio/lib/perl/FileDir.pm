package CBIL::Bio::FileDir;

use strict;


sub new {
  my ($class, $dir) = @_;
  my $self = {};
  bless $self;

  my @fileArr;

  opendir(DIR, $dir) || die "Can't open directory '$dir'";

  while (defined (my $file = readdir (DIR))) {
    next if ($file eq "." || $file eq "..");
    push(@fileArr,$file);
  }

  $self->{count} = @fileArr;

  $self->{index} = \@fileArr;

  return $self;
}

sub getCount{
  my ($self) = @_;

  return $self->{count};
}

sub getFiles {
    my ($self, $start, $stop) = @_;

    my @files;

    for (my $i=$start-1;$i<$stop;$i) {
      push (@files, $self->{index}->[$i]);
    }

    return \@files;
}


1;
