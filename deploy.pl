use lib 'lib';

use CatalystX::ProtoWiki::DBSchema;

my $schema = CatalystX::ProtoWiki::DBSchema->connect( 'dbi:SQLite:wiki.db' );
$schema->deploy;

my $admin = $schema->resultset( 'User' )->create( { username => 'admin', email => 'root@localhost', password => 'pass4admin', email_confirmed => 1 } );
my $role = $schema->resultset( 'Role' )->create( { role => 'admin' } );
$admin->add_to_roles( $role );
$schema->resultset( 'Page' )->create( { title => 'Home', body=> 'Fill in', creator => $admin->id } );

