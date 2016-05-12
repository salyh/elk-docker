# Dockerfile for ELK stack
# Elasticsearch 2.3.1, Logstash 2.3.1, Kibana 4.5.0
# Original Author: Sebastien Pujadas http://pujadas.net
#                  https://github.com/spujadas/elk-docker

# Build with:
# docker build -t <repo-user>/elk .

# Run with:
# docker run -p 5601:5601 -p 9200:9200 -p 9300:9300 -p 5000:5000 -it --name elk <repo-user>/elk

FROM java:8-jdk
MAINTAINER Hendrik Saly (codecentric AG)
ENV REFRESHED_AT 2016-04-17

###############################################################################
#                                INSTALLATION
###############################################################################

### install Elasticsearch

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -qq \
 && apt-get install -qqy apt-utils curl net-tools unzip wget

RUN curl -s http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list
RUN echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | tee -a /etc/apt/sources.list
RUN echo "deb http://packages.elastic.co/logstash/2.3/debian stable main" | tee -a /etc/apt/sources.list
RUN echo "deb http://packages.elastic.co/beats/apt stable main" | tee -a /etc/apt/sources.list

RUN apt-get update -qq \
 && apt-get install -qqy \
		elasticsearch=2.3.1 kibana=4.5.0 logstash=1:2.3.1-1 topbeat \
 && apt-get clean

### install plugins
RUN /usr/share/elasticsearch/bin/plugin install license
RUN /usr/share/elasticsearch/bin/plugin install graph
RUN /usr/share/elasticsearch/bin/plugin install marvel-agent
RUN /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/2.1.2
RUN /usr/share/elasticsearch/bin/plugin install royrusso/elasticsearch-HQ
RUN /opt/kibana/bin/kibana plugin --install elasticsearch/marvel/2.3.1
RUN /opt/kibana/bin/kibana plugin --install elastic/sense
RUN /opt/kibana/bin/kibana plugin --install elasticsearch/graph/latest

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
