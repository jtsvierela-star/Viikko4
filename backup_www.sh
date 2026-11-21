#!/bin/bash

set -Eeuo pipefail

KOHDE="ubuntu@192.168.1.205"
AVAIN="/home/ubuntu/.ssh/backup_to_server2"
TUNNISTETIEDOT="/home/ubuntu/.ssh/known_hosts"
KOHDEKANSIO="/var/backups/www"

AIKA=$(date +"%Y-%m-%d_%H-%M-%S")
UUSI="${KOHDEKANSIO}/www_${AIKA}"

LOKI="/home/ubuntu/scripts/backup_www.log"

exec >> "$LOKI" 2>&1

trap 'echo "[$(date)] VIRHE: rsync-varmuuskopiointi epäonnistui."' ERR

echo "[$(date)] Aloitetaan rsync-varmuuskopiointi."

sudo rsync -avi --no-owner --no-group \
    -e "ssh -i $AVAIN -o UserKnownHostsFile=$TUNNISTETIEDOT -o BatchMode=yes" \
    /var/www/html/ \
    "${KOHDE}:${UUSI}/"

echo "[$(date)] ONNISTUI: www_${AIKA}"
