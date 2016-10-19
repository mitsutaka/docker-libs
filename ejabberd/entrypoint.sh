#!/bin/bash
set -x
#export EJABBERD_ROOT=/opt/ejabberd
#export PATH=$PATH:$EJABBERD_ROOT/bin

echo "EJABBERD_BYPASS_WARNINGS=true" >> /etc/ejabberd/ejabberdctl.cfg

HOSTIP="127.0.0.1"
DOMAIN=${DOMAIN:-"tutorica.jp"}
NODENAME=master

DB_PROTO=${DB_PROTO:-"mysql"}
DB_NAME=${DB_NAME:-"messagedb"}
DB_USER=${DB_USER:-"tutmessageuser"}
DB_PASS=${DB_PASS:-"tutmexx345"}
DB_HOST=${DB_HOST:-"127.0.0.1"}
CERT=/etc/ssl/tutorica.jp.pem

sed -i.bak \
    -e 's/^#INET_DIST_INTERFACE=127.0.0.1/INET_DIST_INTERFACE='0.0.0.0'/g' \
    -e "s/^#ERLANG_NODE=ejabberd@localhost/ERLANG_NODE=ejabberd@$NODENAME.$DOMAIN/g" \
    -e 's/^#FIREWALL_WINDOW=/FIREWALL_WINDOW=6210-6250/g' \
    -e 's/^#ERL_MAX_PORTS=32000/ERL_MAX_PORTS=200000/g' \
    /etc/ejabberd/ejabberdctl.cfg

sed \
    -e "s/^  - \"DOMAIN\"/  - \"$DOMAIN\"/g" \
    -e "s/^      - \"admin\": \"DOMAIN\"/      - \"admin\": \"$DOMAIN\"/g" \
    -e "s/^odbc_type: DB_PROTO/odbc_type: $DB_PROTO/g" \
    -e "s/^odbc_server: \"DB_HOST\"/odbc_server: \"$DB_HOST\"/g" \
    -e "s/^odbc_database: \"DB_NAME\"/odbc_database: \"$DB_NAME\"/g" \
    -e "s/^odbc_username: \"DB_USER\"/odbc_username: \"$DB_USER\"/g" \
    -e "s/^odbc_password: \"DB_PASS\"/odbc_password: \"$DB_PASS\"/g" \
    -e "s!certfile: \"CERT\"!certfile: \"$CERT\"!g" \
    </etc/ejabberd/ejabberd.yml.tmpl \
    >/etc/ejabberd/ejabberd.yml

#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST < /etc/ejabberd/messagedb.sql
#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST \
#    -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER' IDENTIFIED BY '$DB_PASS';"

#touch $EJABBERD_ROOT/.erlang.cookie
#echo "CIPXVPSGPJSINPBTKUJK" >> $EJABBERD_ROOT/.erlang.cookie
#chmod 400 $EJABBERD_ROOT/.erlang.cookie
touch /var/lib/ejabberd/.erlang.cookie
echo "CIPXVPSGPJSINPBTKUJK" >> /var/lib/ejabberd/.erlang.cookie
chmod 400 /var/lib/ejabberd/.erlang.cookie

echo "127.0.0.1 $NODENAME.$DOMAIN $(hostname -f)" >>/etc/hosts

ejabberdctl start

tail -F /var/log/ejabberd/ejabberd.log
