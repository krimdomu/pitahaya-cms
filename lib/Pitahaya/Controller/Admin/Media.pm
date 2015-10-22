package Pitahaya::Controller::Admin::Media;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use Data::Dumper;

sub move_to_new_parent {
    my $self = shift;

    my $node_id   = $self->param("node");
    my $parent_id = $self->param("parent");
    my $pos_id    = $self->param("pos");

    my $site_o   = $self->stash("site");
    my $page_o   = $site_o->get_media($node_id);
    my $parent_o = $site_o->get_media($parent_id);

    my @children = $parent_o->children();

    # no children, so this is the first child
    if ( scalar @children == 0 ) {
        $parent_o->attach_leftmost_child($page_o);
        return $self->render( json => { ok => Mojo::JSON->true } );
    }
    else {
        my $nei_o = $children[$pos_id];
        if ( $pos_id == $#children && $pos_id != 0 ) {
            $nei_o->attach_right_sibling($page_o);
        }
        else {
            $nei_o->attach_left_sibling($page_o);
        }
        return $self->render( json => { ok => Mojo::JSON->true } );
    }
}

1;
