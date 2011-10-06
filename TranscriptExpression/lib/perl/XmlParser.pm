package CBIL::TranscriptExpression::XmlParser;

use strict;

use XML::Simple;

use Data::Dumper;

use CBIL::TranscriptExpression::Error;

sub getXmlFile { $_[0]->{xml_file} }
sub setXmlFile { $_[0]->{xml_file} = $_[1] }

sub new {
  my ($class, $xmlFile) = @_;

  unless(-e $xmlFile) {
    CBIL::TranscriptExpression::Error->new("XML File $xmlFile doesn't exist.")->throw();
  }

  my $self = bless {}, $class;
  $self->setXmlFile($xmlFile);

  return $self;
}


sub parse {
  my ($self) = @_;

  my $xmlFile = $self->getXmlFile();

  my $xml = XMLin($xmlFile,  'ForceArray' => 1);

  my $defaults = $xml->{globalDefaultArguments}->[0]->{property};

  # Hash for things which can be referenced
  my $globalReferencable = $xml->{globalReferencable}->[0]->{property};
  foreach my $ref (keys %$globalReferencable) {
    my $value = $globalReferencable->{$ref}->{value};
    $globalReferencable->{$ref} = $value;
  }

  my $steps = $xml->{step};

  foreach my $step (@$steps) {
    my $args = {};

    foreach my $default (keys %$defaults) {
      my $defaultValue = $defaults->{$default}->{value};

      if(ref($defaultValue) eq 'ARRAY') {
        my @ar = @$defaultValue;
        $args->{$default} = \@ar;
      }
      else {
        $args->{$default} = $defaultValue;
      }
    }

    my $properties = $step->{property};

    foreach my $property (keys %$properties) {
      my $value = $properties->{$property}->{value};
      my $isReference = $properties->{$property}->{isReference};

      if(ref($value) eq 'ARRAY') {
        push(@{$args->{$property}}, @$value);
      }
      elsif($isReference) {
        eval "\$args->{$property} = $value;";

        if($@) {
          CBIL::TranscriptExpression::Error->new("ERROR:  isReference specified but value could not be evaluated:  $@")->throw();
        }
      }
      else {
          $args->{$property} = $value;
      }
    }

    $step->{arguments} = $args;
  }

  return $steps;
}

1;
