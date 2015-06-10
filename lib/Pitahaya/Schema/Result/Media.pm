#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::Result::Media;

use strict;
use warnings;
use Data::Dumper;
use Mojo::Util 'url_escape';
use Encode;

use base qw(DBIx::Class::Core Pitahaya::Schema::ContentBase);

__PACKAGE__->load_components(
  'InflateColumn::Serializer', 'Tree::NestedSet',
  'InflateColumn::DateTime',   'Core'
);

__PACKAGE__->table("media");
__PACKAGE__->add_columns(
  id => {
    data_type         => 'serial',
    is_auto_increment => 1,
    is_numeric        => 1,
  },
  lft => {
    data_type  => 'integer',
    is_numeric => 1,
  },
  rgt => {
    data_type  => 'integer',
    is_numeric => 1,
  },
  level => {
    data_type  => 'integer',
    is_numeric => 1,
  },
  site_id => {
    data_type   => 'integer',
    is_numeric  => 1,
    is_nullable => 0,
  },
  active => {
    data_type   => 'integer',
    size        => 1,
    is_numeric  => 1,
    is_nullable => 0,
  },
  hidden => {
    data_type   => 'integer',
    size        => 1,
    is_numeric  => 1,
    is_nullable => 0,
    default     => 0,
  },
  creator_id => {
    data_type   => 'integer',
    is_numeric  => 1,
    is_nullable => 0,
    default     => 1,
  },
  name => {
    data_type   => 'varchar',
    size        => 150,
    is_nullable => 0,
  },
  url => {
    data_type   => 'varchar',
    size        => 250,
    is_nullable => 0,
  },
  title => {
    data_type   => 'varchar',
    size        => 150,
    is_nullable => 1,
  },
  description => {
    data_type   => 'varchar',
    size        => 500,
    is_nullable => 1,
  },
  keywords => {
    data_type   => 'varchar',
    size        => 500,
    is_nullable => 1,
  },
  type_id => {
    data_type   => 'integer',
    is_nullable => 0,
    is_numeric  => 1,
  },
  c_date => {
    data_type     => 'timestamp',
    is_nullable   => 0,
    default_value => \'CURRENT_TIMESTAMP',
  },
  m_date => {
    data_type     => 'timestamp',
    is_nullable   => 0,
    default_value => \'CURRENT_TIMESTAMP',
  },
  rel_date => {
    data_type     => 'timestamp',
    is_nullable   => 1,
  },
  lock_date => {
    data_type     => 'timestamp',
    is_nullable   => 1,
  },
  content => {
    data_type   => 'text',
    is_nullable => 1,
  },
  data => {
    data_type        => 'jsonb',
    is_nullable      => 1,
    serializer_class => 'JSON',
  },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->tree_columns(
  {
    root_column  => 'site_id',
    left_column  => 'lft',
    right_column => 'rgt',
    level_column => 'level',
  }
);

__PACKAGE__->belongs_to( "site", "Pitahaya::Schema::Result::Site", "site_id" );
__PACKAGE__->belongs_to( "type", "Pitahaya::Schema::Result::MediaType", "type_id" );


1;

__END__

see: http://search.cpan.org/~ribasushi/DBIx-Class-0.082820/lib/DBIx/Class/Manual/Cookbook.pod#Arbitrary_SQL_through_a_custom_ResultSource
select h.id, h.name, conf.value as net_conf from hardware h, jsonb_array_elements(h.data->'hardware'->'network') net, jsonb_array_elements(net.value->'configuration') conf WHERE conf->>'ipaddress' = '192.168.178.4';

