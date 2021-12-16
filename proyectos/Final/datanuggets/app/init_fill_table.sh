#!/bin/bash
set -e

POSTGRES="psql --username ${PGUSER}"

echo "Populating database..."
psql -d ${DB_NAME} -a  -U${POSTGRES_USER} -c "\COPY train_table FROM '/dat/df.csv' delimiter ',' csv;"
