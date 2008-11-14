
package CBIL::Bio::DbFfWrapper::Novartis::ExpressionSet;

# ======================================================================

=pod

=head1 Synopsis

This package is a wrapper around the tab-delimited expression data
files containing J. Hogeneschs data provided by the GNF.

=cut

# ======================================================================

use strict 'vars';

use FileHandle;

use constant MaxRowsToRead => 1e10;

# ======================================================================

# ----------------------------------------------------------------------

sub new {
   my $Class = shift;
   my $Args  = shift;

   my $self = bless {}, $Class;

   $self->init($Args);

   return $self;
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   # filename as string
   if (!ref $Args) {
      $Self->init({ File => $Args });
   }

   # filename (and others) in hash
   elsif (ref $Args eq 'HASH') {

      $Self->setFloor($Args->{Floor});

      if (my $fh = FileHandle->new("<$Args->{File}")) {
         my $row_n = 0;
         my @rows;
         while (<$fh>) {
						chomp;
            push(@rows, [ split /\t/ ] );
            $row_n++;
            last if $row_n > MaxRowsToRead;
         }
         $fh->close;
         $Self->init(\@rows);
      }
      else {
         warn join("\t",
                   ref $Self,
                   "Could not open ExpressionSet File",
                   $Args->{File},
                   $1
                  );
      }
   }

   # rows as text
   elsif (ref $Args eq 'ARRAY') {

      # get titles
      my $titles = shift @$Args;

      # get counts of each column (except spot id)
      my %tissues; foreach (@$titles) { $tissues{$_}++ }
      delete $tissues{$titles->[0]};

      # process data rows
      foreach my $row (@$Args) {

         # make Measurement objects for each tissue
         my %measurements = map {
            ( $_ => DbFfWrapper::Novartis::ExpressionSet::Measurement->new() )
         } keys %tissues;

         # process the data in the row
         for (my $col_i = 1; $col_i < @$row; $col_i++) {
            $measurements{$titles->[$col_i]}->addData(V::max($Self->getFloor(),
                                                             $row->[$col_i]
                                                            )
                                                     );
         }

         # add these to the data set.
         foreach (keys %measurements) {
            $Self->addMeasurement($row->[0],
                                  $_,
                                  $measurements{$_}
                                 );
         }
      }
   }

   return $Self;
}

# ----------------------------------------------------------------------

sub getFloor                { $_[0]->{Floor               } }
sub setFloor                { $_[0]->{Floor               } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub getTissues { sort keys %{$_[0]->{TS}} }
sub getSpots   { sort keys %{$_[0]->{ST}} }

# ----------------------------------------------------------------------

sub addMeasurement {
   my $Self        = shift;
   my $Spot        = shift;
   my $Tissue      = shift;
   my $Measurement = shift;

   $Self->{ST}->{$Spot}->{$Tissue} = $Measurement;
   $Self->{TS}->{$Tissue}->{$Spot} = $Measurement;

   return $Self;
}

sub getMeasurementSpotTissue {
   my $Self   = shift;
   my $Spot   = shift;
   my $Tissue = shift;

   if (exists $Self->{ST}->{$Spot}) {
      return $Self->{ST}->{$Spot}->{$Tissue};
   }
   else {
      return undef;
   }
}

# ----------------------------------------------------------------------

sub getMaximumForSpot {
   my $Self = shift;
   my $Spot = shift;

   # all tissues
   my @tissues         = $Self->getTissues();

   # track the best
   my $bestTissue      = shift @tissues;
   my $bestMeasurement = $Self->getMeasurementSpotTissue($Spot,$bestTissue);
   foreach (@tissues) {
      my $measurement = $Self->getMeasurementSpotTissue($Spot,$_);
      if ($measurement->getMean() > $bestMeasurement->getMean()) {
         $bestTissue = $_;
         $bestMeasurement = $measurement;
      }
   }

   return { Tissue      => $bestTissue,
            Measurement => $bestMeasurement
          };
}

sub getStatisticsForSpotMeans {
   my $Self    = shift;
   my $Spot    = shift;
   my $Tissues = shift || {};

   # all tissues
   my @tissues = keys %$Tissues;
   @tissues    = $Self->getTissues() unless scalar @tissues;

   # get the mean measurements
   my @measurements = map {
      $Self->getMeasurementSpotTissue($Spot,$_)->getMean()
   } @tissues;

   # compute and return
   return { Minimum => V::min(@measurements),
            Maximum => V::max(@measurements),
            Mean    => V::average(@measurements),
            Median  => V::median(@measurements),
          };
}

# ----------------------------------------------------------------------

sub getMaximumForTissue {
   my $Self   = shift;
   my $Tissue = shift;

   # all spots
   my @spots         = $Self->getSpots();

   # track the best
   my $bestSpot        = shift @spots;
   my $bestMeasurement = $Self->getMeasurementSpotTissue($bestSpot,$Tissue);
   foreach (@spots) {
      my $measurement = $Self->getMeasurementSpotTissue($_,$Tissue);
      if ($measurement->getMean() > $bestMeasurement->getMean()) {
         $bestSpot = $_;
         $bestMeasurement = $measurement;
      }
   }

   return { Spot        => $bestSpot,
            Measurement => $bestMeasurement
          };
}

# ----------------------------------------------------------------------

1;


# ======================================================================

package DbFfWrapper::Novartis::ExpressionSet::Measurement;

use V;

sub new {
   my $Class = shift;
   my $Args  = shift;

   my $self = bless {}, $Class;

   $self->init($Args);

   return $self;
}

# ----------------------------------------------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   return $Self;
}

# ----------------------------------------------------------------------

sub getData { $_[0]->{Data} }
sub addData {
   my $Self = shift;
   push(@{$Self->{Data}}, @_);
   $Self->clearCache();
   return $Self;
}
sub getDataCount { scalar @{$_[0]->{Data}} }

# ----------------------------------------------------------------------

sub clearCache {
   my $Self = shift;
   foreach ( Mean ) {
      delete $Self->{$_};
   }
}

sub getMean {
   my $Self  = shift;

   if (!defined $Self->{Mean}) {
      if (my $count = $Self->getDataCount()) {
         $Self->{Mean} = V::sum(@{$Self->getData()}) / $count;
      }
   }

   $Self->{Mean};
}

# ======================================================================


1;

__END__

my $file   = shift @ARGV;
my $tissue = shift @ARGV;
my $spot   = shift @ARGV;

my $NvExSet = DbFfWrapper::Novartis::ExpressionSet->new($file);

use Disp;

#Disp::Display($NvExSet);

Disp::Display($NvExSet->getMaximumForTissue($tissue));
Disp::Display($NvExSet->getMaximumForSpot  ($spot  ));


