package CBIL::Util::MultiPropertySet;

use strict;
use Carp;

# Similar to PropertySet, but, allows multiple sets in one file
# if a line starts with: "# /mySetName/ then that is used.
# propsDeclraration is a hash keyed on the names of the sets
# if $singleSet is set, then ignore other sets
sub new {
    my ($class, $propsFile, $propsDeclaration, $singleSet, $relax) = @_;

    my $self = {};
    bless($self, $class);

    $self->{props} = {};
    $self->{decl} = $propsDeclaration;
    $self->{file} = $propsFile;

    my $fatalError;

    foreach my $setName (keys(%{$propsDeclaration})) {
      next if ($singleSet && $setName ne $singleSet);
      foreach my $decl (@{$propsDeclaration->{$setName}}) {
        my $name = $decl->[0];
        my $value = $decl->[1];
        $self->{props}->{$setName}->{$name} = $value? $value : "REQD_PROP";
      }
    }

    open(F, $propsFile) || die "Can't open property file $propsFile";

    my $duplicateCheck;
    my $setName;
    my $setNames = {};
    while (<F>) {
      chomp;
      s/\s+$//;
      next if (!$_);
      if (/\# \/(\S+)\//) {
	$setName = $1;
	if ($setNames->{$setName}) {
	  print STDERR "'$setName' configured in duplicate\n";
	  $fatalError = 1;
	}
	$setNames->{$setName} = 1;
	next;
      }
      next if (/^\s*\#/);
      die "can't find set name" unless $setName;
      next if ($singleSet && $setName ne $singleSet);
      if (! /(\S+?)\s*=\s*(.+)/) {
	print STDERR "Can't parse '$_' in property file '$propsFile', set '$setName'\n";
	$fatalError = 1;
      }
      my $key = $1;
      my $value = $2;

      if ($duplicateCheck->{$setName}->{$key}) {
	print STDERR "Property name '$key' is duplicated in property file '$propsFile' for property set '$setName'\n";
	$fatalError = 1;
      }
      $duplicateCheck->{$setName}->{$key} = 1;

      if (!$relax && !$self->{props}->{$setName}->{$key}) {
	print STDERR "Invalid property name '$key' for '$setName' in property file '$propsFile'\n";
	$fatalError = 1;
      }

      # allow value to include $ENV{} expressions to include environment vars
      $value =~ s/\$ENV\{"?'?(\w+)"?'?\}/$ENV{$1}/g;

      $self->{props}->{$setName}->{$key} = $value;
    }
    close(F);

    foreach my $setName (keys %{$self->{props}}) {
      next if ($singleSet && $setName ne $singleSet);
      if (!$setNames->{$setName}) {
	print STDERR "No configuration found for '$setName'\n";
	$fatalError = 1;
      }
      foreach my $name (keys %{$self->{props}->{$setName}}) {
	if ($self->{props}->{$setName}->{$name} eq "REQD_PROP") {
	  print STDERR "Required property '$name' must be specified in property file '$propsFile' for set '$setName'\n";
	  $fatalError = 1;
	}
      }
    }

    die "Fatal PropertySet error(s)" if $fatalError;
    return $self;
}

sub getProp {
    my ($self, $setName, $name) = @_;

    my $value = $self->{props}->{$setName}->{$name};
    confess "trying to call getProp('$name') on invalid property name '$name' in set '$setName'\n" unless ($value ne "");
    return $value;
}

sub toString {
  my ($self, $setName) = @_;
  my $ret;
  foreach my $p (sort keys %{$self->{props}->{$setName}}){
    $ret .= "$p=$self->{props}->{$setName}->{$p}\n";
  }
  return $ret;
}


1;
