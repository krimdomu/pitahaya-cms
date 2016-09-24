package Pitahaya::Controller::Admin;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use Data::Dumper;
use File::MimeInfo;
use File::Spec;
use File::Path qw(make_path remove_tree);
use UUID 'uuid';
use Mojo::JSON 'decode_json', 'encode_json';
use FindBin;
use Cwd 'realpath';

sub master {
  my ($self) = @_;

  my $site_o = $self->stash("site");

  my $master = $site_o->master;
  my $master_o;
  if ($master) {
    $master_o = $master->master_site;
  }
  else {
    $master_o = $site_o;
  }

  return $master_o;
}

sub check_login {
  my ($self) = @_;

  if ( $self->is_user_authenticated ) {
    $self->app->log->debug("User is authenticated.");
  }

  $self->stash( is_logged_in => $self->is_user_authenticated );
  $self->redirect_to("/admin/login") and return 0
    unless ( $self->is_user_authenticated );

  return 1;
}

sub login {
  my $self    = shift;
  my $site_rs = $self->db->resultset("Site")->search();
  my @sites;
  while ( my $site_o = $site_rs->next ) {
    push @sites, $site_o;
  }
  $self->stash( sites => \@sites );

  $self->render("admin/login");
}

sub login_POST {
  my $self = shift;
  my $ref  = $self->req->json;
  if ($ref) {
    if ( $self->authenticate( $ref->{username}, $ref->{password} ) ) {
      return $self->render( json => { ok => Mojo::JSON->true } );
    }
    else {
      return $self->render(
        json => {
          ok    => Mojo::JSON->false,
          error => "Wrong username or password."
        },
        status => 401
      );
    }
  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 401 );
}

sub prepare {
  my $self   = shift;
  my $site_o = $self->db->resultset("Site")
    ->search_rs( { name => $self->param("site_name") } )->next;
  $self->stash( "site", $site_o );
}

sub index {
  my $self = shift;
  $self->render("admin/index");
}

################################################################################
# page tree methods
################################################################################

sub page_tree {
  my $self = shift;

  my $wanted_node = $self->param("node");

  my $site_o = $self->stash("site");
  my $page_o;

  my $data;
  if ( $wanted_node eq "root" ) {
    $page_o = $site_o->get_root_page();

    my @pages;
    my $rs = $page_o->children();
    while ( my $child = $rs->next ) {
      push @pages,
        {
        name => $child->name,
        text => $child->name,
        url  => $child->url,
        data => {
          url => $child->url,
        },
        id => $child->id,
        children =>
          ( $child->is_branch ? Mojo::JSON->true : Mojo::JSON->false ),
        parent => $page_o->id,
        icon   => $self->_get_page_tree_icon($child),
        };
    }

    $data = [
      {
        name => $page_o->name,
        text => $page_o->name,
        id   => $page_o->id,
        url  => $page_o->url,
        data => {
          url => $page_o->url,
        },
        is_root  => Mojo::JSON->true,
        icon     => $self->_get_page_tree_icon($page_o),
        children => \@pages,
      }
    ];
  }
  else {
    $page_o = $site_o->get_page($wanted_node);
    $data   = [
      {
        name => $page_o->name,
        text => $page_o->name,
        url  => $page_o->url,
        data => {
          url => $page_o->url,
        },
        id       => $page_o->id,
        is_root  => Mojo::JSON->false,
        icon     => $self->_get_page_tree_icon($page_o),
        children => Mojo::JSON->true
      }
    ];
  }

  $self->render( json => $data );
}

sub page_tree_children {
  my $self = shift;

  my $site_o = $self->stash("site");
  my $page_o = $site_o->get_page( $self->param("node") );

  my @pages;

  my $rs = $page_o->children();
  while ( my $child = $rs->next ) {
    push @pages,
      {
      name => $child->name,
      text => $child->name,
      url  => $child->url,
      data => {
        url => $child->url,
      },
      id       => $child->id,
      icon     => $self->_get_page_tree_icon($child),
      children => ( $child->is_branch ? Mojo::JSON->true : Mojo::JSON->false ),
      parent   => $page_o->id,
      };
  }

  $self->render( json => \@pages );
}

################################################################################
# media tree methods
################################################################################

sub media_tree {
  my $self = shift;

  my $wanted_node = $self->param("node");

  my $site_o = $self->stash("site");
  my $page_o;

  my $data;
  if ( $wanted_node eq "root" ) {
    $page_o = $site_o->get_root_media();

    my @pages;
    my $rs = $page_o->children();
    while ( my $child = $rs->next ) {
      my $child_data = $child->data || {};
      push @pages,
        {
        name => $child->name,
        text => $child->name,
        id   => $child->id,
        data => {
          url => $child->url,
        },
        children =>
          ( $child->is_branch ? Mojo::JSON->true : Mojo::JSON->false ),
        parent => $page_o->id,
        icon   => $self->_get_media_tree_icon(
          $child_data->{mimetype} || $child->type->name
        ),
        };
    }

    my $page_data = $page_o->data || {};
    $data = [
      {
        name => $page_o->name,
        text => $page_o->name,
        id   => $page_o->id,
        data => {
          url => $page_o->url,
        },
        icon => $self->_get_media_tree_icon(
          $page_data->{mimetype} || $page_o->type->name
        ),
        is_root  => Mojo::JSON->true,
        children => \@pages,
      }
    ];
  }
  else {
    $page_o = $site_o->get_media($wanted_node);
    my $page_data = $page_o->data || {};
    $data = [
      {
        name => $page_o->name,
        text => $page_o->name,
        id   => $page_o->id,
        data => {
          url => $page_o->url,
        },
        icon => $self->_get_media_tree_icon(
          $page_data->{mimetype} || $page_o->type->name
        ),
        is_root  => Mojo::JSON->false,
        children => Mojo::JSON->true
      }
    ];
  }

  $self->render( json => $data );
}

sub media_tree_children {
  my $self = shift;

  my $site_o = $self->stash("site");
  my $page_o = $site_o->get_media( $self->param("node") );

  my @pages;

  my $rs = $page_o->children();
  while ( my $child = $rs->next ) {
    my $child_data = $child->data || {};
    push @pages,
      {
      name => $child->name,
      text => $child->name,
      id   => $child->id,
      data => {
        url => $child->url,
      },
      children => ( $child->is_branch ? Mojo::JSON->true : Mojo::JSON->false ),
      parent => $page_o->id,
      icon => $self->_get_media_tree_icon(
        $child_data->{mimetype} || $child->type->name
      ),
      };
  }

  $self->render( json => \@pages );
}

################################################################################
# page methods
################################################################################

sub page_DELETE {
  my $self   = shift;
  my $site_o = $self->stash("site");
  my $page_o = $site_o->get_page( $self->param("page_id") );
  $self->stash( "page", $page_o );

  if ($page_o) {

    my $master_o = $self->master;
    my @sites    = $master_o->get_language_sites;

    if ( $master_o->id != $site_o->id ) {
      push @sites, $master_o;
    }
    else {
      # master is current site
      push @sites, $site_o;
    }

    for my $s (@sites) {
      next if $s->id == $site_o->id;

      my $p = $s->get_page( $page_o->id );

#      if ( ( $p->content ne $page_o->content ) || ( $p->active ) ) {
#        $self->app->log->error(
#          "Can't delete page, because language pages have different content.");
#        return $self->render(
#          json => {
#            ok => Mojo::JSON->false,
#            error =>
#              "Can't delete page, because language pages have different content."
#          },
#          status => 500
#        );
#      }
    }

    if ( $sites[0] ) {
      for my $l (@sites) {
        my $lang_page_o = $l->get_page( $page_o->id );
        $lang_page_o->delete if $lang_page_o;
      }
    }

    $self->_execute_action( "DELETE", "page_DELETE" );

    return $self->render( json => { ok => Mojo::JSON->true } );
  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 404 );
}

sub page_GET {
  my $self = shift;

  my $page_o = $self->stash("site")->get_page( $self->param("page_id") );
  $self->stash( "page", $page_o );

  my $type      = $page_o->type->name;
  my $site_name = $self->stash("site")->name;

  $self->_execute_action( "GET", "page_GET" );

  # check for info.html.ep and tabs.html.ep
  $self->_load_extra_info($page_o);
  $self->_load_extra_tabs($page_o);

  $self->respond_to(
    json => sub        { $self->render( json => $page_o->get_data ) },
    html => { template => "admin/page" }
  );
}

sub page_PUT {
  my $self = shift;

  my $site_o = $self->stash("site");
  $self->app->log->debug( "Updating page: " . $self->param("page_id") );

  my $page_o = $self->stash("site")->get_page( $self->param("page_id") );
  $self->stash( "page", $page_o );

  $self->app->log->debug(
    "Got page: " . $page_o->name . " (" . $page_o->id . ")" );

  my $ref = $self->req->json;
  if ($ref) {
    $self->app->log->debug("Got data to update:");
    $self->app->log->debug(Dumper($ref));
    my $page_type_name = $ref->{type_name};
    delete $ref->{type_name};
    $ref->{type_id} //= $self->_get_page_type_id( $site_o, $page_type_name );

    my ($content_type_name);

    if($ref->{content_type_name}) {
      $content_type_name = $ref->{content_type_name};
      delete $ref->{content_type_name};
      $ref->{content_type_id} =
        $self->_get_content_type_id( $site_o, $content_type_name );
    }

    $page_o->secure_update($ref);

    if (
      $page_o->data && exists $page_o->data->{language_links}
      && ref $page_o->data->{language_links} eq "ARRAY"
      )
    {
      for my $l_id ( @{ $page_o->data->{language_links} } ) {
        my $lang_site = $self->db->resultset("Site")->find($l_id);
        if ($lang_site) {
          $self->app->log->debug( "Updating page lang: $l_id for page: "
              . $page_o->id
              . " and site: "
              . $site_o->id );
          my $lang_page = $lang_site->get_page( $page_o->id );
          $ref->{content_type_id} =
            $self->_get_content_type_id( $lang_site, $content_type_name );
          $ref->{type_id} =
            $self->_get_page_type_id( $lang_site, $page_type_name );
          $lang_page->secure_update($ref);
        }
        else {
          $self->app->log->error( "LangSite id not found: $l_id for page: "
              . $page_o->id
              . " and site: "
              . $site_o->id );
        }
      }
    }

    $self->_execute_action( "PUT", "page_PUT" );

    return $self->render(
      json => {
        name => $page_o->name,
        text => $page_o->name,
        id   => $page_o->id,
        children =>
          ( $page_o->is_branch ? Mojo::JSON->true : Mojo::JSON->false ),
        parent => ( $page_o->level > 0 ? $page_o->parent->id : undef ),
        icon => $self->_get_page_tree_icon($page_o),
      }
    );

  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 500 );
}

sub page_POST {
  my $self = shift;

  $self->app->log->debug("Creating new page (POST)");
  my $site_o = $self->stash("site");
  my $page_o = $site_o->get_page( $self->param("page_id") );
  $self->stash( "page", $page_o );

  $self->app->log->debug("Got site and parent page object.");
  $self->app->log->debug( "parent page: " . $page_o->id );

  my $ref = $self->req->json;

  $self->app->log->debug( Dumper($ref) );

  if ($ref) {
    my $page_type_name = $ref->{type_name};
    delete $ref->{type_name};
    $ref->{type_id} = $self->_get_page_type_id( $site_o, $page_type_name );

    my $content_type_name = $ref->{content_type_name};
    delete $ref->{content_type_name};
    $ref->{content_type_id} =
      $self->_get_content_type_id( $site_o, $content_type_name );

    $ref->{creator_id} = $self->current_user->id;

    $self->app->log->debug("Creating new page now...");

    my $new_page = $page_o->secure_add_to_children($ref);

    my $master_o = $self->master;
    my @langs    = $master_o->get_language_sites;

    if ( $site_o->id != $master_o->id ) {
      push @langs, $master_o;
    }

    if ( $langs[0] ) {
      $ref->{_id} = $new_page->id;

      for my $l (@langs) {
        next if $l->id == $site_o->id;

        my $lang_page_o = $l->get_page( $page_o->id );
        $ref->{content_type_id} =
          $self->_get_content_type_id( $l, $content_type_name );
        $ref->{type_id} = $self->_get_page_type_id( $l, $page_type_name );
        $lang_page_o->secure_add_to_children($ref);
      }
    }

    $self->_execute_action( "POST", "page_POST" );

    $self->res->headers->location( "/page/" . $new_page->id );

    return $self->render(
      json => {
        name => $new_page->name,
        text => $new_page->name,
        id   => $new_page->id,
        icon => $self->_get_page_tree_icon($new_page),
        children =>
          ( $new_page->is_branch ? Mojo::JSON->true : Mojo::JSON->false ),
        parent => $page_o->id,
      }
    );
  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 500 );
}

################################################################################
# media methods
################################################################################

sub media_GET {
  my $self = shift;

  my $page_o = $self->stash("site")->get_media( $self->param("media_id") );

  $self->stash( "page",  $page_o );
  $self->stash( "media", $page_o ); # provide both variables

  my $type      = $page_o->type->name;
  my $site_name = $self->stash("site")->name;

  my $inc_path =
    File::Spec->catfile( "vendor", "site", $site_name, "Admin", "Media",
    ucfirst($type) . ".pm" );

  my %additional_option = ();

  if ( -f $inc_path ) {
    $self->app->log->debug("Loading admin mediatype: $type -> $inc_path");
    require $inc_path;
    my $inc_class = "Admin::Media::" . ucfirst($type);

    my $inc_o = $inc_class->new(
      site       => $self->stash("site"),
      page       => $self->stash("page"),
      controller => $self
    );
    $inc_o->GET();
  }

  $self->respond_to(
    json => sub {
      $self->render( json => { %{ $page_o->get_data }, %additional_option } );
    },
    html => { template => "admin/media" }
  );
}

sub media_PUT {
  my $self = shift;

  my $page_o = $self->stash("site")->get_media( $self->param("media_id") );
  my $ref    = $self->req->json;
  if ($ref) {
    $page_o->secure_update($ref);
  }

  $self->render( json => { ok => Mojo::JSON->true } );
}

sub media_POST {
  my $self = shift;

  my $site_o = $self->stash("site");
  my $page_o = $site_o->get_media( $self->param("media_id") );

  $self->app->log->debug(
    "Got content type: " . $self->req->headers->content_type );

  if ( $self->req->headers->content_type =~ m/json/ ) {
    $self->app->log->debug("Seems to be new content with json");

    my $ref = $self->req->json;

    if ($ref) {

      $ref->{creator_id} = $self->current_user->id;

      if ( exists $ref->{type_name} ) {
        my $type =
          $site_o->media_types->search( { "name" => $ref->{type_name} } )->next;
        if ( !$type ) {
          return $self->render(
            json => {
              ok    => Mojo::JSON->false,
              error => "Unknown media type"
            },
            status => 500
          );
        }
        $ref->{type_id} = $type->id;
        delete $ref->{type_name};
      }

      my $new_page = $page_o->secure_add_to_children($ref);

      $self->res->headers->location( "/media/" . $new_page->id );

      my $child_data = $new_page->data;

      return $self->render(
        json => {
          name => $new_page->name,
          text => $new_page->name,
          id   => $new_page->id,
          icon => $self->_get_media_tree_icon(
            $child_data->{mimetype} || $new_page->type->name
          ),
          children => (
            $new_page->is_branch
            ? Mojo::JSON->true
            : Mojo::JSON->false
          ),
          parent => $page_o->id,
        }
      );
    }

    $self->render( json => { ok => Mojo::JSON->false }, status => 500 );
  }

  if ( $self->req->headers->content_type =~ m/multipart\/form\-data/ ) {

    # seems to be an upload
    $self->app->log->debug("Seems to be file upload");

    my $upload = $self->req->every_upload("uploadedfiles[]")->[0];

    my @ret;

    #for my $upload ( @{$uploads} ) {
    $self->app->log->debug( "Got upload: " . $upload->filename );
    my $uuid     = uuid();
    my $data_dir = File::Spec->catdir(
      $self->config->{data_dir}, $site_o->name,
      substr( $uuid, 0, 2 ), substr( $uuid, 2, 2 )
    );
    my $data_file = File::Spec->catdir( $data_dir, $uuid );
    make_path($data_dir);
    $upload->move_to($data_file);

    my $mimetype = qx{file -bi $data_file};
    chomp $mimetype;

    my $media_type_id = 2;
    my $media_type_search = ( $mimetype =~ m/^image/ ? "image" : "object" );
    my $type =
      $site_o->media_types->search( { "name" => $media_type_search } )->next;
    if ( !$type ) {
      return $self->render(
        json   => { ok => Mojo::JSON->false, error => "Unknown media type" },
        status => 500
      );
    }
    $media_type_id = $type->id;

    my $new_page = $page_o->secure_add_to_children(
      {
        name       => $upload->filename,
        data       => { size => $upload->size, mimetype => $mimetype },
        content    => "file://" . $data_file,
        type_id    => $media_type_id,
        creator_id => $self->current_user->id,
      }
    );

    my $child_data = $new_page->data;

    push @ret,
      {
      name => $new_page->name,
      text => $new_page->name,
      id   => $new_page->id,
      children =>
        ( $new_page->is_branch ? Mojo::JSON->true : Mojo::JSON->false ),
      parent => $page_o->id,
      icon   => $self->_get_media_tree_icon(
        $child_data->{mimetype} || $new_page->type->name
      ),
      file => $data_file,
      };

    #}

    return $self->render( json => \@ret );
  }

  $self->render(
    json   => { ok => Mojo::JSON->false, error => "Unknown content type" },
    status => 500
  );
}

sub media_DELETE {
  my $self   = shift;
  my $page_o = $self->stash("site")->get_media( $self->param("media_id") );

  if ($page_o) {
    my $path = $page_o->content;
    if ( $path =~ m/^file:\/\// ) {
      my $local_path = substr( $path, 7 );
      unlink $local_path;
    }
    $page_o->delete;
    return $self->render( json => { ok => Mojo::JSON->true } );
  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 404 );
}

################################################################################
# editor functions
################################################################################

sub editor_snippets_GET {
  my ($self) = @_;

  my $site_o    = $self->stash("site");
  my $site_name = $site_o->name;

  my $snippets_dir =
    File::Spec->catdir( "vendor", "site", $site_name, "snippets" );
  my @snippets = ();

  if ( -d $snippets_dir ) {
    opendir( my $dh, $snippets_dir );
    while ( my $entry = readdir($dh) ) {
      if ( $entry =~ m/\.json$/ ) {
        my $content = eval {
          local ( @ARGV, $/ ) =
            ( File::Spec->catfile( $snippets_dir, $entry ) );
          <>;
        };
        eval {
          my $ref = decode_json($content);
          my $id  = $entry;
          $id =~ s/\.json$//;
          $ref->{id} = $id;
          push @snippets, $ref;
        };
      }
    }
    closedir($dh);
  }

  $self->stash( snippets => \@snippets );

  $self->render("admin/editor/snippets");
}

sub editor_snippet_GET {
  my ($self)    = @_;
  my $site_name = $self->stash("site")->name;
  my $snippet   = $self->render_to_string(
    "skin/$site_name/admin/snippets/" . $self->param("snippet_id") );
  $snippet =
      "<span class=\"admin_snippet\" data-pitahaya-block=\"block_id:"
    . $self->param("snippet_id")
    . "\">$snippet</span>";
  $self->render( text => $snippet );
}

################################################################################
# private functions
################################################################################

sub _get_media_tree_icon {
  my ( $self, $mt ) = @_;

  if ( $mt =~ m/^image/ ) {
    return "/images/pitahaya/icons/picture.png";
  }
  elsif ( $mt =~ m/^application\/pdf/ ) {
    return "/images/pitahaya/icons/page_white_acrobat.png";
  }
  elsif ( $mt eq "folder" ) {
    return "/images/pitahaya/icons/folder.png";
  }
  elsif ( $mt eq "index" ) {
    return "/images/pitahaya/icons/drive.png";
  }
  else {
    return "/images/pitahaya/icons/page_white.png";
  }
}

sub _get_page_tree_icon {
  my ( $self, $page ) = @_;

  if ( $page->active ) {
    return "/images/pitahaya/icons/page.png";
  }
  else {
    return "/images/pitahaya/icons/page_red.png";
  }
}

sub _load_extra_info {
  my ( $self, $page_o ) = @_;

  my $info_html = File::Spec->catfile( "skin", $self->stash("site")->skin,
    "admin", lc( $page_o->type->name ), "info" );
  $self->app->log->debug("Looking for info extension: $info_html.html.ep");
  if ( -f File::Spec->catfile( "templates", "$info_html.html.ep" ) ) {
    $self->stash( "info_page", $self->render_to_string($info_html) );
  }
  else {
    my $base_info_html =
      File::Spec->catfile( "skin", "base", "admin", lc( $page_o->type->name ),
      "info" );
    $self->app->log->debug(
      "Looking for info extension in base: $base_info_html.html.ep");
    if (
      -f File::Spec->catfile(
        $FindBin::RealBin, "..", "templates", "$base_info_html.html.ep"
      )
      )
    {
      $self->stash( "info_page", $self->render_to_string($base_info_html) );
    }
  }
}

sub _load_extra_tabs {
  my ( $self, $page_o ) = @_;

  my $tabs_html = File::Spec->catfile( "skin", $self->stash("site")->skin,
    "admin", lc( $page_o->type->name ), "tabs" );
  $self->app->log->debug("Looking for tabs extension: $tabs_html.html.ep");
  if ( -f File::Spec->catfile( "templates", "$tabs_html.html.ep" ) ) {
    $self->stash( "custom_tabs", $self->render_to_string($tabs_html) );
  }
  else {
    my $base_tabs_html =
      File::Spec->catfile( "skin", "base", "admin", lc( $page_o->type->name ),
      "tabs" );
    $self->app->log->debug(
      "Looking for tabs extension in base: $base_tabs_html.html.ep");
    if (
      -f File::Spec->catfile(
        $FindBin::RealBin, "..", "templates", "$base_tabs_html.html.ep"
      )
      )
    {
      $self->stash( "custom_tabs", $self->render_to_string($base_tabs_html) );
    }
  }
}

sub _execute_action {
  my ( $self, $action, $admin_action ) = @_;

  my $page_o = $self->stash("page");
  my $site_o = $self->stash("site");

  $self->app->log->debug(
    "_execute_action: " . $page_o->name . "(id: " . $page_o->id . ")" );

  my $type = $page_o->type->name;

  my $inc_path =
    File::Spec->catfile( "vendor", "site", $site_o->name, "Admin",
    ucfirst($type) . ".pm" );

  # check if we have a base type to load
  if ( !-f $inc_path ) {
    $inc_path =
      File::Spec->catfile( $FindBin::RealBin, "..", "vendor", "site",
      "base", "Admin", ucfirst($type) . ".pm" );
  }

  if ( -f $inc_path ) {
    $self->app->log->debug("Loading admin pagetype: $type -> $inc_path");
    require $inc_path;
    my $inc_class = "Admin::" . ucfirst($type);

    my $inc_o = $inc_class->new(
      site       => $self->stash("site"),
      page       => $self->stash("page"),
      controller => $self
    );
    if ( $inc_o->can($action) ) {
      $inc_o->$action();
    }
  }

  my $site_inc_o = $self->_get_site_admin_inc( $self->stash("site"), $page_o );
  if ( $site_inc_o && $site_inc_o->can($admin_action) ) {
    $site_inc_o->$admin_action();
  }

}

sub _get_site_admin_inc {
  my ( $self, $site_o, $page_o ) = @_;

  my $site_inc_path =
    File::Spec->catfile( "vendor", "site", $site_o->name, "Admin.pm" );

  if ( -f $site_inc_path ) {
    $self->app->log->debug("Loading site: -> $site_inc_path");
    require $site_inc_path;
    my $site_inc_class = "Admin";
    my $site_inc_o     = $site_inc_class->new(
      site       => $site_o,
      page       => $page_o,
      controller => $self
    );
    return $site_inc_o;
  }
}

sub _get_page_type_id {
  my ( $self, $site_o, $type_name ) = @_;

  return $site_o->get_default_page_type unless $type_name;

  my $page_type = $site_o->page_types->search( { "name" => $type_name } )->next;
  if ( !$page_type ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Unknown page type" },
      status => 500
    );
  }
  return $page_type->id;
}

sub _get_content_type_id {
  my ( $self, $site_o, $content_type_name ) = @_;

  return $site_o->get_default_content_type unless $content_type_name;

  my $content_type =
    $site_o->content_types->search( { "name" => $content_type_name } )->next;
  if ( !$content_type ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Unknown content type" },
      status => 500
    );
  }
  return $content_type->id;
}

1;
