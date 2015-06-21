#!//bin/bash

sed -i "s/__DB_HOST__/$DB_HOST/" /usr/local/etc/sphinx.conf
sed -i "s/__DB_USER__/$DB_USER/" /usr/local/etc/sphinx.conf
sed -i "s/__DB_PASSWORD__/$DB_PASSWORD/" /usr/local/etc/sphinx.conf
sed -i "s/__DB_SCHEMA__/$DB_SCHEMA/" /usr/local/etc/sphinx.conf


indexer --all "$@" && searchd && while true; do indexer --all --rotate "$@"; sleep 60; done
