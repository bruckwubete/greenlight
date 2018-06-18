#!/bin/bash
while ! curl http://$DB_HOST:5432/ 2>&1 | grep '52'
do
  echo "Waiting for postgres to start up ..."
  sleep 1
done

bundle exec rake db:exists && bundle exec rake db:migrate || bundle exec rake db:setup
#bundle exec thin start --ssl --ssl-verify --ssl-key-file ssl/server.key --ssl-cert-file ssl/greenlight-server.crt -p 3000
bundle exec rails s