#!/bin/bash
if [ ! -f "/config/forked-daapd.conf" ]; then
cp /defaults/forked-daapd.conf /config/forked-daapd.conf
fi
if [ ! -d "/config/logs-databases-and-cache" ]; then
mkdir -p /config/logs-databases-and-cache
chown -R abc:abc /config/logs-databases-and-cache
fi
if [ ! -d "/daapd-pidfolder" ]; then
mkdir -p /daapd-pidfolder
chown -R abc:abc /daapd-pidfolder
fi
chown abc:abc -R /config/



