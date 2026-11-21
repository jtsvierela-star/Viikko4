#!/bin/bash

set -Eeuo pipefail

KOHDE="ubuntu@192.168.1.205"
AVAIN="/home/ubuntu/.ssh/backup_to_server2"
TUNNISTETIEDOT="/home/ubuntu/.ssh/known_hosts"
KOHDEKANSIO="/var/backups/db"

AIKA=$(date +"%Y-%m-%d")
TIEDOSTO="kaikki-${AIKA}.sql.gz"
VALIAIKAINEN="/tmp/${TIEDOSTO}.tmp"

LOKI="/home/ubuntu/scripts/backup_db.log"

exec >> "$LOKI" 2>&1

trap 'echo "[$(date)] VIRHE: tietokantavarmuuskopiointi epäonnistui."' ERR
trap 'rm -f "$VALIAIKAINEN"' EXIT

echo "[$(date)] Aloitetaan tietokantojen varmuuskopiointi."

sudo -n mariadb-dump --all-databases \
    --single-transaction \
    --routines \
    --events \
    --triggers | gzip > "$VALIAIKAINEN"

test -s "$VALIAIKAINEN"

scp -i "$AVAIN" \
    -o UserKnownHostsFile="$TUNNISTETIEDOT" \
    -o BatchMode=yes \
    "$VALIAIKAINEN" \
    "${KOHDE}:${KOHDEKANSIO}/${TIEDOSTO}.tmp"

ssh -i "$AVAIN" \
    -o UserKnownHostsFile="$TUNNISTETIEDOT" \
    -o BatchMode=yes \
    "$KOHDE" \
    "chmod 600 '${KOHDEKANSIO}/${TIEDOSTO}.tmp' && \
     mv '${KOHDEKANSIO}/${TIEDOSTO}.tmp' '${KOHDEKANSIO}/${TIEDOSTO}' && \
     find '${KOHDEKANSIO}' -type f -name 'kaikki-*.sql.gz' -mmin +20160 -delete"

echo "[$(date)] ONNISTUI: ${TIEDOSTO}"
