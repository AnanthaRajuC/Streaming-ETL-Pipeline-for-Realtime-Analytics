## Technology Stack

<details open="open">
	<ul>
		<li><a href="#stream">Stream</a></li>
		<li><a href="#data">Data</a></li>
		<li><a href="#change-data-capture">Change Data Capture</a></li>
		<li><a href="#client---cli-ui">Client - CLI/UI</a></li>
	</ul>
</details>

### Stream

|                 Technology                                         |                              Description                                                                                                                                                         |
|--------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|<a href="https://kafka.apache.org/">Apache Kafka</a>                |Open-source distributed event streaming platform                                                                                                                                                  |
|<a href="https://zookeeper.apache.org/">Apache ZooKeeper</a>        |Centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services                                                        |
|<a href="https://github.com/confluentinc/schema-registry">Confluent Schema Registry</a>|Confluent Schema Registry provides a serving layer for your metadata. It provides a RESTful interface for storing and retrieving your Avro®, JSON Schema, and Protobuf schemas.|

### Data

|                 Technology                                  |                              Description                                           |
|-------------------------------------------------------------|------------------------------------------------------------------------------------|
|<a href="https://www.mysql.com/">MySQL</a>                   |Open-Source Relational Database Management System                                   |
|<a href="https://clickhouse.com/">ClickHouse</a>             |Open-source database for real-time apps and analytics.                              |
|<a href="https://ksqldb.io/">ksqlDB</a>                      |Database purpose-built for stream processing applications on top of Apache Kafka    |

### Change Data Capture

|                 Technology                                  |                              Description                        |
|-------------------------------------------------------------|-----------------------------------------------------------------|
|<a href="https://debezium.io/">Debezium</a>                  |Stream changes from your database                                |

### Client - CLI/UI

|                 Technology                                                                             |       Description                                          |
|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------|
|<a href="https://github.com/provectus/kafka-ui">kafka-ui</a>                                            |Open-Source Web UI for Apache Kafka Management              |
|<a href="https://debezium.io/documentation/reference/stable/operations/debezium-ui.html">Debezium UI</a>|Interactive UI to set up and operate connectors more easily.|
|<a href="https://docs.ksqldb.io/en/latest/operate-and-deploy/installation/cli-config/">ksqlDB CLI</a>   |Interactive CLI to connect to ksqlDB                        |