package Search;

use Mojo::Base 'Pitahaya::PageType';

sub GET {
  my ($self) = @_;
  
  my $stm = $self->controller->sphinx->prepare("SELECT * FROM cms WHERE MATCH(?)");
  $stm->bind_param(1, $self->controller->param("q"));
  $stm->execute;

  $self->controller->stash("search_res", $stm);
}

# sub POST {}
# sub PUT {}
# sub DELETE {}

1;
