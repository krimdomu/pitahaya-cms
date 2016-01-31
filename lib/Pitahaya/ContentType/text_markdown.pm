#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::ContentType::text_markdown {
  use Moo;
  use Text::Markdown qw'markdown';
  
  sub parse {
    my ($self, $c) = @_;
    return markdown($c);
  }
}

1;