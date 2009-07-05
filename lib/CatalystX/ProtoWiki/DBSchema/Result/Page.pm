package CatalystX::ProtoWiki::DBSchema::Result::Page;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components('InflateColumn::DateTime', 'TimeStamp', 'UTF8Columns', 'Core');
__PACKAGE__->table('page');
__PACKAGE__->add_columns(
  'page_id',
  {
    data_type => 'INTEGER',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  'title',
  {
    data_type => 'varchar',
    default_value => undef,
    is_nullable => 1,
    size => 256,
  },
  'creator',
  {
    data_type => 'integer',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  'body',
  {
    data_type => 'text',
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  't_created',
  {
    data_type => 'timestamp',
    default_value => undef,
    is_nullable => 1,
    size => undef,
    set_on_create => 1,
  },
  't_updated',
  {
    data_type => 'timestamp',
    default_value => undef,
    is_nullable => 1,
    size => undef,
    set_on_create => 1, set_on_update => 1,
  },
);
__PACKAGE__->set_primary_key('page_id');
__PACKAGE__->add_unique_constraint(['title']);
__PACKAGE__->belongs_to(
  'creator',
  'CatalystX::ProtoWiki::DBSchema::Result::User',
  { user_id => 'creator' },
);


use overload '""' => sub {$_[0]->id}, fallback => 1;
__PACKAGE__->utf8_columns(qw/title body/);

1;
