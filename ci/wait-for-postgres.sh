#!/bin/bash

PGUSER=postgres
TIMEOUT=30

until psql -h localhost -U $PGUSER -d postgres -c "select 1" > /dev/null 2>&1 || [ $TIMEOUT -eq 0 ]; do
  echo "Waiting for postgres server, $((TIMEOUT--)) remaining attempts..."
  sleep 2
done
