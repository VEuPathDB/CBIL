package CBIL::Util::PropertySet;

use strict;

# smart parsing of properties file.
# file is of the format:
# name=value
# '#' at beginning of line is a comment
#
# propDeclaration is a reference to an array of (name, default, comment) for
# each property.  if default is not provided, property is required.
#
# if $relax is set, then allow properties in the file that are not in the declaration.
sub new {
    my ($class, $propsFile, $propsDeclaration, $relax) = @_;

    my $self = {};
    bless($self, $class);

    $self->{props} = {};
    $self->{decl} = $propsDeclaration;
    $self->{file} = $propsFile;

    foreach my $decl (@$propsDeclaration) {
        my $name = $decl->[0];
        my $value = $decl->[1];
        $self->{props}->{$name} = $value? $value : "REQD_PROP";
      }

    if ($propsFile) {
#      print STDERR "Reading properties from $propsFile\n";

      open(F, $propsFile) || die "Can't open property file $propsFile";

      while (<F>) {
        chomp;
        s/\s+$//;
        next if (!$_ || /^#/);
        die "Can't parse '$_' in property file '$propsFile'" unless /(\S+?)\s*=\s*(.+)/;
        my $key = $1;
        my $value = $2;

        die "Invalid property name '$key' in property file '$propsFile'" unless $relax || $self->{props}->{$key};

        # allow value to include $ENV{} expressions to include environment vars
        $value =~ s/\$ENV\{"?'?(\w+)"?'?\}/$ENV{$1}/g;

        $self->{props}->{$key} = $value;
      }
      close(F);
    }

    foreach my $name (keys %{$self->{props}}) {
        die "Required property '$name' must be specified in property file '$propsFile'"
            if ($self->{props}->{$name} eq "REQD_PROP");
    }

    return $self;
}

sub getProp {
    my ($self, $name) = @_;

    my $value = $self->{props}->{$name};
    die "trying to call getProp('$name') on invalid property name '$name' " unless ($value ne "");
    return $value;
}


1;
