#!/bin/bash
set -x

HOST_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
MP_PERIOD=0
MP_LISTEN=${MP_LISTEN:-"$HOST_IP"}
MP_LISTEN_PORT=${MP_LISTEN_PORT:-"25060"}
MP_MAX_CONNECTIONS=${MP_MAX_CONNECTIONS:-"50"}
DB_USER=${DB_USER:-"statistic"}
DB_PASS=${DB_PASS:-"statistic"}
DB_HOST=${DB_HOST:-"127.0.0.1"}
DB=${DB:-"statistic"}
DB_URI=${DB_URI:-"mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB"}

sed \
    -e "s/^;log_level =.*/log_level = DEBUG/g" \
    -e "s/^;traffic_sampling_period =.*/traffic_sampling_period = $MP_PERIOD/g" \
    -e "s/^;listen =.*/listen = $MP_LISTEN:$MP_LISTEN_PORT/g" \
    -e "s/^;management_use_tls = yes/management_use_tls = no/g" \
    -e "s/^;accounting =.*/accounting = database/g" \
    -e "s!^;dburi =.*!dburi = $DB_URI!g" \
    -e "s/^;max_connections =.*/max_connections = $MP_MAX_CONNECTIONS/g" \
    -e "s/^;sessions_table = media_sessions/sessions_table = media_sessions/g" \
    -e "s/^;callid_column = call_id/callid_column = call_id/g" \
    -e "s/^;fromtag_column = from_tag/fromtag_column = from_tag/g" \
    -e "s/^;totag_column = to_tag/totag_column = to_tag/g" \
    -e "s/^;info_column = info/info_column = info/g" \
    -i /etc/mediaproxy/config.ini

# Please create statistic database in advance
#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST < /etc/mediaproxy/script/statistic.sql
#mysql -uroot -p$DB_ROOT_PASS -h$DB_HOST \
#    -e "GRANT ALL PRIVILEGES ON $DB.* TO '$DB_USER' IDENTIFIED BY '$DB_PASS';"

/usr/bin/media-dispatcher --no-fork
