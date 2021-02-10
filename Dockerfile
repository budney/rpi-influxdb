# Pull base image
FROM balenalib/rpi-raspbian:buster
MAINTAINER Len Budney <len.budney@gmail.com>

# Setup external package-sources
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    apt-utils \
    curl \
    --no-install-recommends && \ 
    curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add - && \
    echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list && \
    apt-get update && apt-get install -y influxdb --no-install-recommends && \
    apt-get remove --auto-remove -y apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

COPY influxdb.conf /etc/influxdb/influxdb.conf

ADD run.sh /run.sh
RUN chmod +x /*.sh

ENV PRE_CREATE_DB **None**

# HTTP API
EXPOSE 8086

VOLUME ["/data"]

CMD ["/run.sh"]

