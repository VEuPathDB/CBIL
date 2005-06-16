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

    my $fatalError;

    foreach my $decl (@$propsDeclaration) {
        my $name = $decl->[0];
        my $value = $decl->[1];
        $self->{props}->{$name} = $value? $value : "REQD_PROP";
      }

    if ($propsFile) {
#      print STDERR "Reading properties from $propsFile\n";

      open(F, $propsFile) || die "Can't open property file $propsFile";

      my %duplicateCheck;
      while (<F>) {
        chomp;
        s/\s+$//;
        next if (!$_ || /^#/);
	if (! /(\S+?)\s*=\s*(.+)/) {
	  print STDERR "Can't parse '$_' in property file '$propsFile'\n";
	  $fatalError = 1;
	}
        my $key = $1;
        my $value = $2;

        if ($duplicateCheck{$key}) {
          print STDERR "Property name '$key' is duplicated in property file '$propsFile'\n";
          $fatalError = 1;
	}
        $duplicateCheck{$key} = 1;

        if (!$relax && !$self->{props}->{$key}) {
          print STDERR "Invalid property name '$key' in property file '$propsFile'\n";
          $fatalError = 1;
	}

        # allow value to include $ENV{} expressions to include environment vars
        $value =~ s/\$ENV\{"?'?(\w+)"?'?\}/$ENV{$1}/g;

        $self->{props}->{$key} = $value;
      }
      close(F);
    }

    foreach my $name (keys %{$self->{props}}) {
      if ($self->{props}->{$name} eq "REQD_PROP") {
        print STDERR "Required property '$name' must be specified in property file '$propsFile'\n";
	$fatalError = 1;
      }
    }

    die "Fatal PropertySet error(s)" if $fatalError;
    return $self;
}

sub getProp {
    my ($self, $name) = @_;

    my $value = $self->{props}->{$name};
    die "trying to call getProp('$name') on invalid property name '$name' " unless ($value ne "");
    return $value;
}

sub getAllProperties {
  my $self = shift;
  my $ret = "property = value, help\n----------------------\n";
  foreach my $p (sort keys %{$self->{props}}){
    $ret .= "$p = $self->{props}->{$p}".($self->{help}->{$p} ? ", \"$self->{help}->{$p}\"\n" : "\n");
  }
  return $ret;
}


1;
