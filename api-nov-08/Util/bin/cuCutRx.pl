#! @perl@

=pod

=head1 Synopsis

  cuCutRx.pl [OPTIONS] [COLUMN-LIST] <>

=head1 Description

Filters a tab-delimied file to eliminate any columns that contain a
match to a list of regexs.

=cut

# ========================================================================
# ----------------------------- Declaration ------------------------------
# ========================================================================

use constant DEBUG_FLAG => 0;

use CBIL::Util::EasyCsp;

# ========================================================================
# --------------------------------- Code ---------------------------------
# ========================================================================

$| = 1;
run(cla());

# --------------------------------- run ----------------------------------

sub run {
   my $Cla = shift;

   my @showRow;

   my $head = <>;
   chomp $head;
   my @head = split /$Cla->{InDelimRx}/, $head;

   my @keep;

   my @accept_rx = @{$Cla->{AcceptRx}};
   my @reject_rx = @{$Cla->{RejectRx}};

 Head:
   for (my $i = 0; $i < @head; $i++) {

      if (@accept_rx) {
         my @match_rx = grep { $head[$i] =~ /$_/ } @accept_rx;
         next Head if !@match_rx;
      }

      if (@reject_rx) {
         foreach my $rx (@reject_rx) {
            next Head if $head[$i] =~ /$rx/;
         }
      }

      push(@keep, $i);
   }

   foreach (@keep) {
      push(@showRow, $head[$_]);
   }
   print join($Cla->{OutDelim}, @showRow), "\n";

   while ( <> ) {
      chomp;
      my @cols = split(/$Cla->{InDelimRx}/, $_);
      @showRow = map { $cols[$_] } @keep;
      print join($Cla->{OutDelim}, @showRow), "\n";
   }
}

# --------------------------------- cla ----------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   ( [ { h => 'remove any columns that match any of these regexps',
         t => CBIL::Util::EasyCsp::StringType(),
         l => 1,
         o => 'RejectRx',
       },

       { h => 'accept any columns that match any of these regexps; accept is applied before reject',
         t => CBIL::Util::EasyCsp::StringType(),
         l => 1,
         o => 'AcceptRx',
       },

       { h => 'input stream is delimited by this RX',
         t => CBIL::Util::EasyCsp::StringType(),
         o => 'InDelimRx',
         d => "\t",
       },

       { h => 'delimit output with this string',
         t => CBIL::Util::EasyCsp::StringType(),
         o => 'OutDelim',
         d => "\t",
       },
     ],

     'project and reformat columns from the input stream'
   ) || exit 0;

   return $Rv;
}
