#!/bin/bash

source /dockup/mongoconfig.sh

MONGO_RESTORE_CMD="mongorestore --host ${MONGODB_HOST} --port ${MONGODB_PORT} ${USER_STR}${PASS_STR} ${WORK_DIR}/${MONGO_BACKUP_NAME}"

echo "Restoring MongoDB database dump..."
eval "time $MONGO_RESTORE_CMD"
rc=$?
/dockup/mongoclean.sh

if [ $rc -ne 0 ]; then
  echo "ERROR: Failed to restore MongoDB dump"
  exit $rc
else
  echo "Successfully restored database dump"
fi
