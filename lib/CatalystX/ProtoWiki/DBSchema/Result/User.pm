package CatalystX::ProtoWiki::DBSchema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';
use String::Random 'random_regex';

__PACKAGE__->load_components('InflateColumn::DateTime', 'TimeStamp', 'UTF8Columns', 'Core');
__PACKAGE__->table('user');
__PACKAGE__->add_columns(
  'user_id',
  {
    data_type => 'INTEGER',
    is_nullable => 0,
    size => undef,
  },
  'username',
  {
    data_type => 'varchar',
    is_nullable => 0,
    size => 32,
  },
  'email',
  {
    data_type => 'varchar',
    is_nullable => 0,
    size => 254,
  },
  'email_confirmed',
  {
    data_type => 'char',
    default_value => undef,
    is_nullable => 1,
    size => 1,
  },
  'email_conf_code',
  {
    data_type => 'varchar',
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  'password',
  {
    data_type => 'varchar',
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  'status',
  {
    data_type => 'TEXT',
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

__PACKAGE__->set_primary_key('user_id');
__PACKAGE__->add_unique_constraint('username_unique', ['username']);
__PACKAGE__->add_unique_constraint('email_unique', ['email']);
__PACKAGE__->has_many(
  'pages',
  'CatalystX::ProtoWiki::DBSchema::Result::Page',
  { 'foreign.creator' => 'self.user_id' },
);
__PACKAGE__->has_many(
    'user_roles',
    'CatalystX::ProtoWiki::DBSchema::Result::UserRole',
    { 'foreign.user_id' => 'self.user_id' },
);

__PACKAGE__->utf8_columns(qw/username email/);

sub new {
    my ( $class, $attrs ) = @_;

    $attrs->{email_conf_code} = random_regex( '\w{32}' ) unless defined $attrs->{email_conf_code};

    my $new = $class->next::method($attrs);

    return $new;
}
1;
