package CBIL::ISA::Contact;
use base qw(CBIL::ISA::Commentable);

use strict;

# Person Roles is an ontologyterm
sub setPersonRoles { $_[0]->{_person_roles} = $_[1] }
sub getPersonRoles { $_[0]->{_person_roles} }

sub setPersonLastName { $_[0]->{_person_last_name} = $_[1] }
sub getPersonLastName { $_[0]->{_person_last_name} }

sub setPersonMidInitials { $_[0]->{_person_mid_initials} = $_[1] }
sub getPersonMidInitials { $_[0]->{_person_mid_initials} }

sub setPersonFirstName { $_[0]->{_person_first_name} = $_[1] }
sub getPersonFIrstName { $_[0]->{_person_first_name} }

sub setPersonAddress { $_[0]->{_person_address} = $_[1] }
sub getPersonAddress { $_[0]->{_person_address} }

sub setPersonAffiliation { $_[0]->{_person_affiliation} = $_[1] }
sub getPersonAffiliation { $_[0]->{_person_affiliation} }

sub setPersonEmail { $_[0]->{_person_email} = $_[1] }
sub getPersonEmail { $_[0]->{_person_email} }

sub setPersonPhone { $_[0]->{_person_phone} = $_[1] }
sub getPersonPhone { $_[0]->{_person_phone} }

sub setPersonFax { $_[0]->{_person_fax} = $_[1] }
sub getPersonFax { $_[0]->{_person_fax} }

1;
