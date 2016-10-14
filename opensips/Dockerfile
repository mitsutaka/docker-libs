FROM ubuntu:14.04
MAINTAINER "Mitz Amano <mitz@linux.com>"

USER root
RUN echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse" >> /etc/apt/sources.list
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 049AD65B && \
#    echo "deb http://apt.opensips.org trusty 1.11-releases" >>/etc/apt/sources.list && \

#RUN apt-get update && \
#    echo "mysql-server mysql-server/root_password password passwd" | debconf-set-selections && \
#    echo "mysql-server mysql-server/root_password_again password passwd" | debconf-set-selections && \
#    apt-get install -y mysql-server git make bison flex libmysqlclient-dev \
#                       libncurses5 libncurses5-dev mysql-client expect

RUN apt-get update && \
    apt-get install -y git make gcc bison flex libmysqlclient-dev libssl-dev libpcre3-dev libperl-dev python-dev libncurses5-dev pkg-config mysql-client openssl libhttp-message-perl liblwp-protocol-https-perl libhttp-async-perl libjson-perl libnet-https-nb-perl
# curl libGeoIP-dev libradiusclient-ng-dev libsnmp-dev libmemcached-dev 

# mysql-client libdbd-mysql-perl

RUN git clone https://github.com/OpenSIPS/opensips.git -b 1.11.8 ~/opensips-1.11.8
COPY opensips-1.11.8-auth_mod-add-join.patch /tmp/
RUN cd ~/opensips-1.11.8 && patch -p1 < /tmp/opensips-1.11.8-auth_mod-add-join.patch && \
    make include_modules="auth_db db_mysql regex perl python" TLS=1 install && \
    cd .. && rm -rf ~/opensips-1.11.8 && rm -f /tmp/opensips-1.11.8-auth_mod-add-join.patch
#    make include_modules="aaa_radius cachedb_memcached db_mysql regex mmgeoip perl python snmpstats" TLS=1 install && cd .. && rm -rf ~/opensips_1_11

#    apt-get install -y libmicrohttpd10 && \
#    apt-get clean

#RUN curl -O http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && gunzip GeoLiteCity.dat.gz && mv GeoLiteCity.dat /usr/local/etc/opensips/

#RUN apt-get purge -y bison build-essential ca-certificates flex git m4 pkg-config curl && \
RUN apt-get purge -y bison build-essential flex git m4 pkg-config curl && \
    apt-get autoremove -y && \
    apt-get clean all

RUN mkdir -p /var/run/opensips

#COPY conf/opensipsctlrc /usr/local/etc/opensips/opensipsctlrc
COPY conf/opensips.cfg.tmpl /usr/local/etc/opensips/
COPY script/perlfunctions.pl.tmpl /usr/local/etc/opensips/
#COPY script/radius.sql /usr/local/share/opensips/mysql/

COPY entrypoint.sh /sbin
RUN chown root.root /sbin/entrypoint.sh && chmod 700 /sbin/entrypoint.sh

EXPOSE 80 443/tcp

ENTRYPOINT ["entrypoint.sh"]
