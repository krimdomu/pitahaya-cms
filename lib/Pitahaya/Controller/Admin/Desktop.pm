package Pitahaya::Controller::Admin::Desktop;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use IO::All;
use Data::Dumper;

sub action_GET {
  my $self = shift;
  
  my $page_o = $self->stash("page");
  my $site_o = $self->stash("site");
  
  my $da = $self->param("desktop_action");

  my $inc_path =
    File::Spec->catfile( $FindBin::RealBin, "..", "vendor", "site", "base",
    "Admin", "Desktop.pm" );
    
  if(-f $inc_path) {
    $self->app->log->debug("Loading admin desktop -> $inc_path");
    require $inc_path;
    my $desktop_o = Admin::Desktop->new(
      site       => $self->stash("site"),
      page       => undef,
      controller => $self
    );
    
    if($desktop_o->can($da)) {
      $desktop_o->$da();
    }
    else {
      $self->app->log->error("Can't find desktop action: $da in $inc_path.");
    }
  }

  $inc_path =
    File::Spec->catfile( "vendor", "site", $site_o->name, "Admin",
      "Desktop.pm" );
      
  if(-f $inc_path) {
    $self->app->log->debug("Loading admin desktop -> $inc_path");
    require $inc_path;
    my $desktop_o = Admin::Desktop->new(
      site       => $self->stash("site"),
      page       => undef,
      controller => $self
    );
    
    if($desktop_o->can($da)) {
      $desktop_o->$da();
    }
    else {
      $self->app->log->error("Can't find desktop action: $da in $inc_path.");
    }
  }
}


1;
