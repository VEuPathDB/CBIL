#! /usr/bin/perl

my $purpose = 'compute hierarchical entropy values';

# ----------------------------------------------------------------------

BEGIN { push(@INC, '.') }

use strict;

use Disp;
use EasyCsp;
use FileHandle;
use XML::Simple;

use CBIL::HQ::Analysis;
use CBIL::HQ::Node;
use CBIL::HQ::Hierarchy;

use CBIL::Util::V;
use CBIL::Bio::DbFfWrapper::Novartis::ExpressionSet;

# ----------------------------------------------------------------------

sub getCla {
   my @options
   = ( { h => 'read expression data from this file',
         t => $EasyCsp::String,
         o => 'ExpressionFile',
       },

       { h => 'set this minimum value on all expression data',
         t => $EasyCsp::String,
         o => 'Floor',
         d => 20,
       },

       { h => 'start processing with this spots',
         t => $EasyCsp::String,
         o => 'FirstSpot',
       },

       { h => 'process this many spots',
         t => $EasyCsp::String,
         o => 'SpotsN',
         d => 1e10,
       },

       { h => 'read hierarchy from this XML file, rather than anatomy and boundary file',
				 t => $EasyCsp::String,
				 o => 'TreeXmlFile',
			 },

       { h => 'select spots matching this node name',
         t => $EasyCsp::String,
         l => 1,
         o => 'Node',
       },

       { h => 'compute selected node\'s fraction of total entropy',
         t => $EasyCsp::Boolean,
         o => 'Fraction',
       },

       { h => 'ignore nodes with H less than this fraction of max H',
         t => $EasyCsp::Float,
         o => 'EntFraction',
       },

       { h => 'ignore nodes with H less than this, i.e., those too uneven',
         t => $EasyCsp::Float,
         o => 'Entropy',
       },

       { h => 'ignore node with more bits than this, i.e., those too weak',
         t => $EasyCsp::Float,
         o => 'Bits',
       },

     );

   my $Cla = EasyCsp::DoItAll(\@options, $purpose, [<DATA>]) || exit 0;

   return $Cla;
}

# ----------------------------------------------------------------------

sub run {
   my $Cla = shift || getCla();

   # keep outputs in sync.
   $| = 1;

   # get tree file
   my $_hierarchy = CBIL::HQ::Hierarchy::NewFromXmlFile($Cla->{TreeXmlFile});
   $Cla->{debug} && Disp::Display($_hierarchy, 'Hierarchy');

	 # make the analysis object
	 my $_analysis = CBIL::HQ::Analysis->new({ Hierarchy        => $_hierarchy,
																						 Threshold        => $Cla->{Floor},
																						 ReplacementValue => $Cla->{Floor},
																						 Pseudocounts     => 0,
																					 });
	 $Cla->{debug} && Disp::Display($_analysis, 'Analysis');

   # get experimental data
	 # ..................................................

   my $_NvExSet = CBIL::Bio::DbFfWrapper::Novartis::ExpressionSet
   ->new({ File  => $Cla->{ExpressionFile},
           Floor => $Cla->{Floor},
         });

   # get the dimensions of the data
   my @spots   = $_NvExSet->getSpots();

   # get tissues and make a map from name to index.
   my @tissues = $_NvExSet->getTissues();
   my $tissue_i = 0;
   my %tissues = map {($_ => $tissue_i++)} @tissues;

   # get range of spots to consider
   my $firstSpot = CBIL::Util::V::max($Cla->{FirstSpot}-1,0);
   my $lastSpot  = CBIL::Util::V::min($firstSpot + $Cla->{SpotsN}, scalar @spots);

   # consider the spots
	 # ......................................................................

	 # We will skip the AFFX spots

 Spot: for (my $spot_i = $firstSpot; $spot_i < $lastSpot; $spot_i++) {
      my $spot = $spots[$spot_i];

      print join("\t", 'Spot', $spot, scalar(@spots)), "\n" if $Cla->{verbose};

      next if $spot=~ /affx/i;

			# make observations
			my %_obs = map {
				 ($_ => $_NvExSet->getMeasurementSpotTissue($spot,$_)->getMean())
			} @tissues;
			$Cla->{debug} && Disp::Display(\%_obs, "\%_obs\n");
			$_analysis->setObservations(\%_obs);

			$_analysis->update();

			$Cla->{debug} && Disp::Display($_analysis->getHierarchy());

			my $root_node     = $_hierarchy->getRoot();
			my $placenta_node = $_hierarchy->lookup('Placenta');

			my $placentaQ_r   =
			$root_node->getGlobalEntropy() + $placenta_node->getLocalBits();

			print join("\t", $spot,
								 $placentaQ_r,
								 $root_node->getGlobalEntropy(),
								 $placenta_node->getLocalBits()
								), "\n";
   }
}

# ======================================================================

run();

# ======================================================================

__END__

