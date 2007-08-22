#! @perl@ -w

=pod

=head1 Synopsis

  cuJoin.pl [OPTIONS] FILE < STREAM

  cuJoin.pl [OPTIONS] FILE OTHER_FILES

=head2 Purpose

Implements a simple join operation between two or more files.

The FILE is read in and indexed using the values in column --FileCol.
Then the STREAM or OTHER_FILES are read and are joined with rows from
FILE if their --StreamCol value(s) matches a row in FILE.  If --Anti
is used, then STREAM rows that do not match are output.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

use FileHandle;

use CBIL::Util::EasyCsp;
use CBIL::Util::Files;

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

   # print lines even if they don't join
   my $outer_b = $Cla->{Outer};

   # ........................................
   # read the file and build a cache on key
   # ........................................

   # key {}-> ref to list of matching rows
   my %tbl = ();

   my $_fh = CBIL::Util::Files::SmartOpenForRead($_f);
   while (<$_fh>) {
      chomp;
      my $cols = [ split /\t/ ];
      #push( @{ $tbl{ $cols->[ $fileCol_i ] } }, $cols );
      my $key  = extractJoinKey($Cla, $Cla->{FileCol}, $cols);
      push( @{$tbl{$key}}, $cols );
   }
   $_fh->close if $_fh;

   # flow through stream
   # ........................................

   while (<>) {
      chomp;

      # split on tab to get columns
      my @cols = split /\t/;

      # get a key from the stream cols.
      my $key = extractJoinKey($Cla, $Cla->{StreamCol}, \@cols);

      # in NOT mode; look for novel ids
      if ($not) {
         #print "$_\n" unless $tbl{$cols[$streamCol_i]};
         print "$_\n" unless $tbl{$key};
      }

      # JOIN mode; report all matches
      else {

	if (my $_matching = $tbl{$key}) {
	  foreach my $row (@{$tbl{$key}}) {
            print join( "\t", @cols, @$row ), "\n";
	  }
	}
	elsif ($outer_b) {
	  print join("\t", @cols), "\n";
	}
      }
   }
}

# --------------------------------- cla ----------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   ( [ { h => 'join on this column in the listed file',
         t => CBIL::Util::EasyCsp::IntType(),
	 l => 1,
         o => 'FileCol',
         d => 1,
       },

       { h => 'join on this column in the stream or secondary files',
         t => CBIL::Util::EasyCsp::IntType(),
	 l => 1,
         o => 'StreamCol',
         d => 1,
       },

       { h => 'report stream lines that do not join',
         t => CBIL::Util::EasyCsp::BooleanType(),
         o => 'Anti',
       },

       { h => 'do an outer join so that even lines with no matches are passed',
	 t => CBIL::Util::EasyCsp::BooleanType(),
	 o => 'Outer',
       },
     ],
     'joins (or not) a file and a stream of tab-delimited rows'
   ) || exit 0;

   return $Rv;
}

# ========================================================================
# -------------------------- Support Functions ---------------------------
# ========================================================================

# ---------------------------- extractJoinKey ----------------------------

sub extractJoinKey {
   my $Cla  = shift;
   my $Cols = shift;
   my $Data = shift;

   my $Rv = join("\t", map { $Data->[$_-1] } @$Cols);

   return $Rv;
}


