#!/bin/bash

bundle exec  rake db:exists && bundle exec rake db:migrate || bundle exec rake db:setup
thin start --ssl --ssl-verify --ssl-key-file ssl/server.key --ssl-cert-file ssl/greenlight-server.crt -p 3000
