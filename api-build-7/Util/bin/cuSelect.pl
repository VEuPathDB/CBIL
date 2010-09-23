#! @perl@

=pod

=head1 Description

Selects rows from input stream where a column (indicated by position)
has a value lt, le, eq, gt, ge, ne, <=, <, ==, !=, >, >= a specified value.

=head1 Example

  cat FILE | cuSelect.pl +1 seq Hello +4 gt 5.0 +8 re '\d+'

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict 'vars';
use vars qw( @ARGV );

use lib '@targetDir@/lib/perl';

use CBIL::Util::EasyCsp;

# ========================================================================
# ------------------------------ Main Body -------------------------------
# ========================================================================

$| = 1;

run(cla());

# --------------------------------- cla ----------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   ( [ { h => 'split input lines on this RX',
         t => CBIL::Util::EasyCsp::StringType(),
         o => 'InDelimRx',
         d => '\t',
       },
     ],
     ''
   ) || exit 0;

   return $Rv;
}

# --------------------------------- run ----------------------------------

sub run {
   my $Cla = shift;

   my @filters = @ARGV; @ARGV = ();

   my $inDelim_rx = $Cla->{InDelimRx};

   my $line = 0;
 FILE_SCAN:
   while ( <> ) {
      $line++;
      chomp;
      my @cols = ($line, split /$inDelim_rx/ );

      for ( my $i = 0; $i < @filters; $i += 3 ) {

         # get the relational operator
         my $s_relop = $filters[ $i + 1 ];

         # get local values of filter parameters
         my $s_left  = getValue( $filters[ $i + 0 ], @cols );
         my $s_right = getValue( $filters[ $i + 2 ], @cols );

         # do the comparison
         my $pass_b = 0;

         if ( $s_relop eq 're' ) {
            $pass_b = $s_left =~ /$s_right/ ? 1 : 0;
         }

         elsif ( $s_relop eq 'nre' ) {
            $pass_b = $s_left =~ /$s_right/ ? 0 : 1;
         }

         elsif ( $s_relop eq 'slt' ) {
            $pass_b = $s_left lt $s_right;
         }

         elsif ( $s_relop eq 'sle' ) {
            $pass_b = $s_left le $s_right;
         }

         elsif ( $s_relop eq 'seq' ) {
            $pass_b = $s_left eq $s_right;
         }

         elsif ( $s_relop eq 'sne' ) {
            $pass_b = $s_left ne $s_right;
         }

         elsif ( $s_relop eq 'sge' ) {
            $pass_b = $s_left ge $s_right;
         }

         elsif ( $s_relop eq 'sgt' ) {
            $pass_b = $s_left gt $s_right;
         }

         elsif ( $s_relop eq '<' || $s_relop eq 'lt' ) {
            $pass_b = $s_left < $s_right;
         }

         elsif ( $s_relop eq '<=' || $s_relop eq 'le' ) {
            $pass_b = $s_left <= $s_right;
         }

         elsif ( $s_relop eq '==' || $s_relop eq 'eq' ) {
            $pass_b = $s_left == $s_right;
         }

         elsif ( $s_relop eq '!=' || $s_relop eq 'ne' ) {
            $pass_b = $s_left != $s_right;
         }

         elsif ( $s_relop eq '>=' || $s_relop eq 'ge' ) {
            $pass_b = $s_left >= $s_right;
         }

         elsif ( $s_relop eq '>' || $s_relop eq 'gt' ) {
            $pass_b = $s_left > $s_right;
         }

         elsif ( $s_relop =~ /^mod(\d+)$/) {
            $pass_b = $s_left % $1 == $s_right;
         }

         next FILE_SCAN unless $pass_b;
      }

      print $_,"\n";;
   }
}

# ========================================================================
# --------------------------- Support Routines ---------------------------
# ========================================================================

# ------------------------------- getValue -------------------------------

sub getValue {
	 my $Tag  = shift;

	 if ( $Tag =~ /^\%(\d+)$/ ) {
			return $_[$1];
	 }
   elsif ($Tag =~ /^\%\%(\d+)$/ ) {
      return length($_[$1]);
   }
	 else {
			return $Tag
	 }
}
