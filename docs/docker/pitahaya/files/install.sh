#!/bin/bash

mkdir -p /usr/share/pitahaya
cd /usr/share/pitahaya

git clone https://github.com/krimdomu/pitahaya-cms.git .
chmod 755 bin/*

carton install

