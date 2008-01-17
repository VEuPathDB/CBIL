#! @perl@ -w

=pod

=head1 Synopsis

  cbSequenceSelector.pl [OPTIONS] [FILES | < FILE] > SEQUENCES

=head1 Purpose

Use this program to select sequences from a sequence file that match
(or do not match) a regular expression either in the sequence or in
the defline.

=cut

# ----------------------------------------------------------------------

use strict;

use FileHandle;

use CBIL::Util::EasyCsp;

use Bio::SeqIO;
use Bio::Seq;

# ----------------------------------------------------------------------

$| = 1;
run(cla());

# ----------------------------------------------------------------------

=pod

=head1 Processing

=cut

sub run {
   my $Cla = shift;

   # we'll write here.
   my $out_io = Bio::SeqIO->new( -file => '>-', -format => $Cla->{OutFormat} );

   # get reg exps from file if need be
   loadSelRxFiles($Cla);

   # number of sequences processed
   my $seqs_n = 0;

   # ids we've considered.
   my %idsWeveSeen;

   # -------------------------- process all files ---------------------------

   # get a list of files.
   my @files = @{$Cla->{ARGV}};
   @files = ('-') if scalar @files == 0;

   foreach my $file (@files) {

      # open sequence file
      my $_f;
      if ($file =~ /.gz$/) {
         $_f = "zcat $file|";
      }
      else {
         $_f = "<$file";
      }

      # ------------------------ process all sequences -------------------------

      my $in_io  = Bio::SeqIO->new( -file => $_f,  -format => $Cla->{InFormat} );
      while ( my $_seq = $in_io->next_seq() ) {

         my $length = $_seq->length();

         my $skip_b = 1;

         my $id     = $_seq->display_id();

         if (!$Cla->{Unique} || $idsWeveSeen{$id} == 0) {

            # title and sequence match
            if ((! defined $Cla->{SelRx}    ||
                 $_seq->display_id() =~ m/$Cla->{SelRx}/ ||
                 $_seq->desc()       =~ m/$Cla->{SelRx}/) &&
                (! defined $Cla->{SeqSeqRx} || $_seq->seq()  =~ m/$Cla->{SelSeqRx}/)
               ) {

               # sequence is right length
               if ($length >= $Cla->{SelLenRange}->[0] &&
                   $length <= $Cla->{SelLenRange}->[1]
                  ) {

                  # does not match an anti-selector or there are none
                  if ((! defined $Cla->{NoSelRx}    ||
                       $_seq->primary_id !~ m/$Cla->{NoSelRx}/ ||
                       $_seq->desc()     !~ m/$Cla->{NoSelRx}/
                      ) &&
                      (! defined $Cla->{NoSelSeqRx} || $_seq->seq()  !~ m/$Cla->{NoSelSeqRx}/)
                     ) {
                     $skip_b = 0;
                  }
               }
            }
         }

         # note that we've seen this.
         $idsWeveSeen{$id} = 1;

         # skipping this one.
         if ($skip_b) {
            $Cla->{debug} && print STDERR "Skipped";
         }

         # pass this one
         else {

            # count number of matches and don't report unwanted sequences.
            $seqs_n++;
            return if $seqs_n < $Cla->{First} || $seqs_n > $Cla->{Last};

            if ($Cla->{Length}) {
               $_seq->seq($_seq->subseq($Cla->{Offset},
                                        $Cla->{Offset}+$Cla->{Length}
                                       )
                         );
            }

            if ($Cla->{DefPrefix}) {
               $_seq->display_id($Cla->{DefPrefix}. $_seq->display_id);
            }

            if ($Cla->{DefSuffix}) {
               $_seq->desc($_seq->desc. $Cla->{DefSuffix});
            }

            $out_io->write_seq($_seq);
         }

         $Cla->{debug} && print STDERR "\t". $_seq->getDefLine. "\n";
      }
   }
}

# ----------------------------------------------------------------------

sub cla {
   my $Rv = CBIL::Util::EasyCsp::DoItAll
   ( [ { h => 'input file has this format',
         t => CBIL::Util::EasyCsp::StringType(),
         o => 'InFormat',
         d => 'Fasta',
       },

       { h => 'write selected sequences in this format',
         t => CBIL::Util::EasyCsp::StringType(),
         o => 'OutFormat',
       },

       { h => 'match this reg-exp against def line',
         t => 'string',
         d => '.',
         o => 'SelRx',
       },

       { h => 'ignore patterns from file',
         t => 'boolean',
         o => 'SrxSkip',
       },

       { h => 'read patterns from this file',
         t => 'string',
         l => 1,
         o => 'SrxTabFiles',
       },

       { h => 'read patterns from this column of file',
         t => 'string',
         d => 1,
         o => 'SrxColumn',
       },

       { h => 'match this rex-exp against sequence',
         t => 'string',
         d => '.',
         o => 'SelSeqRx',
       },

       { h => 'deflines must not contain this reg-exp',
         t => 'string',
         o => 'NoSelRx',
       },

       { h => 'sequences must not contain this reg-exp',
         t => 'string',
         o => 'NoSelSeqRx',
       },

       { h => 'Perl substr index variable',
         t => 'integer',
         d => 0,
         o => 'Offset',
       },

       { h => 'Perl substr length variable',
         t => 'integer',
         o => 'Length'
       },

       { h => 'add this to each def line',
         t => 'string',
         o => 'DefSuffix',
       },

       { h => 'prepend this to each def line',
         t => 'string',
         o => 'DefPrefix',
       },

       { h => 'start passing sequences at this number of matches',
         t => 'integer',
         d => 1,
         o => 'First',
       },

       { h => 'stop passing sequences after this number of matches',
         t => 'integer',
         o => 'Last',
       },

       { h => 'number of sequences to select',
         t => 'integer',
         d => 1e9,
         o => 'Number',
       },

       { h => 'select sequences in this length range',
         t => 'integer',
         l => 1,
         o => 'SelLenRange',
         d => '1,1e12',
       },

       { h => 'make sure sequences are not re-used',
         t => 'boolean',
         o => 'Unique',
       },
     ],
     'Extracts selected portions of sequences from a FASTA file'
   ) || exit 0;

   $Rv->{Last} = $Rv->{First} + $Rv->{Number} unless $Rv->{Last};

   $Rv->{OutFormat} = $Rv->{InFormat} unless defined $Rv->{OutFormat};

   return $Rv;
}

# ========================================================================
# --------------------------- Support Routines ---------------------------
# ========================================================================

=pod

=head1 Details

=cut

# ----------------------------------------------------------------------

=pod

=head2 SrxTabFiles

If there are any C<--SrxTabFiles> indicated, then get the list of terms
that are in all of them.  We then override the C<SelRx> or C<NoSelRx>
options with the OR of this list.

Each line is considered a term in the big RX disjunction.  So for
example a file like this (without the leading whitespace!)

  hello
  world

would generate a RX like

  (hello)|(world)

=cut

sub loadSelRxFiles {
   my $Cla = shift;

   if (my $files_n = scalar @{$Cla->{SrxTabFiles}}) {

      $Cla->{SrxColumn}--;

      my %ids;

      foreach my $file (@{$Cla->{SrxTabFiles}}) {
         my $_fh = FileHandle->new("<$file")
         || die "Can not open SrxTabFile '$file' : $!";

         while (<$_fh>) {
            chomp;
            my @parts = split /\t/;
            my $rx = $parts[$Cla->{SrxColumn}];
            $ids{$rx}++ if length $rx > 0;
         }
         $_fh->close();
      }

      my @ids = sort
      grep { $ids{$_} == $files_n }
      keys %ids;

      my $rx = join('|', map { "($_)" } @ids);
      $rx =~ s/\[/\\\[/g;
      $rx =~ s/\]/\\]/g;
      if ($Cla->{SrxSkip}) {
         $Cla->{NoSelRx} = $rx;
      }
      else {
         $Cla->{SelRx} = $rx;
      }

      if ($Cla->{verbose}) {
         print STDERR scalar(@ids), "\n";
         print STDERR "$Cla->{SelRx}\n";
         print STDERR "$Cla->{NoSelRx}\n";
      }
   }
}

