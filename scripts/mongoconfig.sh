#!/bin/bash
#
# Common configuration for MongoDB dump and restore

[[ ( -z "${MONGODB_USER}" ) && ( -n "${MONGODB_PASS}" ) ]] && MONGODB_USER='admin'

[[ ( -n "${MONGODB_USER}" ) ]] && USER_STR=" --username ${MONGODB_USER}"
[[ ( -n "${MONGODB_PASS}" ) ]] && PASS_STR=" --password ${MONGODB_PASS}"
[[ ( -n "${MONGODB_DB}" ) ]] && DB_STR=" --db ${MONGODB_DB}"
[[ ( -n "${MONGODB_AUTH_DB}" ) ]] && AUTH_DB_STR=" --authenticationDatabase ${MONGODB_AUTH_DB}"
