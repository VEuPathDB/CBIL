#!/usr/bin/perl

=pod
=head1 Name

C<csp::topic> - a hierarchical element in a C<csp::dialog>.

=head1 Description

=head1 Configuration

C<CSP_TOFORM_ICON>

C<CSP_TOHELP_ICON>

=head1 Methods

=over4

=cut

package CBIL::CSP::Topic;

BEGIN {
  warn ">>> CBIL::CSP::Topic\n";
}

@ISA = qw( CBIL::CSP::Item );

use strict "vars";

use CBIL::CSP::Item;

# ----------------------------------------------------------------------
=pod
=item new

creates a new topic.

Arguments:

C<item> arguments as well as these:

=cut

sub new {
  my $class = shift;
  my $args  = shift;
  
  return undef unless $args->ensure();
  
  my $me = new CBIL::CSP::Item($args);
  
  bless $me, $class;
  
  return $me;
}
  
# ----------------------------------------------------------------------
=pod
=item addItem

adds an item to a topic.

Arguments:

C<items> is a reference to a list of items to add.

=cut

sub addItems {
  my $me = shift;
  my $args = shift;
  
  return undef unless $args->ensure('items');
  
  foreach (@ {$args->{items}}) {
    push(@{$me->{items}}, $_);
  }
}

# ----------------------------------------------------------------------
=pod
=item makeDisplay

adds HTML for display of topic and items under it.

Arguments:

C<prefix> text to put before each item.

C<suffix> text to end each item.

=cut

sub makeDisplay {
  my $me = shift;
  my $args = shift;
  
  #return undef unless $args->ensure('prefix', 'suffix');
  
  # get somethings from the style_config.
  my $bkgClr = $me->{style_config}->{CSP_TOPIC_BKGCLR};
  my $hlpIcn = $me->{style_config}->{CSP_TOHELP_ICON};
  
  # link to help (add target)
  my $hlpLnk = qq{<a href="\#$me->{name}.hlp">$hlpIcn</a>};
  
  # the topic itself;
  my $h_header 
    = $me->tableRow(new TO 
		    +{viz => $me->tableData(new TO
					    +{viz => $me->{text},
					      bgcolor =>$bkgClr,
					      align => 'left'
					     }),
		     });
  
  # sub items contained in a table
  my $h_items;

  if (defined $me->{items} and scalar @{$me->{items}} > 0) {
    my $item; foreach $item (@ {$me->{items}}) {
      $h_items .= $me->tableRow(new TO 
				+{viz => $item->makeDisplay(),
				  align => 'left',
				 });
    }
  }

  # there are no items in topic; show an error message
  else {
    $h_items 
      = $me->tableRow(new TO 
		      +{viz => $me->tableData(new TO 
					      +{viz => $me->{style_config}->{CSP_Topic_EmptyMsg},
						bgcolor => $me->{style_config}->{CSP_Error_Bgcolor},
					       })
		       });
  }
  
  my $h_itemsTable
    = $me->tableRow(new TO
		    +{viz => 
		      $me->tableData(new TO
				     +{viz => 
				       $me->table(new TO
						  +{viz => $h_items,
						    '!' => "topic: items for $me->{name}",
						   })
				      }),
		     });
  
  # return the HTML to caller.
  my $rv = $me->tableData(new CBIL::Util::A +{viz =>
				   $me->table(new TO 
					      +{viz => $h_header . $h_itemsTable,
						'!' => "topic: whole thing for $me->{name}",
					       }),
				  });
  return $rv;
}

# ----------------------------------------------------------------------
=pod
=item makeHelp

adds HTML help for topic and items under it.

=cut

sub makeHelp {
 my $me = shift;
  my $args = shift;
  
  #return undef unless $args->ensure('prefix', 'suffix');
  
  my $rv;
  
  # get some things from the style_config.
  my $frmIcn = $me->{style_config}->{CSP_TOFORM_ICON};
  
  # link to form (add target).
  my $frmLnk = $me->formLink(new SO +{ text => $frmIcn });
  
  my $rv;
  
  # link back to form
  $rv .= $frmLnk;
  
  # title for this section of help
  "<h3>Topic: '$me->{text}'</h3>"
  
  # help text for the topic
  . $me->{help} . "<p>"
  
  # see also section
  . $me->seeAlso()
  
  . "\n";
  
  
  return $rv;
  
}
  
# ----------------------------------------------------------------------
=pod
=item table

Overrides others to set borders based on config_style.

=cut

sub table {
  my $me = shift;
  my $args = shift;

  if (not defined $args->{border} 
      and defined $me->{style_config}->{CSP_Topic_Borders}
      and $me->{style_config}->{CSP_Topic_Borders} != 0) {
    $args->{border} = $me->{style_config}->{CSP_Topic_Borders} 
  }

  return $me->SUPER::table($args);
}

# ----------------------------------------------------------------------
=pod
=back
=cut 

BEGIN {
  warn "<<< CBIL::CSP::Topic\n";
}

1;
