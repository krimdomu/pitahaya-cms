package Index;

use Mojo::Base 'Pitahaya::PageType';

sub GET {
  my ($self) = @_;
  $self->controller->stash("current_time", time());
}

# sub POST {}
# sub PUT {}
# sub DELETE {}

1;
