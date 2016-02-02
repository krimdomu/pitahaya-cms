#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::ContentBase;

use strict;
use warnings;
use Data::Dumper;
use Mojo::Util 'url_escape';
use Encode;
use Moo::Role;

with 'Pitahaya::Schema::Base';

sub secure_add_to_children {
    my ( $self, $ref ) = @_;

    my $new_data = {};

    delete $ref->{id};
#    delete $ref->{site_id};
    delete $ref->{c_date};
    delete $ref->{parent};
    delete $ref->{children};
    
    if($ref->{_id}) {
      $ref->{id} = $ref->{_id};
      delete $ref->{_id};
    }

    my %columns = $self->get_columns;
    
    $ref->{hidden} ||= 0;
    $ref->{navigation} //= 1;
    $ref->{active}     //= 1;
    $ref->{type_id} ||= 2;

    my $is_utf8 = 0;
    if ( $ref->{__utf8_check__}
        && url_escape( $ref->{__utf8_check__} ) eq '%C3%96' )
    {
        $is_utf8 = 1;
    }

    delete $ref->{__utf8_check__};

    # cleanup posted data, so that only valid attributes get stored
    # in the database
    for my $col ( keys %{$ref} ) {

        # test for utf8 and convert it
        if ( exists $columns{$col} ) {

            #if(! ref $data->{$col} && $is_utf8 == 0) {
            #  $data->{$col} = Encode::encode("UTF-8", $data->{$col});
            #}
            $new_data->{$col} = $ref->{$col};
        }
    }

    if ( exists $new_data->{url} && $new_data->{url} eq "new_page" ) {
        $new_data->{url} = $new_data->{name};
    }

    $new_data->{url} =
      $self->_create_url( $is_utf8, ( $new_data->{url} || $new_data->{name} ) );

    my $new_page = $self->add_to_children($new_data);
    return $new_page;
}

sub generate_url {
    my ($self) = @_;

    my @path;
    for my $anc ( $self->ancestors ) {
        push @path, $anc->url;
    }
    pop @path;

    return "/" . join( "/", reverse(@path), $self->url ) . ".html";
}

1;

__END__

see: http://search.cpan.org/~ribasushi/DBIx-Class-0.082820/lib/DBIx/Class/Manual/Cookbook.pod#Arbitrary_SQL_through_a_custom_ResultSource
select h.id, h.name, conf.value as net_conf from hardware h, jsonb_array_elements(h.data->'hardware'->'network') net, jsonb_array_elements(net.value->'configuration') conf WHERE conf->>'ipaddress' = '192.168.178.4';

