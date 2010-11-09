#! @perl@

=pod

=head1 Description

Projects and optionally reformats requested columns from a tab- (or
other) delimited stream.  Very similar to cut, but maintains the
user-specified order of the projected fields.  Can also intersperse
constants or transform values with Perl snippets.

=cut

# ========================================================================
# ----------------------------- Declaration ------------------------------
# ========================================================================

use strict;

use CBIL::Util::EasyCsp;
use CBIL::Util::Utils;

# ========================================================================
# --------------------------------- Code ---------------------------------
# ========================================================================

$| = 1;

my $Cla = CBIL::Util::EasyCsp->new
    ( [ { h => 'select these 1-based columns: column[:format]',
          t => StringType(),
          l => 1,
          o => 'Columns',
          d => '1',
        },

        { h => 'input stream is delimited by this RX',
          t => StringType(),
          o => 'InDelimRx',
          d => "\t",
        },

        { h => 'delimit output with this string.  Use TAB or NL for tabs or new lines.',
          t => StringType(),
          o => 'OutDelim',
          d => "\t",
        },

        { h => 'just print the unique combos seen',
          t => BooleanType(),
          o => 'Unique',
        },

        { h => 'use the first line as a title line',
          t => BooleanType(),
          o => 'UseTitles',
        },

        { h => 'skip this many lines before processing rows',
          t => IntType(),
          o => 'skipN',
        },
      ],

      "$0 [OPTIONS] --columns COLUMS < TAB-DELIM > TAB-DELIM"
    );

# ========================================================================
# ------------------------------ Main Body -------------------------------
# ========================================================================

my $debugBool     = $Cla->debug();

my $useTitlesBool = $Cla->UseTitles();

=pod

=head2 Column Specification Formats

You can specify columns in a few different formats.

* N - a single 1-based column.

* N-N - a range of 1-based columns.

* "..." - a constant

* (...) - a bit of perl code, use #N to represent columns.

* ... - a string which is used to match against the titles.

The specification can also contain a trailing format specification, e.g.,

  4%0.3f

which will print the contents of column 4 in floating point format
with three significant digits.

=cut

my $INDEX_constant = 0;
my $INDEX_function = -1;

# assume string format, but pick up other requests
my @Cols_h;
foreach my $spec (@{$Cla->{Columns}}) {

  my $format = '%s';
  if ($spec =~ /(%.+)/) {
    $format = $1;
    $spec =~ s/%.+//;
  }

  my @indices;
  my $isaTitle = undef;

  # number
  if ($spec =~ /^\d+$/) {
    @indices = ($spec);
  }

  # range of numbers
  elsif ($spec =~ /^(\d+)-(\d+)$/) {
    @indices = ($1 .. $2);
  }

  # quoted string literal
  elsif ($spec =~ /^"(.*)"$/) {
    $format = $1;
    @indices = ($INDEX_constant);
  }

  # a piece of code - replace #N with @_[N-1]
  elsif ($spec =~ /^\((.+)\)$/) {
    my $perl = $1;
    $perl =~ s/#(\d+)/\$_\[$1\]/g;
    my $code = sub {
      $debugBool && CBIL::Util::Utils::timestampLog(',', 'CODE', @_);
      eval $perl
    };
    @indices = ($code);
  }

  # title name - we will need to look these up later one.
  else {
    @indices = ($spec);
    $isaTitle = 1;
    $useTitlesBool = 1;
  }

  # save these for later
  foreach (@indices) {
    push(@Cols_h, { Index => $_, Format => $format, Title => $isaTitle });
  }
}

# process input stream
# ......................................................................

# ------------------------------ skip lines ------------------------------

for (my $skip_i = 0; $skip_i < $Cla->skipN(); $skip_i++) {
  $_ = <>;
}

# ------------------------ get titles (optional) -------------------------

# extract titles and make a dictionary of column title to 0-index.
my %titles;
if ($useTitlesBool) {
  my $titles    = <>;  chomp $titles;
  my @titles    = split /$Cla->{InDelimRx}/, $titles;
  my $i         = 0;
  %titles       = map { ( $titles[$i] => $i++ ) } @titles;
  my $errorBool = undef;

  foreach (@Cols_h) {
    if (defined (my $index =  $titles{$_->{Index}})) {
      $_->{Index} = $index + 1;
    }
    else {
      print STDERR "Column title '$_->{Index}' is not defined.\n";
      $errorBool = 1;
    }
  }

  exit(0) if $errorBool;
}

# --------------------- process the rest of the file ---------------------


my $inDelimRx  = $Cla->InDelimRx();
my $outDelim   = $Cla->OutDelim();
$outDelim =~ s/TAB/\t/g;
$outDelim =~ s/NL/\n/g;

my $uniqueBool = $Cla->Unique();
my %seen_b = ();

my $value;
my @cols;
my $text;

my $line = 0;

while ( <> ) {
  $line++;

  chomp;
  @cols = ($line, split(/$inDelimRx/, $_));

  $debugBool && CBIL::Util::Utils::timestampLog('COLS', @cols);

  $text = join($outDelim,
               map {
                 $value = ref $_->{Index} ? $_->{Index}->(@cols) : $cols[$_->{Index}];
                 sprintf($_->{Format}, $value)
               } @Cols_h
              );

  # just print it.
  if (!$uniqueBool) {
    print "$text\n";
  }

  # only print if we've never seen this before.
  elsif (!$seen_b{$text}++) {
    print "$text\n";
  }
}
