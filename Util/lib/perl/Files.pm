
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

use strict 'vars';

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
   my $Hint = shift || 'file';

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
      $file = "gunzip -c $File|";
      $Rv = FileHandle->new($file);
   }

   elsif ($File =~ /\.bz2$/) {
      $file = "bunzip2 -c $File|";
      $Rv = FileHandle->new($file);
   }

   elsif ($File =~ /:/) {
      my ($host, $remoteSpec) = split(':', $File);
      $file = "ssh $host cat $remoteSpec|";
      $Rv = FileHandle->new($file);
   }

   elsif ($File =~ /\|$/) {
      $file = $File;
      $Rv = FileHandle->new($file);
   }

   else {
      $file = "<$File";
      $Rv = FileHandle->new($file);
   }

   $Rv || die "Can not open ${Hint} '$File' for reading as '$file': $!";

   return $Rv;
}

# ----------------------------- openForWrite -----------------------------
sub SmartOpenForWrite {
   my $File = shift;
   my $Hint = shift || 'file';

   return output($File, $Hint, '>');
}

sub SmartOpenForAppend {
   my $File = shift;
   my $Hint = shift || 'file';

   return output($File, $Hint, '>>');
}

sub output {
   my $File = shift;
   my $Hint = shift;
   my $Mode = shift;

   my $Rv;

   my $file;

   if ($File eq '-') {
      $file = "$Mode-";
   }

   elsif ($File =~ /\.Z$/) {
      $file = "|compress -c $Mode $File";
   }

   elsif ($File =~ /\.gz$/) {
      $file = "| gzip -f -c $Mode $File";
   }

   elsif ($File =~ /\.bz2$/) {
      $file = "| bzip2 -f -c $Mode $File";
   }

   elsif ($File =~ /:/) {
      my ($host, $remoteSpec) = split(':', $File);
      $file = "|ssh $host cat \\> $remoteSpec";
   }

   elsif ($File =~ /^\|/ || $File =~ /^>/) {
      $file = $File;
   }

   else {
      $file = "$Mode$File";
   }

   $Rv = FileHandle->new($file);

   $Rv || die "Can not open $Hint '$File' for writing as '$file': $!";

   return $Rv;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;
