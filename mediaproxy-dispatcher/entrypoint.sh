#!/bin/bash
set -x

DB_ROOT_PASS=${DB_ROOT_PASS:-"password"}

HOST_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
MP_DISPATCHERS=$HOST_IP:25060
MP_PORTRANGE=20000:60000
MP_PERIOD=0
MP_LISTEN=$HOST_IP:25060
MP_LISTEN_MANAGEMENT=127.0.0.1:25061
DB_USER=${DB_USER:-"statistic"}
DB_PASS=${DB_PASS:-"statistic"}
DB_HOST=${DB_HOST:-"127.0.0.1"}
DB=${DB:-"statistic"}
DB_URI=${DB_URI:-"mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB"}

sed \
    -e "s/^;dispatchers =.*/dispatchers = $MP_DISPATCHERS/g" \
    -e "s/^;port_range =.*/port_range = $MP_PORTRANGE/g" \
    -e "s/^;log_level =.*/log_level = DEBUG/g" \
    -e "s/^;traffic_sampling_period =.*/traffic_sampling_period = $MP_PERIOD/g" \
    -e "s/^;listen =.*/listen = $MP_LISTEN/g" \
    -e "s/^;listen_management =.*/listen_management = $MP_LISTEN_MANAGEMENT/g" \
    -e "s/^;management_use_tls = yes/management_use_tls = no/g" \
    -e "s/^;accounting =.*/accounting = database/g" \
    -e "s!^;dburi =.*!dburi = $DB_URI!g" \
    -e "s/^;max_connections =.*/max_connections = 50/g" \
    -e "s/^;sessions_table = media_sessions/sessions_table = media_sessions/g" \
    -e "s/^;callid_column = call_id/callid_column = call_id/g" \
    -e "s/^;fromtag_column = from_tag/fromtag_column = from_tag/g" \
    -e "s/^;totag_column = to_tag/totag_column = to_tag/g" \
    -e "s/^;info_column = info/info_column = info/g" \
    -i /etc/mediaproxy/config.ini

#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST < /etc/mediaproxy/script/statistic.sql
#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST \
#    -e "GRANT ALL PRIVILEGES ON $DB.* TO '$DB_USER' IDENTIFIED BY '$DB_PASS';"

/usr/bin/media-dispatcher --no-fork
