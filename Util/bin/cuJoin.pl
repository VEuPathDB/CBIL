#! @perl@ -w

=pod

=head1 Synopsis

  cuJoin.pl [OPTIONS] FILE < STREAM

  cuJoin.pl [OPTIONS] FILE OTHER_FILES

=head2 Purpose

Implements a simple join operation between two or more files.

The FILE is read in and indexed using the values in column --FileCol.
Then the STREAM or OTHER_FILES are read and are joined with rows from
FILE if their --StreamCol value matches a row in FILE.  If --Anti is
used, then STREAM rows that do not match are output.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

use FileHandle;

use CBIL::Util::EasyCsp;

# ========================================================================
# --------------------------- Main Subroutines ---------------------------
# ========================================================================

$| = 1;

run(cla());

# --------------------------------- run ----------------------------------

sub run {
   my $Cla = shift;

   my $_f = shift @ARGV;

   # column in file
   my $fileCol_i = $Cla->{FileCol};
   $fileCol_i--;

   # column in input stream
   my $streamCol_i = $Cla->{StreamCol};
   $streamCol_i--;

   # print the things that don't join
   my $not = $Cla->{Anti};

   # ........................................
   # read the file and build a cache on key
   # ........................................

   # key {}-> ref to list of matching rows
   my $tbl = {};

   my $_fh = FileHandle->new($_f =~ /\.(Z|gz)$/ ? "zcat $_f|" : "<$_f");
   while (<$_fh>) {
      chomp;
      my $cols = [ split /\t/ ];
      push( @{ $tbl->{ $cols->[ $fileCol_i ] } }, $cols );
   }
   $_fh->close if $_fh;

   # flow through stream
   # ........................................

   while (<>) {
      chomp;

      # split on tab to get columns
      my @cols = split /\t/;

      # in NOT mode; look for novel ids
      if ($not) {
         print "$_\n" unless $tbl->{$cols[$streamCol_i]};
      }

      # JOIN mode; report all matches
      else {
         foreach my $row (@{$tbl->{$cols[$streamCol_i]}}) {
            print join( "\t", @cols, @$row ), "\n";
         }
      }
   }
}

# --------------------------------- cla ----------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   ( [ { h => 'join on this column in the listed file',
         t => CBIL::Util::EasyCsp::IntType(),
         o => 'FileCol',
         d => 1,
       },

       { h => 'join on this column in the stream or secondary files',
         t => CBIL::Util::EasyCsp::IntType(),
         o => 'StreamCol',
         d => 1,
       },

       { h => 'report stream lines that do not join',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'Anti',
       },
     ],
     'joins (or not) a file and a stream of tab-delimited rows'
   ) || exit 0;

   return $Rv;
}


