FROM debian:sid

MAINTAINER Tord Holmqvist "tord@holmqvi.st"

# Install cups
RUN apt-get update && apt-get install cups cups-pdf whois -y 

# fix samsung drivers
RUN echo "deb http://www.bchemnet.com/suldr/ debian extra" > /etc/apt/sources.list.d/suldr.list
ADD suldr.gpg /tmp
RUN cat /tmp/suldr.gpg | apt-key add -
RUN apt-get update && apt-get -y install suld-driver-4.01.17

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Disbale some cups backend that are unusable within a container
RUN mv /usr/lib/cups/backend/parallel /usr/lib/cups/backend-available/ &&\
    mv /usr/lib/cups/backend/serial /usr/lib/cups/backend-available/ &&\
    mv /usr/lib/cups/backend/usb /usr/lib/cups/backend-available/

ADD etc-cups /etc/cups
RUN mkdir -p /etc/cups/ssl
VOLUME /etc/cups/
VOLUME /var/log/cups
VOLUME /var/spool/cups
VOLUME /var/cache/cups

ADD etc-pam.d-cups /etc/pam.d/cups

EXPOSE 631

ADD start_cups.sh /root/start_cups.sh
RUN chmod +x /root/start_cups.sh
CMD ["/root/start_cups.sh"]
