#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::Result::MediaType;

use strict;
use warnings;
use Data::Dumper;

use base qw(DBIx::Class::Core Pitahaya::Schema::Base);

__PACKAGE__->load_components(
  'Core',
);

__PACKAGE__->table("media_type");
__PACKAGE__->add_columns(
  id => {
    data_type         => 'serial',
    is_auto_increment => 1,
    is_numeric        => 1,
  },
  site_id => {
    data_type   => 'integer',
    is_numeric  => 1,
    is_nullable => 0,
  },
  name => {
    data_type   => 'varchar',
    size        => 150,
    is_nullable => 0,
  },
  description => {
    data_type   => 'varchar',
    size        => 500,
    is_nullable => 1,
  },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to( "site", "Pitahaya::Schema::Result::Site", "site_id" );
__PACKAGE__->has_many( "medias", "Pitahaya::Schema::Result::Page", "type_id" );


1;
