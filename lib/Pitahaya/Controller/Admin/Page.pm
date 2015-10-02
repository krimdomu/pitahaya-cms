package Pitahaya::Controller::Admin::Page;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use IO::All;
use Data::Dumper;

sub view_tree {
  my $self = shift;
  $self->render("admin/page/tree");
}

sub view_desktop {
  my $self = shift;
  my $site_o = $self->stash("site");
  
  my $tpl_base_path = 
    File::Spec->catdir( $FindBin::RealBin, "..", "templates", "admin", "desktop" );
    
  my $tpl_site_path = 
    File::Spec->catdir( "templates", "skin", $site_o->skin, "admin", "desktop" );
  
  my @files_base = grep { m/\.html\.ep$/ } io->dir($tpl_base_path)->all;
  
  if(-d $tpl_site_path) {
    push @files_base, grep { m/\.html\.ep$/ } io->dir($tpl_site_path)->all;
  }
  
  my @desktop_tpls = ();
  
  for my $fb (@files_base) {
    $fb =~ s/.*templates\/(.*?)\.html\.ep$/$1/;
    push @desktop_tpls, $self->render_to_string($fb);
  }
  
  $self->stash("desktop_widgets", \@desktop_tpls);
  
  $self->render("admin/page/desktop");
}

sub move_to_new_parent {
  my $self = shift;

  my $node_id   = $self->param("node");
  my $parent_id = $self->param("parent");
  my $pos_id    = $self->param("pos");

  my $site_o   = $self->stash("site");
  my $page_o   = $site_o->get_page($node_id);
  my $parent_o = $site_o->get_page($parent_id);

  my @children = $parent_o->children;

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
