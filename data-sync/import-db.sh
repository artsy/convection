#!/bin/bash

start_datetime=$(date -u +"%D %T %Z")
echo "[data import] Starting at $start_datetime"

aws s3 cp s3://artsy-data/convection/archive.pgdump archive.pgdump

pg_restore archive.pgdump --data-only --no-owner --no-privileges -d $DATABASE_URL

end_datetime=$(date -u +"%D %T %Z")
echo "[data import] Ended at $end_datetime"
