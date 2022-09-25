#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

