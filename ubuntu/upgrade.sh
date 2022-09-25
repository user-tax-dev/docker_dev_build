#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

apt-get update -y
apt-get --allow-yes=true -o Dpkg::Options::='--force-confdef' -fuy dist-upgrade
apt-get remove cloud-init || true
apt-get install -y --allow-yes=true cloud-init
apt autoremove -y
do-release-upgrade

