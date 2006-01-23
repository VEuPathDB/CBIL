
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

# ------------------------------- AbsPath --------------------------------

=pod

=head2 AbsPath

This class method takes a file name and prepends the value of PWD if
it does not begin with a '/'.

=cut

sub AbsPath {
   my $File = shift;

   my $Rv = $File =~ /^\// ? $File : "$ENV{PWD}/$File";

   return $Rv;
}

# ----------------------------- openForRead ------------------------------

sub SmartOpenForRead {
   my $File = shift;

   my $Rv;
   my $file;

   if ($File eq '-') {
      $file = '<-';
      $Rv = FileHandle->new($file);
   }

   elsif ($File =~ /\.Z$/) {
      $file = "zcat $File|";
      $Rv = FileHandle->new($file);
   }

   elsif ($File =~ /\.gz$/) {
      $file = "zcat $File|";
      $Rv = FileHandle->new($file);
   }

   elsif ($File =~ /:/) {
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

   if ($File eq /-/) {
      $Rv = FileHandle->new(STDOUT);
   }

   elsif ($File =~ /\.Z$/) {
      $Rv = FileHandle->new("|compress -c > $File");
   }

   elsif ($File =~ /\.gz$/) {
      $Rv = FileHandle->new("|zcat -c > $File");
   }

   elsif ($File = ~ /:/) {
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
