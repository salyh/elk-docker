#!/bin/bash
#
# /usr/local/bin/start.sh
# Start Elasticsearch, Logstash and Kibana services
#
# spujadas 2015-10-09; added initial pidfile removal and graceful termination

# WARNING - This script assumes that the ELK services are not running, and is
#   only expected to be run once, when the container is started.
#   Do not attempt to run this script if the ELK services are running (or be
#   prepared to reap zombie processes).


## handle termination gracefully

_term() {
  echo "Terminating ELK"
  service elasticsearch stop
  service logstash stop
  service kibana stop
  exit 0
}

trap _term SIGTERM


## remove pidfiles in case previous graceful termination failed
# NOTE - This is the reason for the WARNING at the top - it's a bit hackish,
#   but if it's good enough for Fedora (https://goo.gl/88eyXJ), it's good
#   enough for me :)

rm -f /var/run/elasticsearch/elasticsearch.pid /var/run/logstash.pid \
  /var/run/kibana4.pid

## start services

chown -R elasticsearch:elasticsearch /snapshot

update-rc.d topbeat defaults 95 10
update-rc.d elasticsearch defaults 95 10
update-rc.d logstash defaults 95 10
update-rc.d kibana defaults 95 10

service elasticsearch start

chown -R logstash:logstash /opt/logstash
service logstash start

# wait for elasticsearch to start up
# - https://github.com/elasticsearch/kibana/issues/3077
counter=0
while [ ! "$(curl localhost:9200 2> /dev/null)" -a $counter -lt 30  ]; do
  sleep 1
  ((counter++))
  echo "waiting for Elasticsearch to be up ($counter/30)"
  cat /var/log/elasticsearch/elasticsearch.log
done



chown -R kibana:kibana /opt/kibana
service kibana start
service topbeat start

if [ ! -f /tmp/elk2_init ]
then
  curl -XPUT -s 'http://localhost:9200/_snapshot/elk_backup' -d '{
      "type": "fs",
      "settings": {
          "location": "/snapshot"
      }
  }'

  curl -XPOST -s 'http://localhost:9200/_snapshot/elk_backup/elk2snap2/_restore'

  echo
  echo "Loading demo_nyc"
  ## nyc demo
  cat /etc/demo_nyc/nyc_collision_data.csv | /opt/logstash/bin/logstash -f /etc/demo_nyc/nyc_collision_logstash.conf
  touch /tmp/elk2_init
fi

cd /opt
wget https://download.elastic.co/beats/dashboards/beats-dashboards-1.2.1.zip
unzip beats-dashboards-1.2.1.zip
cd beats-dashboards-1.2.1
./load.sh -url "http://localhost:9200"

echo "Started"
tail -f /var/log/elasticsearch/* &
tail -f /var/log/kibana/* &
tail -f /var/log/logstash/* &
wait
