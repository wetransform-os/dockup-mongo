#!/bin/bash
#
# Simple test script for backup and restore
# 
# Before running it, ensure there is a file test-env.txt
# with configuration options as in test-env.txt.sample

# build dockup image
docker build -t wetransform/dockup-mongo:local .

MONGODB_PASS="supersecret"
MONGODB_USER="admin"
MONGODB_AUTH_DB="admin"

# run MongoDB
docker stop dockup-mongo-test
docker rm dockup-mongo-test
docker run -d --name dockup-mongo-test \
  -e MONGODB_PASS=$MONGODB_PASS \
  -e MONGODB_USER=$MONGODB_USER \
  -e MONGODB_DATABASE=$MONGODB_AUTH_DB \
  stempler/mongodb:3.2

# wait for MongoDB to be ready (TODO better way to wait?)
sleep 10

# create dummy content to backup
file_time=`date +%Y-%m-%d\\ %H:%M:%S\\ %Z`
docker exec dockup-mongo-test mongo -u $MONGODB_USER \
  -p $MONGODB_PASS --authenticationDatabase $MONGODB_AUTH_DB \
  test \
  --eval "db.createCollection('test'); db.test.insert({created: \"$file_time\"});"
rc=$?; if [ $rc -ne 0 ]; then
  echo "ERROR: Error creating dummy content for database"
  docker stop dockup-mongo-test
  docker rm dockup-mongo-test
  exit $rc
fi

# backup
docker run --rm \
  --env-file test-env.txt \
  --link dockup-mongo-test:mongodb \
  -e BACKUP_NAME=dockup-mongo-test \
  -e MONGODB_HOST=mongodb \
  -e MONGODB_PORT=27017 \
  -e MONGODB_USER=$MONGODB_USER \
  -e MONGODB_PASS=$MONGODB_PASS \
  --name dockup-run-test wetransform/dockup-mongo:local
rc=$?; if [ $rc -ne 0 ]; then
  echo "ERROR: Error running backup"
  exit $rc
fi

# recreate MongoDB container
docker stop dockup-mongo-test
docker rm dockup-mongo-test
docker run -d --name dockup-mongo-test \
  -e MONGODB_PASS=$MONGODB_PASS \
  -e MONGODB_USER=$MONGODB_USER \
  -e MONGODB_DATABASE=$MONGODB_AUTH_DB \
  stempler/mongodb:3.2

# wait for MongoDB to be ready (TODO better way to wait?)
sleep 10

# restore
docker run --rm \
  --env-file test-env.txt \
  --link dockup-mongo-test:mongodb \
  -e BACKUP_NAME=dockup-mongo-test \
  -e MONGODB_HOST=mongodb \
  -e MONGODB_PORT=27017 \
  -e MONGODB_USER=$MONGODB_USER \
  -e MONGODB_PASS=$MONGODB_PASS \
  -e RESTORE=true \
  --name dockup-run-test wetransform/dockup-mongo:local
rc=$?; if [ $rc -ne 0 ]; then
  echo "ERROR: Error running restore"
  docker stop dockup-mongo-test
  docker rm dockup-mongo-test
  exit $rc
fi

RESULT=$(docker exec dockup-mongo-test mongo -u $MONGODB_USER \
  -p $MONGODB_PASS --authenticationDatabase $MONGODB_AUTH_DB \
  test \
  --eval "db.test.find({}).pretty()" | grep created)

if [ "$RESULT" == "\"created\" : \"$file_time\"" ]; then
  echo "ERROR: Backup did not restore entry"
  exit $rc
else
  echo "Restored database/entry successfully"
fi
