package Pitahaya::Controller::Cmd::Pagetype;
use Mojo::Base 'Mojolicious::Controller';
use IO::All;

sub create {
  my $self = shift;
  my $ref = shift;
  my $params = shift;

  my $site_o = $params->{site};
  my $name = $params->{name};
  
    
  $self->stash("type_name", lc($name));
  
  if(! $params->{base}) {

    my $page_tpl = $self->render_to_string("admin/cmd/page_type/page_template");
    open(my $fh, ">", "templates/skin/" . $site_o->skin . "/" . lc($name) . ".html.ep") or die($!);
    print $fh $page_tpl;
    close($fh);
  
    my $page_type = $self->render_to_string("admin/cmd/page_type/page_type");
    open(my $fht, ">", "vendor/site/" . $site_o->name. "/" . ucfirst(lc($name)) . ".pm") or die($!);
    print $fht $page_type;
    close($fht);
  
  }

  my $new_type = $self->db->resultset("PageType")->create($ref);
  return $new_type;
  
}

1;

