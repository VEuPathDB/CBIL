#! /usr/bin/perl

=pod

=head1 Description

This is just a demo for CBIL::Util::EasyCsp.pm.  See further output for more.

=cut

use strict;

use CBIL::Util::EasyCsp;
use CBIL::Util::Disp;

CBIL::Util::Disp::Display
(CBIL::Util::EasyCsp::DoItAll
 ([ { h => "flag1",
      t => CBIL::Util::EasyCsp::BooleanType,
      o => "hi",
    },

    { h => 'demo of a single regexp matching constraints',
      t => CBIL::Util::EasyCsp::StringType,
      o => 'there',
      d => 'hello world',
      e => 'hello',
    },

    { h => 'another flag',
      t => CBIL::Util::EasyCsp::FloatType,
      o => 'xRange',
      l => 1,
      e => sub { @_ ? $_[0] > 0 : 'must be > 0' },
    },

    { h => 'shoe size',
      t => CBIL::Util::EasyCsp::FloatType,
      o => 'ShoeSize',
      r => 1,
      e => CBIL::Util::EasyCsp::RelatesTo('>=', 5),
    },
  ],
  "put your usage string here : this program demos the CBIL::Util::EasyCsp package",
  [ $0, 'CBIL::Util::EasyCsp', 'CBIL::Util::EasyCsp::Decl' ]
 )
);
