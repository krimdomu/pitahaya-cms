#!/bin/bash

export PERL5LIB=/usr/share/pitahaya/local/lib/perl5
export PATH=/usr/share/pitahaya/local/bin:$PATH

function start_cms() {
  
  cd /var/lib/pitahaya/instance1
  bin/pitahaya admin db --update

  hypnotoad -f bin/pitahaya

}

cd /var/lib/pitahaya

if [ -d instance1 ]; then
  start_cms
else

  /usr/share/pitahaya/bin/pitahaya admin project --name instance1

  cd instance1
  bin/pitahaya admin config --host $DB_HOST --schema $DB_SCHEMA --user $DB_USER --password $DB_PASSWORD --search_host $SEARCH_HOST --search_index $SEARCH_INDEX
  bin/pitahaya admin db --init

  bin/pitahaya admin site --create --name $SITE_NAME --skin $SITE_NAME

  start_cms
fi
