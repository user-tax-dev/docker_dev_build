FROM ubuntu as build

ENV LANG zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8
ENV TZ Asia/Shanghai

RUN \
apt-get update &&\
apt-get install -y tzdata language-pack-zh-hans

RUN \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime &&\
echo $TZ > /etc/timezone &&\
locale-gen zh_CN.UTF-8 

WORKDIR /
COPY build/ubuntu_zh/os .

