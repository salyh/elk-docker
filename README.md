# ELK 2 ready to use demo

This Docker image provides a convenient centralised log server and log management web interface, by packaging Elasticsearch (version 2.0.0), Logstash (version 2.0.0), and Kibana (version 4.2.0), collectively known as ELK2.
It comes bundled with the data from [NY traffic accidents](https://github.com/elastic/examples/tree/master/ELK_nyc_traffic_accidents) as a ready to use ELK demo.

### Use as docker container

* ./docker.sh 

### Use as vagrant box

* vagrant up

### After starting the docker image or the vagrant box point your browser to

* [http://localhost:5601/app/kibana](http://localhost:5601/app/kibana) and open the "NYC Motor Vehicle Collisions" dashboard
* [http://localhost:9200](http://localhost:9200)

To see any data on the "NYC Motor Vehicle Collisions" dashboard make sure your selected time range is "Last 5 years".
The data will be indexed live when the container is running, so expect changing figures until dataload is complete.


### Original documentation

* [README](docs/index.md)
* [ELK Docker image documentation web page](http://elk-docker.readthedocs.org/)

### About

Originally written by [Sébastien Pujadas](https://pujadas.net), released under the [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0).
