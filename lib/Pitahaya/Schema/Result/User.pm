#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::Result::User;

use strict;
use warnings;

use Data::Dumper;
use base qw(DBIx::Class::Core Pitahaya::Schema::Base);

__PACKAGE__->load_components( 'InflateColumn::Serializer', 'PassphraseColumn',
  'Core' );

__PACKAGE__->table("users");

__PACKAGE__->add_columns(
  id => {
    data_type         => 'serial',
    is_auto_increment => 1,
    is_numeric        => 1,
  },
  username => {
    data_type   => 'varchar',
    size        => 150,
    is_nullable => 0,
  },
  password => {
    data_type        => 'text',
    is_nullable      => 0,
    passphrase       => 'rfc2307',
    passphrase_class => 'SaltedDigest',
    passphrase_args  => {
      algorithm   => 'SHA-1',
      salt_random => 42,
    },
    passphrase_check_method => 'check_password',
  },
  email => {
    data_type   => 'varchar',
    size        => 250,
    is_nullable => 1,
  },
  data => {
    data_type        => 'jsonb',
    is_nullable      => 1,
    serializer_class => 'JSON',
  },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many( "pages", "Pitahaya::Schema::Result::Page",
  "creator_id" );

1;
