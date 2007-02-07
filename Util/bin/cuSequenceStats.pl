#! /usr/bin/perl

=pod

=head1 Synopsys

  cuSequenceStats.pl [OPTIONS] sequence files

=head1 Purpose

Reads in a bunch of sequence files and outputs statistics of the
sequences, i.e., length, cg-content, fraction of Ns, etc in a
delimited format.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict 'vars';

use FileHandle;

use Bio::SeqIO;
use Bio::Seq;

use CBIL::Util::EasyCsp;

# ========================================================================
# ------------------------------ Main Body -------------------------------
# ========================================================================

$| = 1;
run(cla());

# ========================================================================
# ---------------------------- Main Functions ----------------------------
# ========================================================================

# --------------------------------- run ----------------------------------

sub run {
  my $Cla = shift;

  my @files = @ARGV;

  my @cols = ( qw( id n% cg% not-nN cgBar ),
               $Cla->{outputSequence} ? qw( seq ) : (),
               qw( desc )
             );
  print join($Cla->{outputDelimiter}, map { "#$_" } @cols), "\n";

  foreach my $file (@files) {

     my $_seqio = Bio::SeqIO->new( -file => "<$file" );

     while (my $_seq = $_seqio->next_seq()) {
        my $id         = $_seq->display_id();
        my $seq        = $_seq->seq();
        my @seq        = split(//, $seq);
        my $length     = scalar @seq;
        my $n_n        = scalar grep { /n/i      } @seq;
        my $n_percent  = $n_n / $length;

        my @bases      = grep { /[acgt]/i } @seq;
        my $bases_n    = scalar @bases;
        my %bases_n    = ();

        my $cgs_n      = 0;
        my $cg_percent = 0;
        my $cg_bar     = '';

        # count the number of each base in sequence
        foreach (@seq) {
           my $b = uc $_;
           $b = 'N' unless $b =~ /[ACGT]/;
           $bases_n{$b}++;
        }

        # make the CG bar
        if ($bases_n > 0) {
           my $cgs_n = scalar grep { /[cg]/i   } @bases;
           $cg_percent = $cgs_n / $bases_n;
           $cg_bar     = '*' x (20 * $cg_percent);
        }

        print join($Cla->{outputDelimiter},
                   $id,
                   $length,
                   sprintf('%0.2f', $n_percent),
                   sprintf('%0.2f', $cg_percent),
                   $bases_n,
                   (map { $bases_n{$_} || 0 } qw( A C G T N ) ),
                   $cg_bar,
                   $Cla->{outputSequence} ? ($_) : (),
                   $_seq->desc(),
                  ), "\n";
     }
  }

}

# --------------------------------- cla ----------------------------------

sub cla {
  my $Rv = CBIL::Util::EasyCsp::DoItAll
  ( [ { h => 'show sequence in output',
        t => CBIL::Util::EasyCsp::BooleanType(),
        o => 'outputSequence',
      },

      { h => 'use this delimiter in output',
        t => CBIL::Util::EasyCsp::StringType(),
        o => 'outputDelimiter',
        d => "\t",
      },
    ]
  ) || exit 0;

  return $Rv;
}

