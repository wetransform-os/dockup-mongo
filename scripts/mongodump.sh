#!/bin/bash

source /dockup/mongoconfig.sh

MONGO_BACKUP_CMD="mongodump --out "'${WORK_DIR}/${MONGO_BACKUP_NAME}'" --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR}${AUTH_DB_STR}${DB_STR} ${MONGODB_DUMP_EXTRA_OPTS}"

echo "Creating MongoDB database dump..."
eval "time $MONGO_BACKUP_CMD"
rc=$?
if [ $rc -ne 0 ]; then
  echo "ERROR: Failed to create MongoDB dump"
  exit $rc
else
  echo "Successfully created database dump"
fi
