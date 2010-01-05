
package CBIL::Util::ColumnManager;

=pod

=head1 Purpose

Helps manage column names in a file.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

use CBIL::Util::Files;

# ========================================================================
# ---------------------------- Global Methods ----------------------------
# ========================================================================

# ---------------------------- MakeDictionary ----------------------------

sub MakeDictionary {
   my $Text = shift;
   my $Rx   = shift || "\t";

   my %Rv;

   my @cols = split $Rx, $Text;

   $Rv{NAMES} = [ @cols ];

   for (my $col_i = 0; $col_i < @cols; $col_i++) {
      $Rv{ORDER}->{$cols[$col_i]} = $col_i;
   }

   return wantarray ? %Rv : \%Rv;
}

# ----------------------------- MakeRowHash ------------------------------

sub MakeRowHash {
   my $Text = shift;
   my $Cols = shift;
   my $Rx   = shift || "\t";

   my %Rv;

   my @cols = split $Rx, $Text;

   if ($Cols) {
      for (my $i = 0; $i < @cols; $i++) {
         $Rv{$Cols->{NAMES}->[$i]} = $cols[$i];
      }
   }

   else {
      for (my $i = 0; $i < @cols; $i++) {
         $Rv{$i+1} = $cols[$i];
      }
   }

   return wantarray ? %Rv : \%Rv;
}

# ========================================================================
# -------------------------------- Basics --------------------------------
# ========================================================================

# --------------------------------- new ----------------------------------

sub new {
   my $Class = shift;

   my $Self = bless {}, $Class;
 
   $Self->init(@_);

   return $Self;
}

# --------------------------------- init ---------------------------------

sub init {
   my $Self = shift;
   my $Args = ref $_[0] ? shift : {@_};

   $Self->setFile                 ( $Args->{File                } );
   $Self->setFileHandle           ( $Args->{FileHandle          } );
   $Self->setRemoveWhiteSpace     ( $Args->{RemoveWhiteSpace    } );
   $Self->setCols                 ( $Args->{Cols                } );
   $Self->setUseColumnOrdinals    ( $Args->{UseColumnOrdinals   } );
   $Self->setCallback             ( $Args->{Callback            } );

   return $Self;
}

# ------------------------------ accessors -------------------------------

sub getFile                 { $_[0]->{'File'              } }
sub setFile                 { $_[0]->{'File'              } = $_[1]; $_[0] }

sub getFileHandle           { $_[0]->{'FileHandle'        } }
sub setFileHandle           { $_[0]->{'FileHandle'        } = $_[1]; $_[0] }

sub getRemoveWhiteSpace     { $_[0]->{'RemoveWhiteSpace'  } }
sub setRemoveWhiteSpace     { $_[0]->{'RemoveWhiteSpace'  } = $_[1]; $_[0] }

sub getCols                 { $_[0]->{'Cols'              } }
sub setCols                 { $_[0]->{'Cols'              } = $_[1]; $_[0] }

sub getUseColumnOrdinals    { $_[0]->{'UseColumnOrdinals' } }
sub setUseColumnOrdinals    { $_[0]->{'UseColumnOrdinals' } = $_[1]; $_[0] }

sub getCallback             { $_[0]->{'Callback'          } }
sub setCallback             { $_[0]->{'Callback'          } = $_[1]; $_[0] }


# ========================================================================
# ---------------------------- Fancy Methods -----------------------------
# ========================================================================

# ------------------------------- initCols -------------------------------

sub initCols {
   my $Self = shift;
   my $File = shift || $Self->getFileHandle() || $Self->getFile();

   if (not ref $File) {
      $File = CBIL::Util::Files::SmartOpenForRead($File);
      if (not $Self->getFileHandle()) {
         $Self->setFileHandle($File);
      }
   }

   if ($Self->getUseColumnOrdinals()) {
      $Self->setCols(undef);
   }

   else {
      my $line = <$File>;
      chomp $line;
      $Self->setCols(scalar MakeDictionary($line));
   }

   return $Self;
}

# ----------------------------- processFile ------------------------------

sub processFile {
   my $Self = shift;
   my $File = shift || $Self->getFileHandle() || $Self->getFile();

   my $_cols = $Self->initCols($File)->getCols();

   my $_code = $Self->getCallback();

   my $_fh = $Self->getFileHandle();

   while (<$_fh>) {
      chomp;

      my $_row = MakeRowHash($_, $_cols);

      $_code && $_code->($_row);
   }

   $_fh->close();

   return $Self;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;
