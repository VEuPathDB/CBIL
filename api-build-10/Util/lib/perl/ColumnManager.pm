
package CBIL::Util::ColumnManager;

=pod

=head1 Purpose

Helps manage column names in a file.

=cut

# ========================================================================
# ----------------------------- Declarations -----------------------------
# ========================================================================

use strict;

use Fcntl qw( :seek );

use CBIL::Util::Files;

# ========================================================================
# ---------------------------- Global Methods ----------------------------
# ========================================================================

# ---------------------------- MakeDictionary ----------------------------

sub MakeDictionary {
   my $Text        = shift;
   my $Rx          = shift || "\t";
   my $StripQuotes = shift || 0;

   my %Rv;

   $Text = [ split $Rx, $Text] unless ref $Text;

   my $maybeStripQuotesCode = sub {
     my $junk = shift;

     if ($StripQuotes) {
       $junk =~ s/^[\'\"]//;
       $junk =~ s/[\'\"]$//;
     }

     return $junk;
   };

   my @cols;

   foreach my $col (@$Text) {

     # if we have a list of columns, then we need to strip each and
     # join them up.
     if (ref $col) {
       $col = join('-',
		   map { $maybeStripQuotesCode->($_) } @$col
		  );
     }

     # we can just strip itself.
     else {
       $col = $maybeStripQuotesCode->($col);
     }

     push(@cols, $col);
   }
   
   $Rv{NAMES} = [ @cols ];

   for (my $col_i = 0; $col_i < @cols; $col_i++) {
      $Rv{ORDER}->{$cols[$col_i]} = $col_i;
   }

   return wantarray ? %Rv : \%Rv;
}

# ----------------------------- MakeRowHash ------------------------------

sub MakeRowHash {
   my $Text        = shift;
   my $Cols        = shift;
   my $Rx          = shift || "\t";
   my $StripQuotes = shift || 0;

   my %Rv;

   my @cols = map { 
     if ($StripQuotes) {
       $_ =~ s/^[\'\"]//; $_ =~ s/[\'\"]$//;
     }
     $_
   } split $Rx, $Text;

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

=pod

=head1 Attributes

=over 4

=item * File - string - name of file to process

=item * FileHandle - file handle - process

=item * RemoveWhiteSpace - boolean - not referenced

=item * Cols - can be a array ref to names to be used. 

Leave blank to retrieve cols from header of file.

=item * DelimiterRx - split lines using this delimter regular expression

  Defaults to a tab character.

=item * UseColumnOrdinals - boolean - use column ordinals, i.e., 1, 2, ... to access columns.

=item * Callback - code ref - function to call to process each row.

  Called with row and row number as input.

=item * SkipRowsN - int - skip this many rows before processing

=item * StripQuotes - boolean - strip enclosing quotes from each field.

=item * ShiftHeaders - int - shift headers this many columns to the right before using.

=back

=cut

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
   $Self->setCallback             ( $Args->{Callback            } || $Args->{Code});
   $Self->setSkipRowsN            ( $Args->{SkipRowsN           } );
   $Self->setStripQuotes          ( $Args->{StripQuotes         } );
   $Self->setShiftHeaders         ( $Args->{ShiftHeaders        } );
   $Self->setHeaderRowsN          ( $Args->{HeaderRowsN         } || 1 );
   $Self->setHeaderRx             ( $Args->{HeaderRx            } );
   $Self->setDelimiterRx          ( $Args->{DelimiterRx         } || "\t" );

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

sub getSkipRowsN            { $_[0]->{'SkipRowsN'         } }
sub setSkipRowsN            { $_[0]->{'SkipRowsN'         } = $_[1]; $_[0] }

sub getStripQuotes          { $_[0]->{'StripQuotes'       } }
sub setStripQuotes          { $_[0]->{'StripQuotes'       } = $_[1]; $_[0] }

sub getShiftHeaders         { $_[0]->{'ShiftHeaders'      } }
sub setShiftHeaders         { $_[0]->{'ShiftHeaders'      } = $_[1]; $_[0] }

sub getHeaderRowsN          { $_[0]->{'HeaderRowsN'       } }
sub setHeaderRowsN          { $_[0]->{'HeaderRowsN'       } = $_[1]; $_[0] }

sub getHeaderRx             { $_[0]->{'HeaderRx'          } }
sub setHeaderRx             { $_[0]->{'HeaderRx'          } = $_[1]; $_[0] }

sub getDelimiterRx          { $_[0]->{'DelimiterRx'       } }
sub setDelimiterRx          { $_[0]->{'DelimiterRx'       } = $_[1]; $_[0] }

# ========================================================================
# ---------------------------- Fancy Methods -----------------------------
# ========================================================================

=pod

=head1 Column Definitions

=cut

# ------------------------------- initCols -------------------------------

=pod

=head2 C<initCols>

This method ...

=cut

sub initCols {
  my $Self = shift;
  my $File = shift || $Self->getFileHandle() || $Self->getFile();

  if (not $Self->getCols()) {

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

      my $delimiterRx = $Self->getDelimiterRx();
      my $headerRowsN = $Self->getHeaderRowsN();
      my $shiftN      = $Self->getShiftHeaders();
      my @shift       = ( '' x $shiftN );

      my @jointHeaders;

      for (my $i = 0; $i < $headerRowsN; $i++) {
        my $line = <$File>;
        chomp $line;
        $line =~ s/\cM$//;

        my @headers = split /$delimiterRx/, $line;

        my %headersN;
        for (my $i = 0; $i < @headers; $i++) {
          if ($headersN{$headers[$i]}++) {
            $headers[$i] .= '-'. $headersN{$headers[$i]};
          }
        }

        unshift(@headers, @shift) if $shiftN;

        for (my $j = 0; $j < @headers; $j++) {
          push(@{$jointHeaders[$j]}, $headers[$j]);
        }
      }

      $Self->setCols(scalar MakeDictionary(\@jointHeaders, undef, $Self->getStripQuotes()));
    }
  }

  elsif (ref $Self->getCols() eq 'ARRAY') {
    $Self->setCols(scalar MakeDictionary( $Self->getCols(), undef, $Self->getStripQuotes()));
  }

  return $Self;
}

# ----------------------------- processFile ------------------------------

=pod

=head1 Processing a File

Processing proceeds with either the C<FileHandle> if it is TRUE or the
C<File> which is opened with C<CBIL::Util::Files::SmartOpenForRead>.

If there is a C<HeaderRx> any initial lines that begin with the RX are
skipped.

C<SkipRowsN> lines are skipped.

Columns names are initialized.

The rest of the file is read, converted to hash refs, and passed to
C<Callback>.  The arguments are the row hash ref, row number (starting
with 1), and the line text.  The return value of C<Callback> is
ignored.

=cut

sub processFile {
  my $Self = shift;
  my $File = shift || $Self->getFileHandle() || $Self->getFile();

  if (not ref $File) {
    $File = CBIL::Util::Files::SmartOpenForRead($File);
    if (not $Self->getFileHandle()) {
      $Self->setFileHandle($File);
    }
  }

  if (my $headerRx = $Self->getHeaderRx()) {
    my $startFilePos = $File->tell();
    while (1) {
      my $line = <$File>;
      if ($line =~ /^$headerRx/) {
        $startFilePos = $File->tell();
      }
      else {
        $File->seek($startFilePos,SEEK_SET);
        last;
      }
    }
  }

  my $skip_n = $Self->getSkipRowsN() || 0;
  for (my $i = 1; $i <= $skip_n; $i++) { <$File> }

  my $_cols  = $Self->initCols($File)->getCols();
  my $sq_b   = $Self->getStripQuotes();
  my $_code  = $Self->getCallback();
  my $_fh    = $Self->getFileHandle();
  my $delimiterRx = $Self->getDelimiterRx();

  my $row_o  = 0;

  while (<$_fh>) {
    chomp;
    $_ =~ s/\cM$//;

    my $_row = MakeRowHash($_, $_cols, $delimiterRx, $sq_b);

    $_code && $_code->($_row, ++$row_o, $_);
  }

  $_fh->close();

  return $Self;
}

# ========================================================================
# ---------------------------- End of Package ----------------------------
# ========================================================================

1;

