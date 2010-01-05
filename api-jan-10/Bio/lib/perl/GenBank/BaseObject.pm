
package CBIL::Bio::GenBank::BaseObject;

use strict 'vars';

sub new {
  my $C = shift;
  my $A = shift;

  my $m = bless {}, $C;

  $m->setValidity(1);
  $m->parse($A->{ios}) if defined $A->{ios};

  # return the new me
  $m;
}

sub setValidity { $_[0]->{_V_} = $_[1]; $_[0] }
sub setString   { $_[0]->{STR} = $_[1]; $_[0] }

sub getValidity { $_[0]->{_V_} }
sub getString   { $_[0]->{STR} }

sub reportError {
  my $M   = shift;
  my $IOS = shift;
  my $T   = shift;

  print join( "\t",
              'ERR',
              'LINE='. $IOS->getLineNumber(),
              $T,
              @_,
            ), "\n";

}

sub parseAsText {
  my $M   = shift;
  my $TAG = shift;
  my $IOS = shift;
  my $EAQ = shift;

  my $val = $M->extractItem($TAG,$IOS,$EAQ);

  $M->setString(join( ' ',@$val));

  $val
}

sub extractItem {
  my $M   = shift;
  my $TAG = shift;
  my $IOS = shift;
  my $EAQ = shift;
  my $JOI = shift;

  my @lines;
  my $line;

  # get first line
  $line = $IOS->getLine();
  if ( $line =~ /^($TAG\s*)(.+)/ ) {

    # save the rest of the line
    my $rest = $2;

    # save this length to compare with later white space
    my $indent = length($1) - 2;

#    print join( "\t", 'eI', $TAG, $indent, $line );

    chomp $rest;
    push( @lines,$rest );

    # get more lines.
    while ( my $line = $IOS->getLine() ) {

      my $stop_b = 0;

      # is left justified we stop
      if ( $line =~ /^\S/ ) { $stop_b = 1 }

      # is a qualifier and we care then stop
      if ( $EAQ == 1 && $line =~ /^\s+\// ) { $stop_b = 1 }

      # not indented enough then stop
      if ( $line =~ /^(\s+)/ ) {
        my $lead = $1;
        if ( length($lead) < $indent ) { $stop_b = 1 }
      }

      # that's enough
      if ( $stop_b ) {
        $IOS->putLine($line);
        last;
      }

      # clean the line and collect it.
      else {
#        print join( "\t", 'eI..', $TAG, $line );
        chomp $line;
        push( @lines, substr( $line, 12 ) );
      }
    }

    if ( defined $JOI ) {
      my $v = join( $JOI, @lines );
      $v =~ s/\s+/ /g;
      return $v;
    }
    else {
      return \@lines;
    }
  }

  # line didn't match tag, put it back and return empty list.
  else {
    $IOS->putLine($line);
    return [];
  }
}

1;

__END__


