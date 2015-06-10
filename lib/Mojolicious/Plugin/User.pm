#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package Mojolicious::Plugin::User;

use strict;
use warnings;

use Mojolicious::Plugin;
use Data::Dumper;

use base 'Mojolicious::Plugin';

sub register {
  my ( $plugin, $app ) = @_;

  $app->helper(
    get_user => sub {
      my ( $self, $uid ) = @_;

      my $user_o;
      if($uid =~ m/^\d+$/) {
        $user_o = $self->app->db->resultset("User")->find($uid);
      }
      else {
        $user_o = $self->app->db->resultset("User")->search_rs({ username => $uid})->next;
      }

      if ($user_o) {
        return $user_o;
      }

      return undef;
    },
  );

  $app->helper(
    check_password => sub {
      my ( $self, $uid, $pass ) = @_;
      my $user_o = $app->get_user($uid);
      if($user_o->check_password($pass)) {
        return $user_o->id;
      }
      return undef;
    },
  );
}

1;
