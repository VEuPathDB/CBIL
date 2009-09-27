
package CBIL::Bio::DbFfWrapper::Fantom;

=pod

=head1 Purpose

A simple wrapper for FANTOM full-length clone lists.

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
			my $_fantomClone = CBIL::Bio::DbFfWrapper::Fantom::Clone->new($_);
			last unless $Code->($_fantomClone);
	 }

	 return $Self;
}

# ======================================================================

package CBIL::Bio::DbFfWrapper::Fantom::Clone;

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
			$Self->setCloneId              ( $Args->{CloneId             } );
			$Self->setLibraryId            ( $Args->{LibraryId           } );
			$Self->setHost                 ( $Args->{Host                } );
			$Self->setVector               ( $Args->{Vector              } );
			$Self->setPrimer1              ( $Args->{Primer1             } );
			$Self->setPrimer2              ( $Args->{Primer2             } );
			$Self->setStrain               ( $Args->{Strain              } );
			$Self->setRearrayId            ( $Args->{RearrayId           } );
			$Self->setSetName              ( $Args->{SetName             } );
			$Self->setAccession            ( $Args->{Accession           } );
			$Self->setComment              ( $Args->{Comment             } );
			$Self->setIdCheck              ( $Args->{IdCheck             } );
	 }

	 elsif (ref $Args eq 'ARRAY') {
			my $i = 0;

			$Self->setCloneId              ( $Args->[$i++] );
			$Self->setLibraryId            ( $Args->[$i++] );
			$Self->setHost                 ( $Args->[$i++] );
			$Self->setVector               ( $Args->[$i++] );
			$Self->setPrimer1              ( $Args->[$i++] );
			$Self->setPrimer2              ( $Args->[$i++] );
			$Self->setStrain               ( $Args->[$i++] );
			$Self->setRearrayId            ( $Args->[$i++] );
			$Self->setSetName              ( $Args->[$i++] );
			$Self->setAccession            ( $Args->[$i++] );
			$Self->setComment              ( $Args->[$i++] );
			$Self->setIdCheck              ( $Args->[$i++] );

	 }

	 else {
			chomp $Args;
			$Self->init([split(/\t/,$Args)]);
	 }

	 return $Self
}

# ----------------------------------------------------------------------

sub getCloneId              { $_[0]->{'CloneId'                     } }
sub setCloneId              { $_[0]->{'CloneId'                     } = $_[1]; $_[0] }

sub getLibraryId            { $_[0]->{'LibraryId'                   } }
sub setLibraryId            { $_[0]->{'LibraryId'                   } = $_[1]; $_[0] }

sub getHost                 { $_[0]->{'Host'                        } }
sub setHost                 { $_[0]->{'Host'                        } = $_[1]; $_[0] }

sub getVector               { $_[0]->{'Vector'                      } }
sub setVector               { $_[0]->{'Vector'                      } = $_[1]; $_[0] }

sub getPrimer1              { $_[0]->{'Primer1'                     } }
sub setPrimer1              { $_[0]->{'Primer1'                     } = $_[1]; $_[0] }

sub getPrimer2              { $_[0]->{'Primer2'                     } }
sub setPrimer2              { $_[0]->{'Primer2'                     } = $_[1]; $_[0] }

sub getStrain               { $_[0]->{'Strain'                      } }
sub setStrain               { $_[0]->{'Strain'                      } = $_[1]; $_[0] }

sub getRearrayId            { $_[0]->{'RearrayId'                   } }
sub setRearrayId            { $_[0]->{'RearrayId'                   } = $_[1]; $_[0] }

sub getSetName              { $_[0]->{'SetName'                     } }
sub setSetName              { $_[0]->{'SetName'                     } = $_[1]; $_[0] }

sub getAccession            { $_[0]->{'Accession'                   } }
sub setAccession            { $_[0]->{'Accession'                   } = $_[1]; $_[0] }

sub getComment              { $_[0]->{'Comment'                     } }
sub setComment              { $_[0]->{'Comment'                     } = $_[1]; $_[0] }

sub getIdCheck              { $_[0]->{'IdCheck'                     } }
sub setIdCheck              { $_[0]->{'IdCheck'                     } = $_[1]; $_[0] }

# ----------------------------------------------------------------------

1;
