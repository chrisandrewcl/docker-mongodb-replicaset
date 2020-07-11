#!/bin/bash

function waitForMongoNodes () {

  while true; do
    mongo ${MONGO1_HOST}:${MONGO1_PORT} --eval "db" > /dev/null 2>&1 && break
  done

  while true; do
    mongo ${MONGO2_HOST}:${MONGO2_PORT} --eval "db" > /dev/null 2>&1 && break
  done

  while true; do
    mongo ${MONGO3_HOST}:${MONGO3_PORT} --eval "db" > /dev/null 2>&1 && break
  done

  mongo ${MONGO1_HOST}:${MONGO1_PORT}/admin --eval "db.runCommand({ replSetInitiate: { _id: 'local', members: [{_id: 0, host: '${MONGO1_HOST}:${MONGO1_PORT}', priority: 2 }, { _id: 1, host: '${MONGO2_HOST}:${MONGO2_PORT}' }, { _id: 2, host: '${MONGO3_HOST}:${MONGO3_PORT}' } ]} })"

}

waitForMongoNodes &