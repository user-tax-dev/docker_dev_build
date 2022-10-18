#!/usr/bin/env bash

set -ex

apt-get update
apt-get install -y curl git
cd ~

curl --connect-timeout 2 -m 4 -s https://t.co >/dev/null || CN=1
[ $CN ] && git config --global url."https://ghproxy.com/https://github.com".insteadOf "https://github.com"

clone() {
  out=$(basename $1)
  if [ ! -d "$out" ]; then
    git clone --recursive --depth=1 https://github.com/$1.git
  else
    cd $out
    git fetch --all
    git reset --hard origin/main
    cd $DIR
  fi
}

clone user-tax-dev/docker_dev_build

~/docker_dev_build/ubuntu/init.sh
