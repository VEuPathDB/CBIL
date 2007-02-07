#! @perl@ -w

=pod

=head1 Synopsis

  cbSelectorMatchingBaseComps.pl [OPTIONS] TEMPLATE_SEQUENCES TARGET_SEQUENCES > MATCHING_SEQUENCES

=head1 Purpose

Use this program to select sequences from the C<target_sequences_file>
that have a C+G base composition that matches the distribution of the
files in C<template_sequence_file>.  The target number of sequences to
select is indicated with the C<--sequenceNumber>, but fewer sequences may
be selected if there are not enough sequences in the target with the
appropriate base composition.

=cut

# ----------------------------------------------------------------------

use strict;

use FileHandle;

use CBIL::Util::EasyCsp;
use CBIL::Util::V;

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

   my $template_f = shift @ARGV;
   my $target_f   = shift @ARGV;

   my %templateProb_dict = _loadCompositionStats( $Cla, -file => $template_f);
   my %targetList_dict   = _loadCompositionStats( $Cla, -file => $target_f  );

   my %idsToTake_dict = _selectIds( $Cla,
                                    -template => \%templateProb_dict,
                                    -target   => \%targetList_dict
                                  );

   # we'll write here.
   my $out_io = Bio::SeqIO->new( -file => '>-',       -format => $Cla->{OutFormat} );

   # we'll read from here.
   my $in_io  = Bio::SeqIO->new( -file => $target_f,  -format => $Cla->{InFormat} );

   while ( my $_seq = $in_io->next_seq() ) {
      my $id = $_seq->display_id();
      if ($idsToTake_dict{$id}) {
         $out_io->write_seq($_seq);
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

       { h => 'number of sequences to select',
         t => 'integer',
         d => 1e9,
         o => 'sequenceNumber',
       },

       { h => 'bin C+G fraction to this resolution',
         t => CBIL::Util::EasyCsp::FloatType(),
         o => 'resolution',
         d => 1/20,
       },

     ],
   ) || exit 0;

   $Rv->{OutFormat} = $Rv->{InFormat} unless defined $Rv->{OutFormat};

   return $Rv;
}

# ========================================================================
# -------------------------- Support Functions ---------------------------
# ========================================================================

# ------------------------ _loadCompositionStats -------------------------

=pod

=head1 Assessing Base Composition

Base composition is assessed using the C<cuSequenceStats.pl> program.
The stats are assumed to be stored in a file with the same name as the
input sequence file, but with the extended extension '.ss.tab', e.g.,
C<seqs.fa> and C<seqs.fa.ss.tab>.

The sequence id and C+G content are read from the file and the number
of sequences, or the actual ids, in each bin are counted or collected.

=cut

sub _loadCompositionStats {
   my $Cla  = shift;
   my %Args = @_; # ( -file => string, -counts => boolean );

   my %Rv;

   my $stat_f = "$Args{-file}.ss.tab";
   if (!-e $stat_f) {
      my $cmd = "cuSequenceStats.pl $Args{-file} > $stat_f";
      system $cmd;
   }

   my $rez = $Cla->{resolution};

   my $stat_fh = FileHandle->new("<$stat_f") ||
   die "Can not open sequence stat file '$stat_f' : $!";

   while (<$stat_fh>) {
      next if /^\#/;
      chomp;

      my @cols = split /\t/;

      my $id = $cols[0];
      my $cg = int($cols[2]/$rez + 0.5) * $rez;

      $Rv{Count}->{$cg}++;
      push(@{$Rv{List}->{$cg}}, $id);
   }

   my $total_n = CBIL::Util::V::sum(values %{$Rv{Count}});
   $Rv{Total} = $total_n;

   foreach (keys %{$Rv{Count}}) {
      $Rv{Prob}->{$_} = $Rv{Count}->{$_} / $total_n;
   }

   $stat_fh->close();

   return wantarray ? %Rv : \%Rv;
}

# ------------------------------ _selectIds ------------------------------

=pod

=head1 Selecting Sequences

The distribution of the target and template C+G percentages and the
number of target sequences puts a limit on the number of sequences
that can be selected.

=cut

sub _selectIds {
   my $Cla  = shift;
   my %Args = @_ ;

   my %Rv;

   # get a dictionary of all of the bins
   my %bins_dict    = map { ( $_ => 1 ) } ( keys %{$Args{-template}->{Count}},
                                            keys %{$Args{-target}->{Count}}
                                          );
   my @bins         = sort { $a <=> $b } keys %bins_dict;

   my $targets_n    = $Args{-target}->{Total};

   # determine maximum number of total sequences.
   my $maxPossible_n = CBIL::Util::V::min($Cla->{sequenceNumber}, $targets_n);

   foreach my $bin (@bins) {

      my $wanted_n   = ($Args{-template}->{Prob }->{$bin}||0) * $targets_n;
      my $possible_n =  $Args{-target  }->{Count}->{$bin};

      if ($wanted_n > $possible_n) {
         my $n = int($possible_n / $Args{-template}->{Prob}->{$bin});
         $maxPossible_n = $n if $n < $maxPossible_n;
      }
   }

   # select sequence ids for each bin
   foreach my $bin (@bins) {

      my $take_n = int( ($Args{-template}->{Prob}->{$bin} || 0) * $maxPossible_n + 0.5);
      if ($take_n > 0) {

         # get ids in random order
         my @ids =
         map  { $_->[0] }
         sort { $a->[1] <=> $b->[1] }
         map  { [ $_, rand() ] }
         @{$Args{-target}->{List}->{$bin}};

         my @selectedIds = sort @ids[0 .. $take_n-1];

         foreach (@selectedIds) {
            $Rv{$_} = 1;
         }
         print STDERR join("\t", $bin, $take_n, @selectedIds), "\n";
      }
      else {
         print STDERR join("\t", $bin, $take_n ), "\n";
      }
   }

   return wantarray ? %Rv : \%Rv;
}
