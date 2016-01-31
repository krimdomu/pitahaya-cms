return sub {
  my ($schema, $versions) = @_;

    my $res = $schema->resultset('Site');
    while(my $row = $res->next) {
      my $ct = $schema->resultset('ContentType')->create({
        site_id => $row->id,
        name    => 'text/html',
        class   => 'Pitahaya::ContentType::text_html',
      });
      
      my $pages = $schema->resultset('Page')->search({site_id => $row->id});
      while(my $p = $pages->next) {
        $p->content_type_id($ct->id);
        $p->update;
      }
    }
  
  
}; 