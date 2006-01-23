
package CBIL::Util::App;

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;

   my $Self  = bless {}, $Class;

   my $Args  = scalar @_ ? ref $_[0] ? shift : {@_} : $Self->cla();

   $Self->init($Args);

   return $Self;
}

# --------------------------------- init ---------------------------------

sub init {
   my $Self = shift;
   my $Args = shift;

   $Self->setVerbose              ( $Args->{Verbose             } || $Args->{verbose});
   $Self->setDebug                ( $Args->{Debug               } || $Args->{debug} );

   return $Self;
}

# ------------------------------ accessors -------------------------------

sub getVerbose              { $_[0]->{'Verbose'           } }
sub setVerbose              { $_[0]->{'Verbose'           } = $_[1]; $_[0] }

sub getDebug                { $_[0]->{'Debug'             } }
sub setDebug                { $_[0]->{'Debug'             } = $_[1]; $_[0] }

# --------------------------------- log ----------------------------------

sub log {
   my $Self = shift;

   my $time = localtime;

   print STDERR join("\t", $time, @_), "\n";

   return $Self;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;

