#! @perl@

=pod

=head1 Usage

  cuRun.pl APP_CLASS [OPTIONS]

You B<must> supply a Perl package that implements the C<APP_CLASS>
'interface' which consists of a C<new>, C<init>, and C<run> method.

=head1 Purpose

Runs classes that are applications.  They must have a C<new> method
that can initialize the program, typically using
C<CBIL::Util::EasyCsp>, and a run method.

An easy way to make an application is to subclass from
C<CBIL::Util::App>.

=cut

$| = 1;

# at least got a class to run
if (scalar @ARGV) {
   my $class = shift @ARGV;

   eval <<MiniBody;

     require $class;
     $class->new()->run();

MiniBody

   if ($@) {
      die $@;
   }
}

# nothing; let 'em know how we work around here.
else {
   system "pod2text $0";
}
