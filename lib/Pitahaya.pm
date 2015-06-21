package Pitahaya;
use Mojo::Base 'Mojolicious';

use Data::Dumper;
use Pitahaya::Schema;
use Cwd 'getcwd';

has schema => sub {
  my ($self) = @_;

  my $dsn =
      "dbi:Pg:"
    . "database="
    . $self->config->{database}->{schema} . ";" . "host="
    . $self->config->{database}->{host};

  return Pitahaya::Schema->connect(
    $dsn,
    $self->config->{database}->{username},
    $self->config->{database}->{password},
  );
};

# This method will run once at server start
sub startup {
  my $self = shift;

  #######################################################################
  # Define some custom helpers
  #######################################################################
  $self->helper( db => sub { $self->app->schema } );

  #######################################################################
  # Load configuration
  #######################################################################
  my @cfg =
    ( getcwd()."/pitahaya.conf", "/etc/pitahaya.conf", "/usr/local/etc/pitahaya.conf", );
  my $cfg;
  for my $file (@cfg) {
    if ( -f $file ) {
      $cfg = $file;
      last;
    }
  }

  #######################################################################
  # Load plugins
  #######################################################################
  if( $cfg ) {
    $self->plugin( "Config", file => $cfg );
    $self->plugin("RenderFile");
    $self->plugin("User");
    $self->plugin(
      "database",
      {
        dsn    => "DBI:mysql:database=cms;host=172.17.42.1;port=9306",
        helper => "sphinx",
      }
    );
    $self->plugin(
      "Authentication" => {
        autoload_user => 1,
        session_key   => $self->config->{session}->{key},
        load_user     => sub {
          my ( $app, $uid ) = @_;
          my $user_o = $app->get_user($uid);
          return $user_o;    # user objekt
        },
        validate_user => sub {
          my ( $app, $username, $password ) = @_;
          return $app->check_password( $username, $password );
        },
      }
    );

    # Router
    my $r = $self->routes;
    $r->get('/admin/login')->to('admin#login');
    $r->post('/admin/login')->to('admin#login_POST');

    my $r_auth = $r->under('/admin')->to("admin#check_login");

    $r_auth->get('/site/#site_id')->to('admin-site#site_GET');

    my $admin_r = $r_auth->under('/#site_name')->to('admin#prepare');

    $admin_r->get('/')->to('admin#index');

    $admin_r->get('/export')->to('admin-export#export');
    $admin_r->post('/import')->to('admin-import#import_into_site');

    $admin_r->get('/dialog/select_page_or_media')->to('admin-dialog#select_page_or_media');

    $admin_r->get('/page/tree/')->to( 'admin#page_tree', node => 'root' );
    $admin_r->get('/page/tree/:node')->to('admin#page_tree');
    $admin_r->get('/page/tree/children/:node')->to('admin#page_tree_children');
    $admin_r->put('/page/tree/:node/move/:parent/:pos')
      ->to('admin-page#move_to_new_parent');

    $admin_r->get('/editor/snippets')->to('admin#editor_snippets_GET');
    $admin_r->get('/editor/snippet/:snippet_id')->to('admin#editor_snippet_GET');

    $admin_r->get('/media/tree/')->to( 'admin#media_tree', node => 'root' );
    $admin_r->get('/media/tree/:node')->to('admin#media_tree');
    $admin_r->get('/media/tree/children/:node')->to('admin#media_tree_children');
    $admin_r->put('/media/tree/:node/move/:parent/:pos')
      ->to('admin-media#move_to_new_parent');

    $admin_r->get('/page/:page_id')->to('admin#page_GET');
    $admin_r->put('/page/:page_id')->to('admin#page_PUT');
    $admin_r->post('/page/:page_id')->to('admin#page_POST');
    $admin_r->delete('/page/:page_id')->to('admin#page_DELETE');

    $admin_r->get('/media/:media_id')->to('admin#media_GET');
    $admin_r->put('/media/:media_id')->to('admin#media_PUT');
    $admin_r->post('/media/:media_id')->to('admin#media_POST');
    $admin_r->delete('/media/:media_id')->to('admin#media_DELETE');

    $admin_r->get('/page/view/tree')->to('admin-page#view_tree');
    $admin_r->get('/page/view/desktop')->to('admin-page#view_desktop');

    $admin_r->get('/user/view/tree')->to('admin-user#view_tree');
    $admin_r->get('/user/view/desktop')->to('admin-user#view_desktop');

    $admin_r->get('/user/tree/')->to( 'admin-user#tree', node => 'root' );
    $admin_r->get('/user/tree/children/:node')->to('admin-user#tree_children');

    $admin_r->get('/user/:user_id')->to('admin-user#user_GET');
    $admin_r->put('/user/:user_id')->to('admin-user#user_PUT');
    $admin_r->post('/user')->to('admin-user#user_POST');
    $admin_r->delete('/user/:user_id')->to('admin-user#user_DELETE');

    # Normal route to controller
    my $cms_r = $r->under('/')->to('common#prepare');

    $cms_r->any('/')->to('common#page');
    $cms_r->any('/media/*req_url')->to('common#media');
    $cms_r->any('/*req_url')->to('common#page');

    push @{ $self->static->paths }, getcwd() . "/public";
    push @{ $self->renderer->paths }, getcwd() . "/templates";
  }

}

1;
