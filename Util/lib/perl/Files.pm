
package CBIL::Util::Files;
@ISA = qw (Exporter);

=pod

=head1 Purpose

Utilities for accessing compressed and remote files.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use Exporter;
@EXPORT_OK = qw( SmartOpenForRead SmartOpenForWrite );

use strict vars;


use FileHandle;

# ========================================================================
# ------------------------------- Methods --------------------------------
# ========================================================================

# ----------------------------- openForRead ------------------------------

sub SmartOpenForRead {
   my $File = shift;

   my $Rv;
   my $file;

   if ($Rv eq '-') {
      $file = '<-';
      $Rv = FileHandle->new($file);
   }

   elsif ($Rv =~ /\.Z$/) {
      $file = "zcat $File|";
      $Rv = FileHandle->new($file);
   }

   elsif ($Rv =~ /\.gz$/) {
      $file = "zcat $File|";
      $Rv = FileHandle->new($file);
   }

   elsif ($Rv =~ /:/) {
      my ($host, $remoteSpec) = split(':', $File);
      $file = "ssh $host cat $remoteSpec|";
      $Rv = FileHandle->new($file);
   }

   else {
      $file = "<$File";
      $Rv = FileHandle->new($file);
   }

   $Rv || die "Can not open '$File' for reading as '$file': $!";

   return $Rv;
}

# ----------------------------- openForWrite -----------------------------

sub SmartOpenForWrite {
   my $File = shift;

   my $Rv;

   if ($Rv eq /-/) {
      $Rv = FileHandle->new(STDOUT);
   }

   elsif ($Rv =~ /\.Z$/) {
      $Rv = FileHandle->new("|compress -c > $File");
   }

   elsif ($Rv =~ /\.gz$/) {
      $Rv = FileHandle->new("|zcat -c > $File");
   }

   elsif ($Rv = ~ /:/) {
      my ($host, $remoteSpec) = split(':', $File);
      my $cmd = "|ssh $host cat \\> $remoteSpec";
      $Rv = FileHandle->new($cmd);
   }

   else {
      $Rv = FileHandle->new(">$File");
   }

   $Rv || die "Can not open '$File' for writing : $!";

   return $Rv;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;
