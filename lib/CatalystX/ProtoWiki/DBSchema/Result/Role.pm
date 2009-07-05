package CatalystX::ProtoWiki::DBSchema::Result::Role;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('EncodedColumn', 'Core');
__PACKAGE__->table('role');
__PACKAGE__->add_columns(
  'role_id',
  {
    data_type => 'INTEGER',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  'role',
  {
    data_type => 'TEXT',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key('role_id');
__PACKAGE__->add_unique_constraint('role_unique', ['role']);
__PACKAGE__->has_many(
  'user_roles',
  'CatalystX::ProtoWiki::DBSchema::Result::UserRole',
  { 'foreign.role_id' => 'self.role_id' }
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-26 20:41:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R1c4S63v/JDVbVnnyeudKw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
