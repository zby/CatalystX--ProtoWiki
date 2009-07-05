package CatalystX::ProtoWiki::DBSchema::Result::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('EncodedColumn', 'Core');
__PACKAGE__->table('user_role');
__PACKAGE__->add_columns(
  'id',
  {
    data_type => 'INTEGER',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  'user_id',
  {
    data_type => 'INTEGER',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  'role_id',
  {
    data_type => 'INTEGER',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(
  'user',
  'CatalystX::ProtoWiki::DBSchema::Result::User',
  { user_id => 'user_id' }
);
__PACKAGE__->belongs_to(
  'role',
  'CatalystX::ProtoWiki::DBSchema::Result::Role',
  { role_id => 'role_id' }
);


1;
