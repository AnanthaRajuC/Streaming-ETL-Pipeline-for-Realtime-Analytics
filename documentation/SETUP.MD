## Setup

1. Clone the repository

~~~shell
$ git clone https://github.com/AnanthaRajuC/Streaming_ETL_pipeline_MySQL.git
$ cd Streaming_ETL_pipeline_MySQL
~~~

#### Running the application via docker compose

2. Start up the environment

The first time that you do this, the Docker images will be pulled down from the remote server. This may take a while!_

~~~shell
$ docker-compose up
~~~

~~~shell
Creating network "streaming_etl_pipeline_mysql_webproxy" with driver "bridge"
Creating zookeeper ... done
Creating kafka     ... done
Creating debezium           ... done
Creating cp-schema-registry ... done
Creating kafka-connect-01   ... done
Creating ksqldb-server      ... done
Creating ksqldb-cli         ... done
~~~

#### Accessing Kafka Topics via Kakfka-UI

3. Optionally, start [Kafka UI](https://github.com/provectus/kafka-ui), an open-source web UI for Apache Kafka Management

~~~shell
$ docker run --name=kafka-ui --network=streaming_etl_pipeline_mysql_webproxy -p 8080:8080 -e KAFKA_CLUSTERS_0_NAME=local -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka:9092 -d provectuslabs/kafka-ui:latest
~~~

URL to access Kakfka-UI console: **http://localhost:8080**  

![Kafka UI](images/04-kafka-topics-before-debezium.png) 

4. Make sure everything is up and running

~~~shell
$ docker ps
~~~

![Docker Compose Up](images/09-docker-ps.png) 

#### Accessing ksqlDb via ksqldb-cli

4. Launch the KSQL CLI in another terminal window.

~~~shell
$ docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
~~~

![ksqlDB CLI](images/10-ksql-db-initial.png) 

## Tear down the stack

~~~shell
$ docker stop kafka-ui

$ docker rm kafka-ui
~~~

~~~shell
$ docker compose-down
~~~

~~~shell
Stopping ksqldb-cli       ... done
Stopping ksqldb-server    ... done
Stopping kafka-connect-01 ... done
Stopping debezium         ... done
Stopping kafka            ... done
Stopping zookeeper        ... done
Removing ksqldb-cli         ... done
Removing ksqldb-server      ... done
Removing kafka-connect-01   ... done
Removing cp-schema-registry ... done
Removing debezium           ... done
Removing kafka              ... done
Removing zookeeper          ... done
Removing network streaming_etl_pipeline_mysql_webproxy
~~~

_If you want to preserve the state of all containers, run `docker-compose stop` instead._