
package CBIL::Bio::UCSC;

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

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
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;


