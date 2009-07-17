#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
BEGIN { $ENV{EMAIL_SENDER_TRANSPORT} = 'Test' }

use Test::WWW::Mechanize::Catalyst 'CatalystX::ProtoWiki';
use String::Random qw(random_regex);

my $mech = Test::WWW::Mechanize::Catalyst->new;
my $schema = CatalystX::ProtoWiki::DBSchema->connect( 'dbi:SQLite:wiki.db' );

$mech->get_ok("/login", 'Login page');
$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            username => 'admin',
            password => 'pass4admin',
        }
    },
    'Logging in'
);
$mech->content_contains( 'Logged in: admin' );
my $title = random_regex('\w{20}');
$mech->get_ok("/page/$title", 'New page OK');
my $body = random_regex('\w{8} ' x 40) . 'a';
$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            'body' => $body,
        }
    },
    'Creating page'
);
my $page = $schema->resultset( 'Page' )->search( { title => $title } )->first;
#END { $page->delete if $page };
ok( $page, 'New page exists in db' );
is( $page->body, $body, 'Body created' );

