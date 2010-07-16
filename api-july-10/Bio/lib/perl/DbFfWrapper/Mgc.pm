
package CBIL::Bio::DbFfWrapper::Mgc;

=pod

=head1 Purpose

A simple wrapper for MGC full-length clone lists.

=cut

# ----------------------------------------------------------------------

use strict;

use FileHandle;

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

	 $Self->setFile                 ( $Args->{File                } );

	 return $Self;
}

# ----------------------------------------------------------------------

sub getFile                 { $_[0]->{'File'                        } }
sub setFile                 { $_[0]->{'File'                        } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

sub scanFile {
	 my $Self = shift;
	 my $Code = shift;

	 my $_f  = $Self->getFile();
	 my $_fh = FileHandle->new("<$_f")
	 || die "Can not open MCG clone file '$_f' : $!";

	 my $headers = <$_fh>;

	 while (<$_fh>) {
			my $_mgcClone = CBIL::Bio::DbFfWrapper::Mgc::Clone->new($_);
			last unless $Code->($_mgcClone);
	 }

	 return $Self;
}

# ======================================================================

package CBIL::Bio::DbFfWrapper::Mgc::Clone;

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

	 if (ref $Args eq 'HASH') {
			$Self->setSymbol               ( $Args->{Symbol              } );
			$Self->setGenBankDefLine       ( $Args->{GenBankDefLine      } );
			$Self->setLocusLinkId          ( $Args->{LocusLinkId         } );
			$Self->setUniGeneId            ( $Args->{UniGeneId           } );
			$Self->setImageId              ( $Args->{ImageId             } );
			$Self->setGenBankId            ( $Args->{GenBankId           } );
			$Self->setCloneLength          ( $Args->{CloneLength         } );
			$Self->setLibraryId            ( $Args->{LibraryId           } );
			$Self->setLibraryName          ( $Args->{LibraryName         } );
	 }

	 elsif (ref $Args eq 'ARRAY') {
			my $i = 0;
			$Self->setSymbol               ( $Args->[$i++] );
			$Self->setGenBankDefLine       ( $Args->[$i++] );
			$Self->setLocusLinkId          ( $Args->[$i++] );
			$Self->setUniGeneId            ( $Args->[$i++] );
			$Self->setImageId              ( $Args->[$i++] );
			$Self->setGenBankId            ( $Args->[$i++] );
			$Self->setCloneLength          ( $Args->[$i++] );
			$Self->setLibraryId            ( $Args->[$i++] );
			$Self->setLibraryName          ( $Args->[$i++] );
	 }

	 else {
			chomp $Args;
			$Self->init([split(/\t/,$Args)]);
	 }

	 return $Self
}

# ----------------------------------------------------------------------

sub getSymbol               { $_[0]->{'Symbol'                      } }
sub setSymbol               { $_[0]->{'Symbol'                      } = $_[1]; $_[0] }

sub getGenBankDefLine       { $_[0]->{'GenBankDefLine'              } }
sub setGenBankDefLine       { $_[0]->{'GenBankDefLine'              } = $_[1]; $_[0] }

sub getLocusLinkId          { $_[0]->{'LocusLinkId'                 } }
sub setLocusLinkId          { $_[0]->{'LocusLinkId'                 } = $_[1]; $_[0] }

sub getUniGeneId            { $_[0]->{'UniGeneId'                   } }
sub setUniGeneId            { $_[0]->{'UniGeneId'                   } = $_[1]; $_[0] }

sub getImageId              { $_[0]->{'ImageId'                     } }
sub setImageId              { $_[0]->{'ImageId'                     } = $_[1]; $_[0] }

sub getGenBankId            { $_[0]->{'GenBankId'                   } }
sub setGenBankId            { $_[0]->{'GenBankId'                   } = $_[1]; $_[0] }

sub getCloneLength          { $_[0]->{'CloneLength'                 } }
sub setCloneLength          { $_[0]->{'CloneLength'                 } = $_[1]; $_[0] }

sub getLibraryId            { $_[0]->{'LibraryId'                   } }
sub setLibraryId            { $_[0]->{'LibraryId'                   } = $_[1]; $_[0] }

sub getLibraryName          { $_[0]->{'LibraryName'                 } }
sub setLibraryName          { $_[0]->{'LibraryName'                 } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

1;
