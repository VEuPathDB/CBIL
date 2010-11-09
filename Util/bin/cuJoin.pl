#! @perl@ -w

=pod

=head1 Synopsis

  cuJoin.pl [OPTIONS] FILE < STREAM

  cuJoin.pl [OPTIONS] FILE OTHER_FILES

=head2 Purpose

The program mplements a simple join operation between two or more
files.  The program will append columns from matching lines in FILE to
those read from STREAM or OTHER_FILES.  A line will be printed
multiple times if there are multiple matches.

=head2 Details

The FILE is read in and indexed using the values in column
C<--FileCol>.  Then the STREAM or OTHER_FILES are read and are joined
with rows from FILE if their C<--StreamCol> value(s) matches a row in
FILE.

If C<--Anti> is used, then STREAM rows that do not match are output.

If C<--caseInsensitive> is set then the keys are compared without
regard to case, i.e., the program converts them to lower case prior to
the comparison.

Normally the colums from the STREAM are printed to the left of the
FILE columns.  If C<--fileColumnsFirst> is set then the positions are
reversed.

If C<--Outer> is used then STREAM rows are printed even if there is no
matching FILE row.  If C<--MissingValues> is set then that list is
used to fill in.

If not all of the colums in the FILE are of interest, then use
C<--projectFileColumns> to list ones of interest.

All column indices are 1-based.

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

   my $caseInsensitiveBool  = $Cla->caseInsensitive();

   my $fileColumnsFirstBool = $Cla->fileColumnsFirst();

   # print the things that don't join
   my $antiBool = $Cla->Anti();

   # print lines even if they don't join
   my $outerBool   = $Cla->Outer();
   my @missingVals = $Cla->MissingValues();

   # project these colums from the file
   my @projectFileCols = map { $_ - 1 } @{$Cla->projectFileColumns()};

   # ........................................
   # read the file and build a cache on key
   # ........................................

   # key {}-> ref to list of matching rows
   my %tbl = ();

   my $_fh = CBIL::Util::Files::SmartOpenForRead($_f);
   while (<$_fh>) {
      chomp;
      my $cols = [ split /\t/ ];
      my $key  = extractJoinKey($Cla, $Cla->{FileCol}, $caseInsensitiveBool, $cols);
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
      my $key = extractJoinKey($Cla, $Cla->{StreamCol}, $caseInsensitiveBool, \@cols);

      # in NOT mode; look for novel ids
      if ($antiBool) {
         #print "$_\n" unless $tbl{$cols[$streamCol_i]};
         print "$_\n" unless $tbl{$key};
      }

      # JOIN mode; report all matches
      else {

	if (my $_matching = $tbl{$key}) {
	  foreach my $row (@{$tbl{$key}}) {

	    my @row = @$row;
	    if (@projectFileCols >= 1) {
	      @row = map { $row[$_] } @projectFileCols;
	    }



	    if ($fileColumnsFirstBool) {
	      print join( "\t", @row, @cols ), "\n";
	    }
	    else {
	      print join( "\t", @cols, @row ), "\n";
	    }
	  }
	}
	elsif ($outerBool) {
	  print join("\t", @cols, @missingVals), "\n";
	}
      }
   }
}

# --------------------------------- cla ----------------------------------

sub cla {
  my $Rv = CBIL::Util::EasyCsp->new
    ( [ { h => 'join on this column in the listed file',
	  t => IntType(),
	  l => 1,
	  o => 'FileCol',
	  d => 1,
	},
	
	{ h => 'join on this column in the stream or secondary files',
	  t => IntType(),
	  l => 1,
	  o => 'StreamCol',
	  d => 1,
	},

       { h => 'report stream lines that do not join',
         t => BooleanType(),
         o => 'Anti',
       },

       { h => 'do an outer join so that even lines with no matches are passed',
	 t => BooleanType(),
	 o => 'Outer',
       },

	{ h => 'use these values for missing values when doing an outer join',
	  t => StringType(),
	  l => 1,
	  o => 'MissingValues',
	},

       { h => 'output file columns first',
	 t => BooleanType(),
	 o => 'fileColumnsFirst',
	 d => 0,
       },

	{ h => 'project these columns from file',
	  t => IntType(),
	  l => 1,
	  o => 'projectFileColumns',
	},

	{ h => 'match row keys in a case-INsensitive manner',
	  t => BooleanType(),
	  o => 'caseInsensitive',
	},

	{ h => 'print rows in file that were not matched',
	  t => BooleanType(),
	  o => 'LeftOvers',
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
   my $Cla    = shift;
   my $Cols   = shift;
   my $CiBool = shift;
   my $Data   = shift;

   my $Rv = join("\t", map { defined $Data->[$_-1] ? $Data->[$_-1] : '' } @$Cols);

   $Rv = lc $Rv if $CiBool;

   return $Rv;
}

# ========================================================================
# ------------------------------- History --------------------------------
# ========================================================================

=pod

=head1 History

=head2 jschug : Thu Aug 20 07:50:41 EDT 2009

Added case-insensitive matching using C<--caseInsensitive>.

Cleaned up terse boolean variable names.

=cut
