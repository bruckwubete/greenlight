#!/bin/bash

bundle exec rake db:exists && bundle exec rake db:migrate || bundle exec rake db:setup
#bundle exec thin start --ssl --ssl-verify --ssl-key-file ssl/server.key --ssl-cert-file ssl/greenlight-server.crt -p 3000
#exec bundle exec puma -C config/puma.rb
bundle exec rails s -b 'ssl://0.0.0.0:3000?key=ssl/server.key&cert=ssl/greenlight-server.crt'
