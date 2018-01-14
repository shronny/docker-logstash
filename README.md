[![](https://images.microbadger.com/badges/image/khezen/logstash.svg)](https://hub.docker.com/r/khezen/logstash/) - inspirde by https://hub.docker.com/r/khezen/logstash/

# What is logstash?
Logstash is an open source, server-side data processing pipeline that ingests data from a multitude of sources simultaneously, transforms it, and then sends it to your favorite “stash.” (Elasticsearch for example.)

# What is Kafka splitter configuation?
Kafka Splitter configuration read data from specific topic and send it to splitted topics according to filed from the message itself.

# What message type is splitter support?
the configuration support the follwing messages:
```
{
    "mid":1,
    "desk":"tshirt"
}

```
splitter configuration will create (and send) the data to topic according to mid filed

[<img src="https://static-www.elastic.co/fr/assets/blt946bc636d34a70eb/icon-logstash-bb.svg?q=600" width="144" height="144">](https://www.elastic.co/fr/products/logstash)

# How To Use

## docker engine

```
docker run -d -p 5000:5000 - p 5001:5001 shronny/logstash:latest   
```
## docker compose
its possible to establish environment with zookeeper, kafka, kafka-manager logstash and graphite.

clone the project, then run

```
deploy.sh
```
to add kafka cluster to kafka-maanger, go to http://localhost:9000, add cluster, zookeeper host is zookeeper:2181

### [File Descriptors and MMap](https://www.elastic.co/guide/en/elasticsearch/guide/current/_file_descriptors_and_mmap.html)

run the following command on your host:
```
sysctl -w vm.max_map_count=262144
```
You can set it permanently by modifying `vm.max_map_count` setting in your `/etc/sysctl.conf`.

# Environment Variables

##### HEAP_SIZE | `1g`
Defines the maximum memory allocated to logstash.

##### ORDERS_KAFKA_HOST | `Orders kafka host `
kafka host that handle topic orders hostname.

##### SPLIT_KAFKA_HOST | `Split topics  kafka host `
kafka host that handle splitter topics.

##### KAFKA_PORT | `9092`
kafka port.

# Splitter config

```
#########
# INPUT #
#########
input {
  # for testing its possible to add line to this specific file
  file {
    path => "/tmp/input.data"
    start_position => "beginning"
    type => "Orders"
    sincedb_path => "/tmp/files/sincedb.log"
  }
  # This consumenr set to get the data from the main topic  - orders
  kafka {
        topics => "orders"
        type => "items"
        #should come from system variable
        bootstrap_servers => "${ORDERS_KAFKA_HOST}:${ORDERS_KAFKA_PORT}"
  }
}

##########
# Filter #
##########
filter {
  if [type] == "items" {
  # match condition, to aviod messages from different piplines
    json {
        source => message
          }
    }
}

##########
# Output #
##########
output {
  # this configuration is for debuging, this will take the data from the input file and insert it to Orders topic
  if [type] == "Orders" {
      # match condition, to aviod messages from different piplines
    kafka {
        topic_id => "orders"
        #should come from system variable
        bootstrap_servers => "${ORDERS_KAFKA_HOST}:${ORDERS_KAFKA_PORT}"
        }
  }
  if [type] == "items" {
      # match condition, to aviod messages from different piplines
    kafka {
        topic_id => "%{[mid]}"
        #should come from system variable
        bootstrap_servers => "${SPLIT_KAFKA_HOST}:${SPLIT_KAFKA_PORT}"
        }

  } 
}
```

# Configure Logstash

Configuration file is located in `/etc/logstash/splitter.conf` if you follow the same volume mapping as in docker-compose examples above.

You can find default config [there](https://github.com/Khezen/docker-logstash/blob/master/config/logstash.conf).

*NOTE*: It is possible to use [environment variables in logstash.conf](https://www.elastic.co/guide/en/logstash/current/environment-variables.html).

You can find help with logstash configuration [there](https://www.elastic.co/guide/en/logstash/current/configuration.html).

# User Feedback
## Issues
If you have any problems with or questions about this image, please ask for help through a [GitHub issue](https://github.com/shronny/docker-logstash/issues).
