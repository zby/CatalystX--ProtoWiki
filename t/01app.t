#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

use Test::WWW::Mechanize::Catalyst 'CatalystX::ProtoWiki';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok("/", "Application Running");

