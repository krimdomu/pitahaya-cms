#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::Schema::Base;

use strict;
use warnings;
use Data::Dumper;
use Mojo::Util 'url_escape';
use Encode;
use Moo::Role;

sub get_data {
    my ($self) = @_;

    my $ret = {};

    my %columns = $self->get_columns;
    for my $col ( keys %columns ) {
        $ret->{$col} = $self->$col();
    }

    return $ret;
}

sub secure_update {
    my ( $self, $data ) = @_;
    my $new_data = {};

    my %columns = $self->get_columns;

    # remove some attributes that can't be modified
    # from external things
    delete $data->{id};
    delete $data->{site_id};
    delete $data->{c_date};
    delete $data->{parent};
    delete $data->{children};

    my $is_utf8 = 0;
    if ( $data->{__utf8_check__} && url_escape( $data->{__utf8_check__} ) eq '%C3%96' ) {
        $is_utf8 = 1;
    }

    delete $data->{__utf8_check__};

    if ( exists $columns{url} ) {

        if ( $data->{url} eq "new_page" ) {
            $data->{url} = $data->{name};
        }

        $data->{url} =
          $self->_create_url( $is_utf8, ( $data->{url} || $data->{name} ) );
    }

    # cleanup posted data, so that only valid attributes get stored
    # in the database
    for my $col ( keys %{$data} ) {

        # test for utf8 and convert it
        if ( exists $columns{$col} ) {

            #if(! ref $data->{$col} && $is_utf8 == 0) {
            #  $data->{$col} = Encode::encode("UTF-8", $data->{$col});
            #}
            $new_data->{$col} = $data->{$col};
        }
    }

    $self->update($new_data);
}

sub _create_url {
    my ( $self, $is_utf8, $name ) = @_;
print STDERR "(1) _create_url\n";

    # normalize url, so there is no strange symbols in it
    $name =~ s/[^A-Za-z0-9\-_\.]/_/gms;
    $name = lc($name);
print STDERR "(2) _create_url\n";

    if ( !$is_utf8 ) {
print STDERR "(3) _create_url\n";
        return url_escape( Encode::encode( "UTF-8", $name ) );
    }
print STDERR "(4) _create_url\n";

    return url_escape($name);
}

1;
