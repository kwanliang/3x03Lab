#!/usr/bin/env sh

set -x
docker kill my-apache-php-app
docker rm my-apache-php-app
sleep 1
set +x