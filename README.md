# ELK 2 out of the box -ready to use- demo

Consists of

* Elasticsearch 2
* Logstash 2
* Kibana 4

and comes bundled with the data from [NY traffic accidents](https://github.com/elastic/examples/tree/master/ELK_nyc_traffic_accidents) 
as a out of the box -ready to use- demo.

### Use with docker

* ./docker.sh 

### Use with vagrant

* vagrant up

Tested with Vagrant 1.7.4 and VirtualBox 5

### After starting the docker image or the vagrant box point your browser to

* [http://localhost:5601/app/kibana](http://localhost:5601/app/kibana) and open the "NYC Motor Vehicle Collisions" dashboard
* [http://localhost:9200/_plugin/kopf/](http://localhost:9200/_plugin/kopf/)

To see any data on the "NYC Motor Vehicle Collisions" dashboard make sure your selected time range is "Last 5 years".
The data will be indexed live when the container is running for the first time, so expect changing figures until dataload is complete.

### This project was derived from spujadas/elk-docker

* [README](docs/index.md)
* [ELK Docker image documentation web page](http://elk-docker.readthedocs.org/)
* written by [Sébastien Pujadas](https://pujadas.net), released under the [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0).

