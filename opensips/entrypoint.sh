#!/bin/bash

#SIP_ADVERTISED_IP=${ADVERTISED_IP:-"127.0.0.1"}
DB_ROOT_PASS=${DB_ROOT_PASS:-"password"}

SIP_HOST=${SIP_HOST:-"sip"}
SIP_DOMAIN=${SIP_DOMAIN:-"tutorica.jp"}
SIP_IPADDR=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
SIP_MEMCACHED_HOST=${SIP_MEMCACHED_HOST:-"no.need.for.now"}
#NODE_EXP=$(ip route | grep "dev eth0  proto kernel" | awk '{print $1}' | sed -e 's/\.0.*//' -e 's/\./\\./g')
SIP_TCP=${SIP_TCP:-"80"}
SIP_UDP=${SIP_UDP:-"80"}
SIP_TLS=${SIP_TLS:-"443"}
DB_PROTO=${DB_PROTO:-"mysql"}
DB_PROTO_UPPER=${DB_PROTO_UPPER:-"MYSQL"}
DB_USER=${DB_USER:-"opensips"}
DB_PASS=${DB_PASS:-"opensipsrw"}
DB_HOST=${DB_HOST:-"127.0.0.1"}
SIP_RELAY_HOST=${SIP_RELAY_HOST:-"127.0.0.1"}
SIP_RELAY_PORT=${SIP_RELAY_PORT:-"5180"}

SIP_SHARED_MEM=4096
SIP_PKG_MEM=128

sed \
    -e "s/^#\ DBENGINE=.*/DBENGINE=$DB_PROTO_UPPER/" \
    -e "s/^#\ DBHOST=.*/DBHOST=$DB_HOST/" \
    -e "s/^#\ INSTALL_EXTRA_TABLES=ask/INSTALL_EXTRA_TABLES=yes/" \
    -e "s/^#\ INSTALL_PRESENCE_TABLES=ask/INSTALL_PRESENCE_TABLES=yes/" \
    -i /usr/local/etc/opensips/opensipsctlrc

PW=$DB_ROOT_PASS /usr/local/sbin/opensipsdbctl create

#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST < /usr/local/share/opensips/mysql/radius.sql
#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST \
#    -e "GRANT ALL PRIVILEGES ON radius.* TO '$DB_USER' IDENTIFIED BY '$DB_PASS';"


# Configure opensips.cfg
#sed -e "s/^log_stderror=no/log_stderror=yes/g" \
#    -e "s/advertised_address=.*/advertised_address=\"${ADVERTISED_IP}\"/g" \
#    -e "s/alias=.*/alias=\"${ADVERTISED_IP}\"/g" \
#    -e "s/listen=.*/listen=tcp:${HOST_IP}:5060\nlisten=udp:${HOST_IP}:5060/g" \
#    -e "s/fr_timeout/fr_timer/g" \
#    -e "s/fr_inv_timeout/fr_inv_timer/g" \
#    -e "s/^loadmodule \"proto_udp.so\"/#loadmodule \"proto_udp.so\"/g" \
#    -i /usr/local/etc/opensips/opensips.cfg

sed \
    -e 's/SIP_HOST/'$SIP_HOST'/g' \
    -e 's/SIP_DOMAIN/'$SIP_DOMAIN'/g' \
    -e 's/SIP_IPADDR/'$SIP_IPADDR'/g' \
    -e 's/SIP_MEMCACHED_HOST/'$SIP_MEMCACHED_HOST'/g' \
    -e 's/SIP_TCP/'$SIP_TCP'/g' \
    -e 's/SIP_UDP/'$SIP_UDP'/g' \
    -e 's/SIP_TLS/'$SIP_TLS'/g' \
    -e 's/DB_PROTO/'$DB_PROTO'/g' \
    -e 's/DB_USER/'$DB_USER'/g' \
    -e 's/DB_PASS/'$DB_PASS'/g' \
    -e 's/DB_HOST/'$DB_HOST'/g' \
    -e 's/SIP_RELAY_HOST/'$SIP_RELAY_HOST'/g' \
    -e 's/SIP_RELAY_PORT/'$SIP_RELAY_PORT'/g' \
    </usr/local/etc/opensips/opensips.cfg.tmpl \
    >/usr/local/etc/opensips/opensips.cfg

sed \
    -e 's/SIP_IPADDR/'$SIP_IPADDR'/g' \
    -e 's/DB_HOST/'$DB_HOST'/g' \
    </usr/local/etc/opensips/perlfunctions.pl.tmpl \
    >/usr/local/etc/opensips/perlfunctions.pl


#    -e 's/PH_NODE_EXP/'$NODE_EXP'/g' \
cp /usr/local/etc/opensips/tls/user/user-privkey.pem /usr/local/etc/opensips/privkey.pem
cp /usr/local/etc/opensips/tls/user/user-cert.pem /usr/local/etc/opensips/cert.pem
cp /usr/local/etc/opensips/tls/user/user-calist.pem /usr/local/etc/opensips/calist.pem

/usr/local/sbin/opensips -m $SIP_SHARED_MEM -M $SIP_PKG_MEM -P /var/run/opensips/opensips.pid 2>&1 >/var/log/opensips.log

tail -F /var/log/opensips.log
#tail -F /var/log/{opensips.log,mediaproxy.log}
#while true; do 
#    sleep 3600
#done
