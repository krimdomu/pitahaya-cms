package Pitahaya::Controller::Admin::Dialog;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util 'url_escape';

use File::Path qw(make_path remove_tree);
use File::Spec;
use File::Copy::Recursive qw(dircopy);

use Mojo::JSON qw(decode_json encode_json);
use File::chdir;

use Data::Dumper;

sub select_page_or_media {
    my ($self) = @_;
    $self->render('admin/dialog/select_page_or_media');
}

1;
