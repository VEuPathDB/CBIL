#! @perl@

=pod

=head1 Purpose

Runs classes that are applications.  They must have a C<new> method
that can initialize the program, typically using
C<CBIL::Util::EasyCsp>, and a run method.

=cut

$| = 1;

my $class = shift @ARGV;

eval <<MiniBody;

  require $class;
  $class->new()->run();

MiniBody

if ($@) {
   die $@;
}
