package CBIL::Util::Ini;

use strict;

use Parse::RecDescent;

sub setParser { $_[0]->{_parser} = $_[1] }
sub getParser { $_[0]->{_parser} }

=pod

=head1 Ini file parser

The default grammar for parsing ini files will return a simple hash object.  You can also override the grammar if your ini file is different.  In the default grammar, header lines have square brackets.  Those '[' and ']' are not allowed on other lines

 my $iniFileParser = CBIL::Util::Ini->new();
 my $out = $ini->parseFile($file);

=over 4

=item Input 

  [section]
  key1:
  key2: 1
  key2: 2
  key3: test
  key3: test,


  [section2]
  key1=
  key2= 1
  key2= 2
  key3= test

=item Output

 {'section' => {'key2' => ['1','2'],
                'key3' => ['test']
               }
 }

=back

=cut

my $DEFAULT_GRAMMAR = q(
file: section(s)
{ my %file;
  foreach (@{$item[1]}) {
    $file{$_->[0]} = $_->[1];
  }
  \%file;
}
section: header assign(s)
{ my %sec;
  foreach (@{$item[2]}) {
    push @{$sec{$_->[0]}}, $_->[1] if($_->[1]);
  }
[ $item[1], \%sec]
}
header: '[' /[-\w]+/ ']' { $item[2] }
assign: /[^\n^\[^\]]+/
{ my ($key, @rest) = split(':', $item[1]);
[$key, join(":", @rest)] 
}
);

sub new {
    my ($class, $grammarOverride) = @_;

    my $self = {};
    bless($self, $class);
    my $grammar = $grammarOverride ? $grammarOverride : $DEFAULT_GRAMMAR;

    my $parser = Parse::RecDescent->new($grammar);
    $self->setParser($parser);

    return $self;
}

sub parseFile {
  my ($self, $file) = @_;

  open(FILE, $file) or die "Cannot open file $file for reading: $!";

   my $text;
   {
     $/ = undef;
     $text = <FILE>;
   }

  my $parser = $self->getParser();
  return $parser->file($text);
}


1;

