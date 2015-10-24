#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::Result::Site;

use strict;
use warnings;

use Data::Dumper;
use Mojo::Util 'url_unescape', 'url_escape';
use Moo;

extends 'DBIx::Class::Core';
with 'Pitahaya::Schema::Base';

__PACKAGE__->load_components( 'InflateColumn::Serializer',
    'InflateColumn::DateTime', 'Core' );

__PACKAGE__->table("site");
__PACKAGE__->add_columns(
    id => {
        data_type         => 'serial',
        is_auto_increment => 1,
        is_numeric        => 1,
    },
    name => {
        data_type   => 'varchar',
        size        => 150,
        is_nullable => 0,
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
    skin => {
        data_type   => 'varchar',
        size        => 150,
        is_nullable => 0,
    },
    data => {
        data_type        => 'jsonb',
        is_nullable      => 1,
        serializer_class => 'JSON',
    },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many( "page_types", "Pitahaya::Schema::Result::PageType",
    "site_id" );
__PACKAGE__->has_many( "media_types", "Pitahaya::Schema::Result::MediaType",
    "site_id" );
__PACKAGE__->has_many( "pages",  "Pitahaya::Schema::Result::Page",  "site_id" );
__PACKAGE__->has_many( "medias", "Pitahaya::Schema::Result::Media", "site_id" );
__PACKAGE__->has_many( "virtual_hosts",
    "Pitahaya::Schema::Result::VirtualHost", "site_id" );
__PACKAGE__->has_one( "master", "Pitahaya::Schema::Result::Language",
    "lang_site_id" );
__PACKAGE__->has_many( "languages", "Pitahaya::Schema::Result::Language",
    "master_site_id" );

################################################################################
# page methods
################################################################################

sub get_page_by_url {
    my ( $self, $url ) = @_;
    my @url_parts = split( /\//, $url );

    if ( scalar @url_parts == 0 ) {
        return $self->get_root_page();
    }

    my $lookup_for = $url_parts[-1];
    $lookup_for =~ s/\.(html|htm|xml)$//igms;

    shift @url_parts;

    my $current_parent = $self->get_root_page();
    my $url_part_1     = $url_parts[0];
    $url_part_1 =~ s/\.(html|htm|xml)$//igms;
    if ( scalar @url_parts == 1 && $current_parent->url eq $url_part_1 ) {
        return $current_parent;
    }

    for my $url_part (@url_parts) {
        $url_part =~ s/\.(html|htm|xml)$//igms;
        $current_parent =
          $current_parent->children( { 'me.url' => $url_part } )->next;
        if ( !$current_parent ) {

            # page not found
            return;
        }

        if ( $current_parent->url eq $lookup_for ) {
            return $current_parent;
        }
    }

    # nothing found
    return;
}

sub get_root_page {
    my ($self) = @_;
    return $self->pages->search_rs( { lft => 1 } )->next;
}

sub get_page {
    my ( $self, $id ) = @_;
    return $self->pages->find( { id => $id, site_id => $self->id } );
}

sub get_page_types {
    my ($self) = @_;
    return $self->page_types;
}

################################################################################
# media methods
################################################################################

sub get_media_by_url {
    my ( $self, $url ) = @_;
    my @url_parts = split( /\//, $url );

    if ( scalar @url_parts == 0 ) {
        return $self->get_root_media();
    }

    my $lookup_for = $url_parts[-1];

    #$lookup_for =~ s/\.([a-zA-Z0-9]+)$//igms;

    shift @url_parts;

    my $current_parent = $self->get_root_media();
    my $url_part_1     = $url_parts[0];

    #$url_part_1 =~ s/\.([a-zA-Z0-9]+)$//igms;
    if ( scalar @url_parts == 1 && $current_parent->url eq $url_part_1 ) {
        return $current_parent;
    }

    for my $url_part (@url_parts) {

        #$url_part =~ s/\.([a-zA-Z0-9]+)$//igms;
        $current_parent =
          $current_parent->children( { 'me.url' => $url_part } )->next;
        if ( !$current_parent ) {

            # media not found
            return;
        }

        if ( $current_parent->url eq $lookup_for ) {
            return $current_parent;
        }
    }

    # nothing found
    return;
}

sub get_root_media {
    my ($self) = @_;
    return $self->medias->search_rs( { lft => 1 } )->next;
}

sub get_media {
    my ( $self, $id ) = @_;
    return $self->medias->find( { id => $id, site_id => $self->id } );
}

sub get_media_types {
    my ($self) = @_;
    return $self->media_types;
}

1;

__END__

see: http://search.cpan.org/~ribasushi/DBIx-Class-0.082820/lib/DBIx/Class/Manual/Cookbook.pod#Arbitrary_SQL_through_a_custom_ResultSource
select h.id, h.name, conf.value as net_conf from hardware h, jsonb_array_elements(h.data->'hardware'->'network') net, jsonb_array_elements(net.value->'configuration') conf WHERE conf->>'ipaddress' = '192.168.178.4';

