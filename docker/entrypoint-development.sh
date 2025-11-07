#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo -e "!!! If there are missing gems, you need to building the docker image again !!!\nRun: \"docker compose build app\""

echo "Prepare Database"
bin/rails db:prepare

exec "$@"
