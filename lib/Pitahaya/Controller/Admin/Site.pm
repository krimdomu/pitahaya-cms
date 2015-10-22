package Pitahaya::Controller::Admin::Site;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use Data::Dumper;

sub site_GET {
    my $self = shift;

    my $site_id = $self->param("site_id");

    my $site_o;
    if ( $site_id =~ m/^\d+$/ ) {
        $site_o = $self->db->resultset("Site")->find($site_id);
    }
    else {
        $site_o =
          $self->db->resultset("Site")->search_rs( { name => $site_id } )->next;
    }

    if ( !$site_o ) {
        return $self->render(
            json   => { ok => Mojo::JSON->false, error => "Site not found." },
            status => 404
        );
    }

    $self->render( json => $site_o->get_data );
}

1;
