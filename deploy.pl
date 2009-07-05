use lib 'lib';

use CatalystX::ProtoWiki::DBSchema;

my $schema = CatalystX::ProtoWiki::DBSchema->connect( 'dbi:SQLite:wiki.db' );
$schema->deploy;

