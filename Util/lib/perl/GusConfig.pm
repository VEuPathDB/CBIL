package Common::GusConfig;

use strict;

use CBIL::Util::PropertySet;

my @properties = 
(
 ["login",         "",  ""],
 ["password",   "",  ""],
 ["database",   "",  ""],
 ["readOnlyLogin",         "",  ""],
 ["readOnlyPassword",   "",  ""],
 ["readOnlyDatabase",   "",  ""],
);

# param gusconfigfile - an optional file of 'name=value'.
#                       default = $ENV{GUS_CONFIG_FILE}
sub new {
  my ($class, $gusConfigFile) = @_;

  my $self = {};
  bless($self, $class);

  $gusConfigFile = $ENV{GUS_CONFIG_FILE}if (!$gusconfigfile);
  $self->{propertySet} = CBIL::Util::PropertySet->new($gusConfigFile,\@properties);
}


sub getLogin {
  return $self->{propertySet}->getProp('login');
}

sub getPassword {
  return $self->{propertySet}->getProp('password');
}

sub getDatabase {
  return $self->{propertySet}->getProp('database');
}

sub getReadOnlyLogin {
  return $self->{propertySet}->getProp('readOnlylogin');
}

sub getReadOnlyPassword {
  return $self->{propertySet}->getProp('readOnlypassword');
}

sub getReadOnlyDatabase {
  return $self->{propertySet}->getProp('readOnlydatabase');
}
