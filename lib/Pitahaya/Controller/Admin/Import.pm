package Pitahaya::Controller::Admin::Import;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use File::Path qw(make_path remove_tree);
use File::Spec;
use File::Copy::Recursive qw(dircopy);

use Mojo::JSON qw(decode_json encode_json);
use File::chdir;
use Archive::Tar;

use Data::Dumper;

sub import_into_site {
  my ($self) = @_;
  my $site_o = $self->stash("site");

  my $ref = $self->req->json;

  my $media_file = $ref->{file};
  $media_file =~ s/^\/media//;

  $self->app->log->debug("Importing (from media): " . $media_file);

  my $file_o = $site_o->get_media_by_url($media_file);

  my $tar = Archive::Tar->new;
  $self->app->log->debug("Importing: " . $file_o->content);

  my $tar_file = $file_o->content;
  $tar_file =~ s/^file:\/\///;

  $tar->read($tar_file);

  my $page_rs = $self->db->resultset("Page")->search({ id => { '>' => 0 }});
  $page_rs->delete;

  my $page_type_rs = $self->db->resultset("PageType")->search({ id => { '>' => 0 }});
  $page_type_rs->delete;


  my $media_rs = $self->db->resultset("Media")->search({ id => { '>' => 0 }});
  $media_rs->delete;

  my $media_type_rs = $self->db->resultset("MediaType")->search({ id => { '>' => 0 }});
  $media_type_rs->delete;

  my $media_dir = File::Spec->catdir($self->config->{data_dir}, $site_o->name);

  {
    my @content = split(/\n/, $tar->get_content("page_types.json"));
    for my $page_type_line (@content) {
      my $ref = decode_json($page_type_line);
      $self->app->log->debug("Importing page_type: " . $ref->{name});
      $self->db->resultset("PageType")->create($ref);
    }
  }

  {
    my @content = split(/\n/, $tar->get_content("pages.json"));
    for my $page_line (@content) {
      my $ref = decode_json($page_line);
      $self->app->log->debug("Importing page: " . $ref->{name});
      $self->db->resultset("Page")->create($ref);
    }
  }


  {
    my @content = split(/\n/, $tar->get_content("media_types.json"));
    for my $media_type_line (@content) {
      my $ref = decode_json($media_type_line);
      $self->app->log->debug("Importing media_type: " . $ref->{name});
      $self->db->resultset("MediaType")->create($ref);
    }
  }

  {
    my @content = split(/\n/, $tar->get_content("media.json"));
    for my $media_line (@content) {
      my $ref = decode_json($media_line);
      $self->app->log->debug("Importing media: " . $ref->{name});
      my $e_file = $ref->{content};
      $e_file =~ s/^\///;

      $ref->{content} = "file://" . File::Spec->catfile($self->config->{data_dir}, $site_o->name, $e_file);
      $self->db->resultset("Media")->create($ref);
    }

    $self->app->log->debug("Recreating media dir: $media_dir");

    make_path($media_dir . ".tmp");

    my @media_files = grep { m/^media\// } $tar->list_files;
    for my $media_file (@media_files) {
      my $to = $media_file;
      $to =~ s/^media\///;
      $self->app->log->debug("Extracting: $media_file -> $to");
      $tar->extract_file($media_file, "$media_dir.tmp/$to");
    }

  }

  {
    remove_tree(File::Spec->catfile("vendor", "site", $site_o->name));

    my @vendor_files = grep { m/^vendor\// } $tar->list_files;
    for my $vendor_file (@vendor_files) {
      my $to = $vendor_file;
      $self->app->log->debug("Extracting: $vendor_file -> $to");
      $tar->extract_file($vendor_file, $to);
    }
  }

  {
    remove_tree(File::Spec->catfile("templates", "skin", $site_o->skin));
    remove_tree(File::Spec->catfile("templates", "layouts", "skin", $site_o->skin));

    my @templates_files = grep { m/^templates\// } $tar->list_files;
    for my $templates_file (@templates_files) {
      my $to = $templates_file;
      $self->app->log->debug("Extracting: $templates_file -> $to");
      $tar->extract_file($templates_file, $to);
    }
  }

  {
    remove_tree(File::Spec->catfile("public", "css", "skin", $site_o->skin));
    remove_tree(File::Spec->catfile("public", "images", "skin", $site_o->skin));
    remove_tree(File::Spec->catfile("public", "js", "skin", $site_o->skin));

    my @public_files = grep { m/^public\// } $tar->list_files;
    for my $public_file (@public_files) {
      my $to = $public_file;
      $self->app->log->debug("Extracting: $public_file -> $to");
      $tar->extract_file($public_file, $to);
    }
  }

  remove_tree $media_dir;
  rename "$media_dir.tmp", $media_dir;

  $self->render(json => {ok => Mojo::JSON->true});
}

1;
