#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
BEGIN { $ENV{EMAIL_SENDER_TRANSPORT} = 'Test' }

use Test::WWW::Mechanize::Catalyst 'CatalystX::ProtoWiki';
use String::Random qw(random_regex);

my $mech = Test::WWW::Mechanize::Catalyst->new;
my $schema = CatalystX::ProtoWiki::DBSchema->connect( 'dbi:SQLite:wiki.db' );

$mech->get_ok('/', 'Application Running');
$mech->get_ok('/register', 'Registration Page' );
my $username = random_regex('\w{20}');
$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            'email' => $username . '@example.com' ,
            'username' => $username,
            'password' => 'testpass',
            'password_' => 'testpass',
        }
    },
    'Registering user'
);
my $user = $schema->resultset( 'User' )->search( { username => $username } )->first;
END { $user->delete if $user };
ok( $user, 'User exists in db' );
my @deliveries = Email::Sender::Simple->default_transport->deliveries;
is( scalar @deliveries, 1, 'Confirmation email generated' );
my $body = $deliveries[0]->{email}->get_body;
$body =~ qr{(http://\S+) };
my $link = $1;
$mech->get_ok($link, 'Confirmation page');
$user->discard_changes;
ok( $user->email_confirmed, 'Email confirmed' );

