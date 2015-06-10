package Pitahaya::Controller::Admin::User;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use Data::Dumper;

sub view_tree {
  my $self = shift;
  $self->render("admin/user/tree");
}

sub view_desktop {
  my $self = shift;
  $self->render("admin/user/desktop");
}

sub tree {
  my $self = shift;

  $self->render(
    json => [
      {
        name     => "Users",
        text     => "Users",
        id       => "root",
        is_root  => Mojo::JSON->true,
        icon     => "/images/pitahaya/icons/user.png",
        children => Mojo::JSON->true,
      }
    ]
  );
}

sub tree_children {
  my $self = shift;

  my $user_rs = $self->db->resultset("User")->search;
  my @users;

  while ( my $user_o = $user_rs->next ) {
    push @users,
      {
      id       => $user_o->id,
      name     => $user_o->username,
      text     => $user_o->username,
      children => Mojo::JSON->false,
      icon     => "/images/pitahaya/icons/user.png",
      };
  }

  $self->render( json => \@users );
}

sub user_GET {
  my $self = shift;

  my $user_o = $self->db->resultset("User")->find( $self->param("user_id") );
  $self->stash( user => $user_o );

  if ($user_o) {
    my $data = $user_o->get_data;
    delete $data->{password};

    return $self->respond_to(
      json => sub        { $self->render( json => $data ) },
      html => { template => "admin/user/edit" }
    );
  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 404 );
}

sub user_DELETE {
  my $self = shift;

  my $user_o = $self->db->resultset("User")->find( $self->param("user_id") );
  if ($user_o) {
    $user_o->delete;
    return $self->render( json => { ok => Mojo::JSON->true } );
  }

  $self->render( json => { ok => Mojo::JSON->false }, status => 404 );
}

sub user_POST {
  my $self = shift;

  my $ref = $self->req->json;

  if ($ref) {
    delete $ref->{__utf8_check__};
    my $user_o = $self->db->resultset("User")->create($ref);
    $self->res->headers->location( "/user/" . $user_o->id );
    return $self->render(
      json => {
        name     => $user_o->username,
        text     => $user_o->username,
        id       => $user_o->id,
        children => Mojo::JSON->false,
        icon     => "/images/pitahaya/icons/user.png",
      }
    );
  }

  $self->render(
    json   => { ok => Mojo::JSON->false, error => "Error creating user." },
    status => 500
  );
}

sub user_PUT {
  my $self = shift;

  my $ref = $self->req->json;

  if ($ref) {
    my $user_o = $self->db->resultset("User")->find( $self->param("user_id") );
    $user_o->secure_update($ref);
    return $self->render( json => { ok => Mojo::JSON->true } );
  }

  $self->render(
    json   => { ok => Mojo::JSON->false, error => "Error updating user." },
    status => 500
  );
}

1;
