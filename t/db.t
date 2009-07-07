use strict;
use warnings;
use Test::More tests => 2;
use String::Random qw(random_regex);

use_ok 'CatalystX::ProtoWiki::Model::DBICSchemamodel';
use CatalystX::ProtoWiki::DBSchema;

my $schema = CatalystX::ProtoWiki::DBSchema->connect( 'dbi:SQLite:wiki.db' );

my $username = random_regex('\w{20}');
my $user = $schema->resultset( 'User' )->create( { username => $username, email => $username . '@test.test' } );
END { $user->delete if $user };

is( length $user->email_conf_code, 32, 'Email confirmation code generated' );

