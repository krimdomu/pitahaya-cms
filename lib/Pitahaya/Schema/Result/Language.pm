#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::Result::Language;

use strict;
use warnings;
use Data::Dumper;
use Moo;

extends qw(DBIx::Class::Core);
with qw(Pitahaya::Schema::Base);

__PACKAGE__->load_components( 'Core', );

__PACKAGE__->table("language");
__PACKAGE__->add_columns(
    id => {
        data_type         => 'serial',
        is_auto_increment => 1,
        is_numeric        => 1,
    },
    master_site_id => {
        data_type   => 'integer',
        is_numeric  => 1,
        is_nullable => 0,
    },
    lang_site_id => {
        data_type   => 'integer',
        is_numeric  => 1,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to( "master_site", "Pitahaya::Schema::Result::Site", "master_site_id" );
__PACKAGE__->belongs_to( "lang_site", "Pitahaya::Schema::Result::Site", "lang_site_id" );

1;
