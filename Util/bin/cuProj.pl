#! @perl@

=pod

=head1 Synopsis

  cuProj.pl [OPTIONS] [COLUMN-LIST] <>

=head1 Description

Projects and optionally reformats requested columns from a tab- (or
other) delimited stream.  Very similar to cut, but maintains the
user-specified order of the projected fields.  If the file contains a
#-indicated comment, then the name of the column can be used to select
the column.

=cut

# ========================================================================
# ----------------------------- Declaration ------------------------------
# ========================================================================

use strict;

use CBIL::Util::EasyCsp;

# ========================================================================
# --------------------------------- Code ---------------------------------
# ========================================================================

$| = 1;
run(cla());

# --------------------------------- run ----------------------------------

sub run {
   my $Cla = shift;

   # assume string format, but pick up other requests
   my @Cols_h;
   foreach my $spec (@{$Cla->{Columns}}) {
      my $format = '%s';
      if ($spec =~ /(%.+)/) {
	 $format = $1;
	 $spec =~ s/%.+//;
      }

      my @indices;
      if ($spec =~ /^(\d+)-(\d+)$/) {
	 @indices = ($1 .. $2);
      } elsif ($spec =~ /^\d+$/) {
	 @indices = ($spec);
      } elsif ($spec =~ /^"(.*)"$/) {
	 $format = $1;
	 @indices = (0);
      }

      foreach (@indices) {
	 push(@Cols_h, { Index => $_, Format => $format });
      }
   }

   # process input stream
   # ......................................................................

   my %seen_b = ();

   my $line = 0;
   while ( <> ) {
      $line++;

      chomp;
      my @cols = ($line, split(/$Cla->{InDelimRx}/, $_));

      my $text = join($Cla->{OutDelim},
		      map {
			  sprintf $_->{Format}, $cols[$_->{Index}]
			  } @Cols_h
		      );

      # just print it.
      if (!$Cla->{Unique}) {
	  print "$text\n";
      }

      # only print if we've never seen this before.
      elsif (!$seen_b{$text}++) {
	 print "$text\n";
      }
   }
}

# --------------------------------- cla ----------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   ( [ { h => 'select these 1-based columns: column[:format]',
	 t => CBIL::Util::EasyCsp::StringType,
	 l => 1,
	 o => 'Columns',
	 d => '1',
       },

       { h => 'input stream is delimited by this RX',
	 t => CBIL::Util::EasyCsp::StringType,
	 o => 'InDelimRx',
	 d => "\t",
       },

       { h => 'delimit output with this string',
	 t => CBIL::Util::EasyCsp::StringType,
	 o => 'OutDelim',
	 d => "\t",
       },

       { h => 'just print the unique combos seen',
	 t => CBIL::Util::EasyCsp::BooleanType(),
	 o => 'Unique',
       },
     ],

     'project and reformat columns from the input stream'
   ) || exit 0;

   return $Rv;
}
