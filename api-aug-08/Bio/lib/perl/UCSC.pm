
package CBIL::Bio::UCSC;

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

use CBIL::Util::EasyCsp;
use CBIL::Util::Files;

use TESS::Common::Span; # bad practice here - need to fix this.

# ----------------------------- EasyCspOpts ------------------------------

sub EasyCspOpts {
   my @Rv = 
   ( { h => 'give the track this name',
       t => CBIL::Util::EasyCsp::StringType(),
       o => 'trackName',
     },

     { h => 'give the track this description',
       t => CBIL::Util::EasyCsp::StringType(),
       o => 'trackDescription',
     },

     { h => 'give the track this color',
       t => CBIL::Util::EasyCsp::StringType(),
       o => 'trackColor',
       d => '0,0,0',
     },

     { h => 'maximum height of track',
       t => CBIL::Util::EasyCsp::IntType(),
       o => 'trackMaxHeightPixels',
       d => 40,
     },

     { h => 'content GFF source column',
       t => CBIL::Util::EasyCsp::StringType(),
       o => 'gffSource',
       d => $0,
     },
   );

   return wantarray ? @Rv : \@Rv;
}

# ------------------------------- Browser --------------------------------

sub Browser {
   my $Args = ref $_[0] ? shift : {@_};

   my @atts = qw( position hide dense pack squish full );

   return Generic($Args, 'browser', \@atts);
}

# -------------------------------- Track ---------------------------------

sub Track {
   my $Args = ref $_[0] ? shift : {@_};

   my @atts = qw( name description visibility color altColor autoScale
   gridDefault maxHeightPixels graphType itemRgb useScore group
   prioriy db offset url htmlUrl type viewLimits yLineMark yLineOnOff
   windowingFunction smoothingWindow );

   my @noQuotes = qw( type );

   return Generic($Args, 'track', \@atts, \@noQuotes);
}

# -------------------------------- Wiggle --------------------------------

sub Wiggle_variableStep {
   my $Args = ref $_[0] ? shift : {@_};

   my @atts = qw( chrom span );

   my @noQuotes = qw( chrom span );

   return  Generic($Args, 'variableStep', \@atts, \@noQuotes);
}

sub Wiggle_fixedStep {
   my $Args = ref $_[0] ? shift : {@_};

   my @atts = qw( chrom start step span );

   my @noQuotes = qw( );

   return  Generic($Args, 'fixedStep', \@atts, \@noQuotes);
}

# ------------------------------- generic --------------------------------

sub Generic {
   my $Args = shift;
   my $Tag  = shift;
   my $Atts = shift;
   my $NoQ  = shift || [];

   my $Rv;

   my %noQ = map { $_ => 1 } @$NoQ;

   my @avs  = ();

   foreach my $att (@$Atts) {
      my $q = $noQ{$att} ? '' : '"';
      defined $Args->{$att} && push(@avs, "$att=$q$Args->{$att}$q");
   }

   $Rv = join(' ', $Tag, @avs);

   return $Rv;
}

# ========================================================================
# ------------------------- Scanning Subroutines -------------------------
# ========================================================================

# ------------------------------ WiggleScan ------------------------------

sub WiggleScan {
   my $File = shift;
   my $Code = shift;
   my $Skip = shift || 1;

   my $_fh = ref $File ? $File : CBIL::Util::Files::SmartOpenForRead($File);

   my $chr;
   my $beg;
   my $end;
   my $score;
   my $span;
   my $step;

   my $fixedStep_b;
      
   while (<$_fh>) {
      chomp;

      # skip track line
      if ($_ =~ /^track/) {
      }

      # fixed step info
      elsif ($_ =~ /^fixedStep/) {
         ($chr)  = $_ =~ /chrom=(\S+)/;
         ($beg)  = $_ =~ /start=(\d+)/;
         ($span) = $_ =~ /span=(\d+)/;
         ($step) = $_ =~ /step=(\d+)/;
         $fixedStep_b = 1;
      }

      # variable step
      elsif ($_ =~ /^variableStep/) {
         ($chr)  = $_ =~ /chrom=(\S+)/;
         ($span) = $_ =~ /span=(\d+)/;
         $fixedStep_b = 0;
      }

      # a data line
      elsif ($fixedStep_b) {
         if ($Skip && $_ =~ /inf|nan/i) {
         }
         else {
            $Code->(TESS::Common::Span->new($chr, $beg, $beg + $span - 1, $_));
         }
         $beg += $step;
      }

      # variable data line
      else {
         ($beg, $score) = split /\t/;
         if ($Skip && $score =~ /inf|nan/i) {
         }
         else {
            $Code->(TESS::Common::Span->new($chr, $beg, $beg + $span - 1, $score));
         }
      }
   }

   $_fh->close();

}


# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;


