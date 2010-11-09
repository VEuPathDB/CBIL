#! @perl@

=pod

=head1 Description

Selects rows from input stream where a column (indicated by position)
has a value lt, le, eq, gt, ge, ne, <=, <, ==, !=, >, >= a specified value.

=head1 Example

  cat FILE | cuSelect.pl %1 seq Hello %4 gt 5.0 %8 re '\d+'
  
If you need to compare to a literal with a leading minus sign, e.g.,

 %3 le -1,
 
then put '--' before the selection expression.

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
   my $Rv = CBIL::Util::EasyCsp->new
   ( [ { h => 'split input lines on this RX',
         t => CBIL::Util::EasyCsp::StringType(),
         o => 'InDelimRx',
         d => '\t',
       },

       { h => 'pass this many header lines through without testing for matches',
         t => IntType(),
         o => 'skipN',
         d => 0,
       },
       
       { h => 'read column names from header line (after skipping skipN)',
         t => BooleanType(),
         o => 'header',
       }
     ],
     ''
   );

   return $Rv;
}

# --------------------------------- run ----------------------------------

sub run {
   my $Cla = shift;

   my @filters = @ARGV; @ARGV = ();

   my $inDelimRx = $Cla->{InDelimRx};

   my $skipN = $Cla->skipN();
   for (my $i = 1; $i <= $skipN; $i++) {
     my $line = <>;
     print $line;
   }

   my $columnNamesDict = extractHeader($Cla);

   my $line = 0;
 FILE_SCAN:
   while ( <> ) {
      $line++;
      chomp;
      my @cols = ($line, split /$inDelimRx/ );

      for ( my $i = 0; $i < @filters; $i += 3 ) {

         # get the relational operator
         my $s_relop = $filters[ $i + 1 ];

         # get local values of filter parameters
         my $s_left  = getValue( $columnNamesDict, $filters[ $i + 0 ], @cols );
         my $s_right = getValue( $columnNamesDict, $filters[ $i + 2 ], @cols );

         # do the comparison
         my $pass_b = 0;

         if ( $s_relop eq 're' ) {
            $pass_b = $s_left =~ /$s_right/ ? 1 : 0;
         }

         elsif ( $s_relop eq 'nre' ) {
            $pass_b = $s_left =~ /$s_right/ ? 0 : 1;
         }

        elsif ( $s_relop eq 'ire' ) {
            $pass_b = $s_left =~ /$s_right/i ? 1 : 0;
         }

         elsif ( $s_relop eq 'inre' ) {
            $pass_b = $s_left =~ /$s_right/i ? 0 : 1;
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

# ---------------------------- extractHeader -----------------------------

=pod

=head1 Column Headings

When the C<--header> option is used then the first line (follow C<--skipN>
lines) is used as a header to give names to each column.

=cut

sub extractHeader {
  my $Cla = shift;

  my $Rv;

  if ($Cla->header()) {
    my $inDelimRx = $Cla->InDelimRx();
    my $headers   = <>;
    print $headers;
    chomp $headers;
    my @cols = map { $_ =~ s/^\"//; $_ =~ s/\"$//; $_ } split /$inDelimRx/, $headers;
    for (my $i = 0; $i < @cols; $i++) {
      $Rv->{$cols[$i]} = $i+1;
    }
  }
  
  return $Rv;
}

# ------------------------------- getValue -------------------------------

=pod

=head1 Indicating Values

Values may be column content, length of column content, or a literal value.

Columns can be addressed either by the column number (1-based) using a form
like %n or by name using %text.

The length of a column's content is indicated by a %%d or %%text.

The %text or %%text methods can only be used when C<--header> is specified.

Anything else is interpreted as a literal value.

=cut

sub getValue {
  my $Dict = shift;
  my $Tag  = shift;

  if ( $Tag =~ /^\%(\d+)$/ ) {
    return $_[$1];
  }
  elsif ($Tag =~ /^\%\%(\d+)$/ ) {
    return length($_[$1]);
  }
  elsif (defined $Dict && $Tag =~ /^\%(.+)/ && defined $Dict->{$1}) {
    return $_[$Dict->{$1}];
  }
  elsif (defined $Dict && $Tag =~ /^\%%(.+)/ && defined $Dict->{$1}) {
    return length($_[$Dict->{$1}+1]);
  }
  else {
    return $Tag
  }
}
