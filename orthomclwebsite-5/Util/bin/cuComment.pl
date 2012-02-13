#! @perl@

=pod

=head1 Purpose

Make standard comments for Perl and other languages.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

use lib "$ENV{GUS_HOME}/lib/perl";

use CBIL::Util::EasyCsp;

# ========================================================================
# --------------------------- Global Variables ---------------------------
# ========================================================================

our %CommentChars = ( 'perl'  => [ '#',        '' ],
                      'tex'   => [ '%',        '' ],
                      'cpp'   => [ '//',       '' ],
                      'c'     => [ '/*',     '*/' ],
                      'xml'   => [ '<!--',  '-->' ],
                      'html'  => [ '<!--',  '-->' ],
                      'basic' => [ 'REM',      '' ],
                      'sql'   => [ '/*',     '*/' ],
		      'r'     => [ '###',      '' ],
                      ''      => [ '',         '' ],
                    );

our %MinorFill    = ( 'xml'  => '.',
                      'html' => '.',
                    );

# ========================================================================
# ----------------------------- Trivial Body -----------------------------
# ========================================================================

run(cla());

# ========================================================================
# --------------------------- Basic Functions ----------------------------
# ========================================================================

# --------------------------------- run ----------------------------------

sub run {
   my $Cla = shift || cla();

   my @texts  = $Cla->{Multiple} ? @ARGV : join(' ', @ARGV);

   my $td     = scalar localtime;
   my $user   = $ENV{USER};

   foreach my $text (@texts) {

      $text      =~ s/%d/$td/g;
      $text      =~ s/%u/$user/g;

      my $text_n = length $text;
      my $pad_n  = int(($Cla->{Width} - $text_n) / 2) - 1;

      my $lPad   = $Cla->{MinorFill} x $pad_n;
      my $rPad   = $Cla->{MinorFill} x $pad_n; $rPad .= $Cla->{MinorFill} if $text_n % 2 == 1;

      my $head   = $CommentChars{$Cla->{Language}}->[0];
      my $tail   = $CommentChars{$Cla->{Language}}->[1];
      my $section = $Cla->{Section} ? $Cla->{MajorFill} x $Cla->{Width} : undef;

      output($head, $section, $tail) if $Cla->{Section};
      output($head, $lPad, $text, $rPad, $tail );
      output($head, $section, $tail) if $Cla->{Section};
   }
}

# --------------------------------- cla ----------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   (
    [ { h => 'format for this language',
        t => CBIL::Util::EasyCsp::StringType(),
        e => [ sort keys %CommentChars ],
        o => 'Language',
        d => 'perl',
      },

      { h => 'add section lines',
        t => CBIL::Util::EasyCsp::BooleanType(),
        o => 'Section',
      },

      { h => 'produce a comment that is this wide, excluding delimiters',
        t => CBIL::Util::EasyCsp::IntType(),
        o => 'Width',
        d => 72,
      },

      { h => 'minor fill character',
        t => CBIL::Util::EasyCsp::StringType(),
        o => 'MinorFill',
      },

      { h => 'minor fill character',
        t => CBIL::Util::EasyCsp::StringType(),
        o => 'MajorFill',
        d => '=',
      },

      { h => 'treat words as separate comments',
        t => CBIL::Util::EasyCsp::BooleanType(),
        o => 'Multiple',
      },

    ],
    'make nicely formatted comments in a standard format for a variety of languages',
   ) || exit 0;

  if (not defined $Rv->{MinorFill}) {
     $Rv->{MinorFill} = $MinorFill{$Rv->{Language}} || '-';
  }

  return $Rv;
}

# -------------------------------- output --------------------------------

sub output {

   my $text = join(' ', grep { length $_ > 0 } @_);

   print "$text\n";
}

