FROM maven:3.6-openjdk-11-slim

RUN mkdir -p /tmp/felix-uberizer/libs

COPY ./felix-uberizer.sh /tmp/felix-uberizer
COPY ./libs/* /tmp/felix-uberizer/libs/

RUN chmod +x /tmp/felix-uberizer/felix-uberizer.sh

RUN apt-get update
RUN apt-get --assume-yes install jq

WORKDIR /tmp/felix-uberizer
ENTRYPOINT ["/tmp/felix-uberizer/felix-uberizer.sh"]