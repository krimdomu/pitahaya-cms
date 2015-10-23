package Pitahaya::Controller::Common;
use Mojo::Base 'Mojolicious::Controller';
use FindBin;
use Cwd 'realpath';

use Data::Dumper;

sub prepare {
    my $self = shift;

    my $vhost = $self->req->headers->host;

    $self->app->log->debug("Searching site for virtual host: $vhost");

    my $vhost_o =
      $self->db->resultset("VirtualHost")->search_rs( { name => $vhost } )
      ->next;
    my $site_o;

    if ( !$vhost_o ) {
        $self->app->log->debug("No site found for: $vhost");
        $site_o = $self->db->resultset("Site")->find(1);
    }
    else {
        $site_o = $vhost_o->site;
    }

    $self->stash( site => $site_o );

    my $url = $self->req->url->path;

    $self->app->log->debug( "Complete request: " . $self->req->url );
    $self->app->log->debug( "Request path: " . $self->req->url->path );

    # media link
    if ( $url =~ m/^\/media\// ) {
        my $_url = $url;
        $_url =~ s/^\/media//;

        my $media_o = $site_o->get_media_by_url($_url);
        if ( !$media_o ) {
            $self->app->log->error(
                "Requested media not found: " . $self->req->url->path );
            $self->reply->not_found();
            return 0;
        }
        $self->stash( media => $media_o );
    }
    else {
        my $page_o = $site_o->get_page_by_url( $self->req->url->path );
        if ( !$page_o ) {
            $self->app->log->error(
                "Requested page not found: " . $self->req->url );
            my $site_inc_o = $self->_get_site_inc( $self->stash("site") );
            $site_inc_o->page_not_found();
            return 0;
        }
        $self->stash( page => $page_o );
    }

}

sub media {
    my $self = shift;

    my $media_o = $self->stash("media");
    $self->app->log->debug( "Found media: " . $media_o->name );
    $self->app->log->debug( "Found media path: " . $media_o->content );

    my $path = $media_o->content;
    $path =~ s/^file:\/\///;

    $self->render_file(
        filepath            => $path,
        format              => $media_o->data->{mimetype},
        content_disposition => 'inline',
        filename            => $media_o->name
    );
}

sub page {
    my $self = shift;

    my $skin = $self->stash("site")->skin;

    my $page_o = $self->stash("page");

    #  $page_o->add_to_children({
    #    active => 1,
    #    name => 'bar',
    #    type => 'page',
    #    content => '<h2>hello foo/bar</h2>',
    #    hidden => 0,
    #    navigation => 1,
    #  });

    my $type      = $page_o->type->name;
    my $site_name = $self->stash("site")->name;

    my $site_inc_o = $self->_get_site_inc( $self->stash("site"), $page_o );
    if ($site_inc_o) {
        my $site_meth = $self->req->method;
        $site_inc_o->$site_meth();
    }

    my $inc_path =
      File::Spec->catfile( "vendor", "site", $site_name,
        ucfirst($type) . ".pm" );

    # check if we have a base type
    if ( !-f $inc_path ) {
        $inc_path =
          File::Spec->catfile( $FindBin::RealBin, "..", "vendor", "site",
            "base", ucfirst($type) . ".pm" );
    }

    if ( -f $inc_path ) {
        $self->app->log->debug("Loading pagetype: $type -> $inc_path");
        require $inc_path;
        my $inc_class = ucfirst($type);
        my $inc_o     = $inc_class->new(
            site       => $self->stash("site"),
            page       => $self->stash("page"),
            controller => $self
        );
        my $meth = $self->req->method;
        $inc_o->$meth();
    }

    $self->render("skin/$skin/$type");
}

sub _get_site_inc {
    my ( $self, $site_o, $page_o ) = @_;

    my $site_inc_path =
      File::Spec->catfile( "vendor", "site", $site_o->name, "Site.pm" );

    if ( -f $site_inc_path ) {
        $self->app->log->debug("Loading site: -> $site_inc_path");
        require $site_inc_path;
        my $site_inc_class = "Site";
        my $site_inc_o     = $site_inc_class->new(
            site       => $site_o,
            page       => $page_o,
            controller => $self
        );
        return $site_inc_o;
    }
}

1;
