FROM ubuntu:latest

WORKDIR /tmp/nginx

ADD . .

RUN chmod 777 build.sh \
    && ./build.sh

MAINTAINER shaun
