#### Debezium Registration

~~~shell
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" 127.0.0.1:8083/connectors/ -d @connector.json
~~~

or

~~~shell
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" 127.0.0.1:8083/connectors/ -d '{
  "name": "streaming_ETL_pipeline_MySQL-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "database.hostname": "172.17.0.1",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "Debezium@123#",
    "database.server.name": "mysql",
	"database.server.id": "223344",
    "database.include.list": "streaming_etl_db",
	"database.allowPublicKeyRetrieval": true,
	"database.history.kafka.bootstrap.servers": "kafka:9092",
	"database.history.kafka.topic": "mysql-streaming_etl_db-person",
	"schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
    "schema.history.internal.kafka.topic": "schema-changes.streaming_etl_db",
	"time.precision.mode": "connect",
    "include.schema.changes": false,
	"topic.prefix": "dbserver",
    "transforms": "unwrap,dropTopicPrefix",
	"transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
	"transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
	"transforms.dropTopicPrefix.regex":"asgard.demo.(.*)",
	"transforms.dropTopicPrefix.replacement":"$1",
	"key.converter":"org.apache.kafka.connect.json.JsonConverter",
	"key.converter.schemas.enable": "false",
	"value.converter":"org.apache.kafka.connect.json.JsonConverter",
	"value.converter.schemas.enable": "false"
  }
}'
~~~

![debezium-registration](images/01-debezium-registration.png)

#### Post Debezium registration.

[http://localhost:8083/connectors?expand=info&expand=status](http://localhost:8083/connectors?expand=info&expand=status)  

![connectors](images/02-debezium-connectors.png)

~~~json
{
  "streaming_ETL_pipeline_MySQL-connector": {
    "info": {
      "name": "streaming_ETL_pipeline_MySQL-connector",
      "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.history.kafka.topic": "mysql-streaming_etl_db-person",
        "transforms": "unwrap,dropTopicPrefix",
        "transforms.dropTopicPrefix.regex": "asgard.demo.(.*)",
        "include.schema.changes": "false",
        "transforms.dropTopicPrefix.replacement": "$1",
        "topic.prefix": "dbserver",
        "schema.history.internal.kafka.topic": "schema-changes.streaming_etl_db",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "database.allowPublicKeyRetrieval": "true",
        "database.user": "debezium",
        "database.server.id": "223344",
        "database.history.kafka.bootstrap.servers": "kafka:9092",
        "time.precision.mode": "connect",
        "database.server.name": "mysql",
        "schema.history.internal.kafka.bootstrap.servers": "kafka:9092",
        "database.port": "3306",
        "key.converter.schemas.enable": "false",
        "database.hostname": "172.17.0.1",
        "database.password": "Debezium@123#",
        "value.converter.schemas.enable": "false",
        "name": "streaming_ETL_pipeline_MySQL-connector",
        "transforms.dropTopicPrefix.type": "org.apache.kafka.connect.transforms.RegexRouter",
        "database.include.list": "streaming_etl_db"
      },
      "tasks": [
        {
          "connector": "streaming_ETL_pipeline_MySQL-connector",
          "task": 0
        }
      ],
      "type": "source"
    },
    "status": {
      "name": "streaming_ETL_pipeline_MySQL-connector",
      "connector": {
        "state": "RUNNING",
        "worker_id": "172.24.0.5:8083"
      },
      "tasks": [
        {
          "id": 0,
          "state": "RUNNING",
          "worker_id": "172.24.0.5:8083"
        }
      ],
      "type": "source"
    }
  }
}
~~~

[http://localhost:8083/connectors/streaming_ETL_pipeline_MySQL-connector/status](http://localhost:8083/connectors/streaming_ETL_pipeline_MySQL-connector/status) 

![connector-status](images/03-debezium-connector-status.png)

~~~json
{
  "name": "streaming_ETL_pipeline_MySQL-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "172.24.0.5:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "172.24.0.5:8083"
    }
  ],
  "type": "source"
}
~~~

#### Debezium UI

![debezium-ui](images/debezium_ui.png)

#### Kafka UI

[http://localhost:8080](http://localhost:8080)  

![Kafka UI after Debezium Registration](images/05-kafka-topics-after-registration.png)   

#### Person Topic

![Person Topic](images/06-kafka-topic-message.png)  
