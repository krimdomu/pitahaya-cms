package Pitahaya::Controller::Admin::Export;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use File::Path qw(make_path remove_tree);
use File::Spec;
use File::Copy::Recursive qw(dircopy);

use Mojo::JSON qw(decode_json encode_json);
use File::chdir;

use Data::Dumper;

sub export {
  my ($self) = @_;
  my $site_o = $self->stash("site");

  my $time = time();
  my $export_to = File::Spec->catdir($self->config->{export}->{dir}, $site_o->name, $time);  

  make_path($export_to);

  {
    open(my $fh, ">", File::Spec->catfile($export_to, "site.json"));
    print $fh encode_json($site_o->get_data);
    print $fh "\n";
    close($fh);
  }

  {
    my @pages = $self->db->resultset("Page")->search({site_id => $site_o->id});
    open(my $fh, ">", File::Spec->catfile($export_to, "pages.json"));
    for my $page (@pages) {
      print $fh encode_json($page->get_data);
      print $fh "\n";
    }
    close($fh);
  }

  {
    my @medias = $self->db->resultset("Media")->search({site_id => $site_o->id});
    open(my $fh, ">", File::Spec->catfile($export_to, "media.json"));
    for my $media (@medias) {
      my $data = $media->get_data;

      if($data->{content} && $data->{content} =~ m/^file:\/\//) {
        my $data_dir = File::Spec->catdir($self->config->{data_dir}, $site_o->name);
        $data->{content} =~ s/^file:\/\/\Q$data_dir\E//;
      }

      print $fh encode_json($data);
      print $fh "\n";
    }
    close($fh);
  }

  {
    my @page_types = $self->db->resultset("PageType")->search({site_id => $site_o->id});
    open(my $fh, ">", File::Spec->catfile($export_to, "page_types.json"));
    for my $page_type (@page_types) {
      print $fh encode_json($page_type->get_data);
      print $fh "\n";
    }
    close($fh);
  }

  {
    my @media_types = $self->db->resultset("MediaType")->search({site_id => $site_o->id});
    open(my $fh, ">", File::Spec->catfile($export_to, "media_types.json"));
    for my $media_type (@media_types) {
      print $fh encode_json($media_type->get_data);
      print $fh "\n";
    }
    close($fh);
  }

  {
    my $media_dir = File::Spec->catdir($self->config->{data_dir}, $site_o->name );
    my $media_export_dir = File::Spec->catdir($export_to, "media");
    make_path($media_export_dir);
    dircopy($media_dir, $media_export_dir);
  }

  {
    my $skin_dir = File::Spec->catdir("templates", "skin", $site_o->skin );
    my $skin_export_dir = File::Spec->catdir($export_to, "templates", "skin", $site_o->skin);

    my $layout_dir = File::Spec->catdir("templates", "layouts", $site_o->skin );
    my $layout_export_dir = File::Spec->catdir($export_to, "templates", "skin", $site_o->skin);

    make_path($skin_export_dir);
    make_path($layout_export_dir);

    dircopy($skin_dir, $skin_export_dir);
    dircopy($layout_dir, $layout_export_dir);
  }

  {
    my $site_dir = File::Spec->catdir("vendor", "site", $site_o->name );
    my $site_export_dir = File::Spec->catdir($export_to, "vendor", "site", $site_o->name);

    make_path($site_export_dir);

    dircopy($site_dir, $site_export_dir);
  }

  {
    local $CWD = $export_to;
    system "tar czf ../$time.tar.gz *";
  }

  remove_tree($export_to);

  $self->render(json => {ok => Mojo::JSON->true});
}

1;
