#!/usr/bin/env sh

set -x
sudo docker kill my-apache-php-app
sudo docker rm my-apache-php-app
