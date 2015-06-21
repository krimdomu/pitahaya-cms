FROM ubuntu:latest

ENV VERSION 0.1

EXPOSE 8080
VOLUME ["/var/lib/pitahaya"]

RUN apt-get update
RUN apt-get -y install git carton

RUN apt-get -y build-dep \
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

ENV PITAHAYA_VERSION 0.1

ADD files/install.sh /usr/local/bin/install_pitahaya.sh
RUN chmod 755 /usr/local/bin/install_pitahaya.sh
RUN mkdir -p /var/lib/pitahaya
RUN /usr/local/bin/install_pitahaya.sh

ADD files/run.sh /usr/local/bin/run_pitahaya.sh
RUN chmod 755 /usr/local/bin/run_pitahaya.sh

CMD ["/usr/local/bin/run_pitahaya.sh"]
