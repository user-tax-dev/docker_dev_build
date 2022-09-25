#!/usr/bin/env bash

org=$1
os=$2

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

set -ex

file=$org_$os

cp build/$os/Dockerfile $file
cat build/Dockerfile >> $file

end=build/$os/end

if [ -f "$end" ]; then
cat $end >> $file
fi

cat build/end >> $file

tag=$(date +%Y-%m-%d)
img=$org/dev_$os
docker buildx build -t $img:$tag -t $img:latest -f $file .
rm -rf $file
