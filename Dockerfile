FROM wetransform/dockup:20230515
MAINTAINER Simon Templer <simon@wetransform.to>

# install MongoDB shell & tools
RUN curl -fsSL https://pgp.mongodb.com/server-5.0.asc | gpg -o /usr/share/keyrings/mongodb-server-5.0.gpg --dearmor && \
  echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list && \
  apt-get update && \
  apt-get install -y mongodb-org-shell mongodb-org-tools

ADD /scripts /dockup/
RUN chmod 755 /dockup/*.sh

ENV PATHS_TO_BACKUP $WORK_DIR/mongodump
ENV MONGO_BACKUP_NAME mongodump
ENV BEFORE_BACKUP_CMD /dockup/mongodump.sh
ENV AFTER_BACKUP_CMD /dockup/mongoclean.sh
ENV AFTER_RESTORE_CMD /dockup/mongorestore.sh
ENV MONGODB_HOST mongodb
ENV MONGODB_PORT 27017
