# Dockerfile for ELK stack
# Elasticsearch 2.0.0, Logstash 2.0.0, Kibana 4.2.0
# Original Author: Sebastien Pujadas http://pujadas.net
#                  https://github.com/spujadas/elk-docker

# Build with:
# docker build -t <repo-user>/elk .

# Run with:
# docker run -p 5601:5601 -p 9200:9200 -p 9300:9300 -p 5000:5000 -it --name elk <repo-user>/elk

FROM java:8-jdk
MAINTAINER Hendrik Saly (codecentric AG)
ENV REFRESHED_AT 2016-03-14

###############################################################################
#                                INSTALLATION
###############################################################################

### install Elasticsearch

RUN apt-get update -qq \
 && apt-get install -qqy curl apt-utils

RUN curl -s http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main > /etc/apt/sources.list.d/elasticsearch-2.x.list

RUN apt-get update -qq \
 && apt-get install -qqy \
		elasticsearch=2.0.0 \
 && apt-get clean

### install plugins
RUN /usr/share/elasticsearch/bin/plugin install license
RUN /usr/share/elasticsearch/bin/plugin install marvel-agent
RUN /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/2.0

### install Logstash

ENV LOGSTASH_HOME /opt/logstash
ENV LOGSTASH_PACKAGE logstash-2.0.0.tar.gz

RUN mkdir ${LOGSTASH_HOME} \
 && curl -s -O https://download.elasticsearch.org/logstash/logstash/${LOGSTASH_PACKAGE} \
 && tar xzf ${LOGSTASH_PACKAGE} -C ${LOGSTASH_HOME} --strip-components=1 \
 && rm -f ${LOGSTASH_PACKAGE} \
 && groupadd -r logstash \
 && useradd -r -s /usr/sbin/nologin -d ${LOGSTASH_HOME} -c "Logstash service user" -g logstash logstash \
 && mkdir -p /var/log/logstash /etc/logstash/conf.d \
 && chown -R logstash:logstash ${LOGSTASH_HOME} /var/log/logstash

ADD ./logstash-init /etc/init.d/logstash
RUN sed -i -e 's#^LS_HOME=$#LS_HOME='$LOGSTASH_HOME'#' /etc/init.d/logstash \
 && chmod +x /etc/init.d/logstash


### install Kibana

ENV KIBANA_HOME /opt/kibana
ENV KIBANA_PACKAGE kibana-4.2.0-linux-x64.tar.gz

RUN mkdir ${KIBANA_HOME} \
 && curl -s -O https://download.elasticsearch.org/kibana/kibana/${KIBANA_PACKAGE} \
 && tar xzf ${KIBANA_PACKAGE} -C ${KIBANA_HOME} --strip-components=1 \
 && rm -f ${KIBANA_PACKAGE} \
 && groupadd -r kibana \
 && useradd -r -s /usr/sbin/nologin -d ${KIBANA_HOME} -c "Kibana service user" -g kibana kibana \
 && chown -R kibana:kibana ${KIBANA_HOME}

RUN /opt/kibana/bin/kibana plugin --install elasticsearch/marvel/2.0.0

ADD ./kibana-init /etc/init.d/kibana
RUN sed -i -e 's#^KIBANA_HOME=$#KIBANA_HOME='$KIBANA_HOME'#' /etc/init.d/kibana \
 && chmod +x /etc/init.d/kibana


###############################################################################
#                               CONFIGURATION
###############################################################################

### configure Elasticsearch

ADD ./elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
ADD ./demo_nyc/nyc_collision_data.csv /etc/demo_nyc/nyc_collision_data.csv
ADD ./demo_nyc/nyc_collision_kibana.json /etc/demo_nyc/nyc_collision_kibana.json
ADD ./demo_nyc/nyc_collision_logstash.conf /etc/demo_nyc/nyc_collision_logstash.conf
ADD ./demo_nyc/nyc_collision_template.json /etc/demo_nyc/nyc_collision_template.json

### configure Logstash

# cert/key
RUN mkdir -p /etc/pki/tls/certs && mkdir /etc/pki/tls/private
ADD ./logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt
ADD ./logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key

# filters
ADD ./01-lumberjack-input.conf /etc/logstash/conf.d/01-lumberjack-input.conf
ADD ./10-syslog.conf /etc/logstash/conf.d/10-syslog.conf
ADD ./11-nginx.conf /etc/logstash/conf.d/11-nginx.conf
ADD ./30-lumberjack-output.conf /etc/logstash/conf.d/30-lumberjack-output.conf

# patterns
ADD ./nginx.pattern ${LOGSTASH_HOME}/patterns/nginx
RUN chown -R logstash:logstash ${LOGSTASH_HOME}/patterns


###############################################################################
#                                   START
###############################################################################

ADD ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 5601 9200 9300 5000
VOLUME /var/lib/elasticsearch
#VOLUME /snapshot
ADD snapshot /snapshot

CMD [ "/usr/local/bin/start.sh" ]
