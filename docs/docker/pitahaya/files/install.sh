#!/bin/bash

apt-get update
apt-get -y install git carton

apt-get -y build-dep \
  libmojolicious-perl \
  libdbix-class-perl \
  libdbix-class-deploymenthandler-perl \
  libfile-mimeinfo-perl \
  libfile-copy-recursive-perl \
  libfile-chdir-perl \
  libdatetime-perl \
  libdbd-mysql-perl \
  libdbd-pg-perl \
  libuuid-perl

mkdir -p /usr/share/pitahaya
cd /usr/share/pitahaya

git clone https://github.com/krimdomu/pitahaya-cms.git .
chmod 755 bin/*

carton install

