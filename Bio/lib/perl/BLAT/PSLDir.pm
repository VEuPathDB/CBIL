package CBIL::Bio::BLAT::PSLDir;

use strict;

# read a directory containing BLAT alignment output files,

sub new {
    my ($class, $pslDir) = @_;

    my $self = { pslDir=>$pslDir };
    $self->{pslFiles} = &_readPSLDir($pslDir);
    bless($self, $class);
}

sub getPSLDir {
    my $self = shift;
    return $self->{pslDir};
}

sub getPSLFiles {
    my ($self) = @_;

    my $pslDir = $self->getPSLDir;
    my @fs;
    foreach (@{ $self->{pslFiles} }) { push @fs, "$pslDir/$_"; }

    @fs;
}

sub stripExtraHeaders {
    my ($self, $psl_file) = @_;

    my $pslDir = $self->getPSLDir;
    my @fs;
    if ($psl_file) {
	push @fs, $psl_file; 
    } else {
	foreach ($self->getPSLFiles) { push @fs, $_; }
    }

    foreach (@fs) { &strip($_);  }
}

# file scoped subs

sub _readPSLDir {
    my ($pslDir) = @_;

    opendir(PD, $pslDir) or die "could not opendir $pslDir";
    my @all = readdir(PD);
    closedir(PD);

    my @psl_files = grep(/\.psl/, @all);
    \@psl_files;
}

sub strip {
  my ($boFile) = @_;

  my $n = 0;
  open IN, $boFile;
  open OUT, ">$boFile.tmp";

  while (<IN>) {
    print OUT;
    last if (++$n == 5);
  }

  my $found = 0;
  while (<IN>) {
    if (/^psLayout version/) { $found = 1; next; }
    next if (/^\s*$/);
    next if (/^\s*match/);
    next if (/^\-*$/);
    print OUT;
  }

  close OUT; close IN;
  if ($found) { `mv $boFile.tmp $boFile`; } else { `/bin/rm -f $boFile.tmp`; }
}

1;
