FROM jfried/perl:latest

ENV PITAHAYA_VERSION 0.1.3

EXPOSE 8080
VOLUME ["/var/lib/pitahaya"]

ADD files/install.sh /usr/local/bin/install_pitahaya.sh
RUN chmod 755 /usr/local/bin/install_pitahaya.sh
RUN mkdir -p /var/lib/pitahaya
RUN /usr/local/bin/install_pitahaya.sh

ADD files/run.sh /usr/local/bin/run_pitahaya.sh
RUN chmod 755 /usr/local/bin/run_pitahaya.sh

CMD ["/usr/local/bin/run_pitahaya.sh"]
