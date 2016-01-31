#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::Result::ContentType;

use strict;
use warnings;
use Data::Dumper;
use Moo;

extends qw(DBIx::Class::Core);
with qw(Pitahaya::Schema::Base);

__PACKAGE__->load_components( 'Core', );

__PACKAGE__->table("content_type");
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
    class => {
        data_type   => 'varchar',
        size        => 500,
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key( qw/id site_id/ );

__PACKAGE__->belongs_to( "site", "Pitahaya::Schema::Result::Site", "site_id" );
__PACKAGE__->has_many( "pages", "Pitahaya::Schema::Result::Page", {
  "foreign.content_type_id" => "self.id",
  "foreign.site_id"         => "self.site_id",
});

1;
