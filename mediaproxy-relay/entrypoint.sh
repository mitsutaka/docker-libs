#!/bin/bash
set -x

DB_ROOT_PASS=${DB_ROOT_PASS:-"password"}

HOST_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
MP_DISPATCHERS=$HOST_IP:15060
MP_PORTRANGE=20000:60000
MP_PERIOD=0
MP_LISTEN=$HOST_IP:15060
MP_LISTEN_MANAGEMENT=127.0.0.1:15061
DB_USER=${DB_USER:-"statistic"}
DB_PASS=${DB_PASS:-"statistic"}
DB_HOST=${DB_HOST:-"127.0.0.1"}
DB=${DB:-"statistic"}
DB_URI=${DB_URI:-"mysql://$DB_USER:$DB_PASS@$DB_HOST/$DB"}

/usr/bin/media-relay --no-fork
