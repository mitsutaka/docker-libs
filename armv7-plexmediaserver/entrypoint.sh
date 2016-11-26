#!/bin/bash

export LD_LIBRARY_PATH=/opt/plexmediaserver
export PLEX_MEDIA_SERVER_HOME=/opt/plexmediaserver
export PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=/var/lib/plex
export PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
export PLEX_MEDIA_SERVER_TMPDIR=/tmp
export TMPDIR=/tmp
/opt/plexmediaserver/Plex\ Media\ Server
tail -F /var/lib/plex/Plex\ Media\ Server/Logs/{Plexr\ DLNA\ Server\ Neptune.log,Plex\ DLNA\ Server.log,Plex\ Media\ Server.log}
