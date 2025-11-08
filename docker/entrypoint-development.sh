#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

if ! bundle check ; then
  echo -e "\e[31m!!! Missing gems, you need to building the docker image again running \"docker compose build app\" !!!"
  exit 1
fi

echo "Prepare Database"
bin/rails db:prepare

exec "$@"
