
package CBIL::Util::Configuration;

=head1 NAME

C<Configuration> - a configuration object.

=head1 DESCRIPTION

Basically, it is a hash which can be loaded from a user-editable file
which can be documented.

=head1 METHODS

=over 4

=cut

use strict 'vars';
use FileHandle;
use Carp;

=item new

Creates a new configuration object.  Configuration is loaded from a file 
via a list of key/value pairs.  No filtering is performed at the moment and 
no defaults are provided.

Arguments:

C<CONFIG_FILE> (opt) name of a file to read for configuration.

=cut

sub new {
  my $class = shift;
  my $args  = shift;

  my $self = {};
  bless $self, $class;

  $self->load($args);

  return $self;
}

# ----------------------------------------------------------------------

=item add

Adds definitions from an object to the configuration.

Arguments:

All keys in input C<A> are copied.

=cut

sub add {
  my $self = shift;
  my $args = shift;

  foreach (keys %$args) {
     $self->{$_} = $args->{$_};
  }

}

# ----------------------------------------------------------------------

=item load

loads parameters from a file.  Current configuration is not erase prior to 
loading.

Arguments:

C<CONFIG_FILE> or C<ConfigFile> (req) name of a file to read for configuration.
C<Delimiter> (opt) to split lines.

=cut

sub load {
  my $self = shift;
  my $args = shift;

  if (my $config_f = $args->{ConfigFile} || $args->{'CONFIG_FILE'}) {
     if (my $config_fh = FileHandle->new("<$config_f")) {
        my $delim_rx = $args->{Delimiter} || '\s+';

        while (<$config_fh>) {
           chomp;

           # skip comments
           if (/^\#/) {
              ;
           }

           # key-value pairs
           elsif (/\s*(.+?)$delim_rx(.*)/) {
              $self->{$1} = $2;
           }
        }
        $config_fh->close();
     }

     else {
        carp("Unable to open '$config_f' to read the configuration: $!");
        return undef;
     }
	}

  return $self;
}

# ----------------------------------------------------------------------

=item save

C<save> writes the object to a file in a format suitable for reloading.

Arguments:

C<CONFIG_FILE> writes to this file.

=cut

sub save {
  my $self = shift;
  my $args = shift;

  my $rv;

  if (my $config_f = $args->{ConfigFile} || $args->{'CONFIG_FILE'}) {
     if (my $config_fh = FileHandle->new(">$config_f")) {
        my $delim = $args->{Delimiter} || "\t";
        foreach (sort keys %$self) {
           print $config_fh "$_$delim$args->{$_}\n";
        }
        $config_fh->close();
        $rv = 1;
     }
  }

  return $rv;
}

=pod
=item lookup

Looks up the value of a tag in the configuration.  Caller must provide
a default and a list of possible tag names, usually abberviations.

First argument is the default value, the rest are tag strings.

=cut

sub lookup {
  my $Me      = shift;
  my $Default = shift;
  my @Tags    = @_;

  my $rv = $Default;
  my $tag;
  foreach $tag (@Tags) {
    if (exists $Me->{$tag}) {
      $rv = $Me->{$tag};
      last;
    }
  }
  
  return $rv;
}

# ----------------------------------------------------------------------

=back

=cut

1;


