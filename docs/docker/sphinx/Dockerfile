FROM centurylink/sphinx:latest

ENV VERSION 1.2

EXPOSE 9312 9306
VOLUME ["/var/idx/sphinx", "/var/log/sphinx", "/var/lib/sphinx", "/var/run/sphinx", "/var/diz/sphinx"]

ADD files/sphinx.conf /usr/local/etc/sphinx.conf
ADD files/launch.sh /launch.sh
RUN chmod 755 /launch.sh

CMD ["./launch.sh"]

