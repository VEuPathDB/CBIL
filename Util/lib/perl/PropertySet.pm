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
sub new {
    my ($class, $propsFile, $propsDeclaration) = @_;

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
      print STDERR "Reading properties from $propsFile\n";

      open(F, $propsFile) || die "Can't open property file $propsFile";

      while (<F>) {
	chomp;
	s/\s+$//;
	next if (!$_ || /^#/);
	die "Can't parse '$_' in props file $propsFile" unless /(\S+)\s*=\s*(.+)/; 
	my $key = $1;
	my $value = $2;

	die "Invalid property name '$key' in properties file $propsFile" unless $self->{props}->{$key};

	# allow value to include $ENV{} expressions to inlcude environment vars
	$value =~ s/\$ENV\{"?'?(\w+)"?'?\}/$ENV{$1}/g;

	$self->{props}->{$key} = $value;
      }
      close(F);
    }

    foreach my $name (keys %{$self->{props}}) {
	die "Required property '$name' must be specified in $propsFile" 
	    if ($self->{props}->{$name} eq "REQD_PROP");
    } 

    return $self;
}

sub getProp {
    my ($self, $name) = @_;

    my $value = $self->{props}->{$name};
    die "trying to get invalid property name '$name' " unless $value;
    return $value;
}


1;
