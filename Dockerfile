FROM debian:jessie
MAINTAINER Eric Lemoine <elemoine@mirantis.com>

WORKDIR /tmp/build
COPY .build/heka_0.10.0b2_amd64.deb packages/
RUN dpkg -i /tmp/build/packages/heka_0.10.0b2_amd64.deb
RUN rm -rf /tmp/build && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/hekad"]
