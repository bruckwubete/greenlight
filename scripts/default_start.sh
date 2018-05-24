#!/bin/bash

rake db:exists && rake db:migrate || rake db:setup
thin start --ssl --ssl-verify --ssl-key-file ssl/server.key --ssl-cert-file ssl/greenlight-server.crt -p 3000
