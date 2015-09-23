package CBIL::ISA::Commentable;

use strict;
use CBIL::ISA::Comment;

sub getComments {
  my ($self) = @_;

  return $self->{_comments};
}


sub new {
  my ($class, $args) = @_;

  my $commentString = "_comment";

  my @keys = grep {!/$commentString/} keys%{$args};
  my @commentKeys = grep {/$commentString/} keys%{$args};

  my $obj = {};
  foreach my $key (@keys) {
    $obj->{$key} = $args->{$key};
  }

  foreach my $ck (@commentKeys) {
    my $commentValues = $args->{$ck};
    next unless $commentValues;

    $ck =~ m/$commentString\[(.+)\]/;
    my $comment = CBIL::ISA::Comment->new({qualifier => $1, values => $commentValues});
    push @{$obj->{_comments}}, $comment;
  }

  return bless $obj, $class;
}


1;
