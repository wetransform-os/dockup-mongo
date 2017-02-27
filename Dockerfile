FROM wetransform/dockup:latest
LABEL maintainer="Simon Templer <simon@wetransform.to>"
ENV PATHS_TO_BACKUP /dockup/mongodump
VOLUME ["/dockup/mongodump"]
ENV MONGO_BACKUP_NAME mongodump
ENV BEFORE_BACKUP_CMD ./mongodump.sh
ENV AFTER_BACKUP_CMD ./mongoclean.sh
ENV AFTER_RESTORE_CMD ./mongorestore.sh
ENV MONGODB_HOST mongodb
ENV MONGODB_PORT 27017
COPY /scripts /dockup/
RUN chmod 755 /dockup/*.sh

# install MongoDB shell & tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
&& echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
&& apt-get update \
&& apt-get install -y mongodb-org-shell mongodb-org-tools
