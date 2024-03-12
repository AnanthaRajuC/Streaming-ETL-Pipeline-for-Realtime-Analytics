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
    "transforms": "unwrap",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "key.converter":"org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "false",
    "value.converter":"org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false"
  }
}'






Use KafkaEngine;
show tables;

-- First, we will define the target MergeTree table.

CREATE TABLE geo (
  id String,
  uuid String,
  created_date_time String,
  last_modified_date_time String,
  lat String,
  lng String
) ENGINE = MergeTree 
ORDER BY (id);

-- drop table geo
-- drop table geo_queue

-- create a table using the Kafka engine to connect to the topic and read data.

CREATE TABLE geo_queue (
    id String,
    uuid String,
    created_date_time String,
    last_modified_date_time String,
    lat String,
    lng String
)
ENGINE = Kafka
SETTINGS kafka_broker_list = 'localhost:29092',
       kafka_topic_list = 'dbserver.streaming_etl_db.geo',
       kafka_group_name = 'streaming_etl_db_consumer_group1',
       kafka_format = 'JSONEachRow',
       kafka_max_block_size = 1048576;

-- Finally, we create a materialized view to transfer data between Kafka and the merge tree table.

CREATE MATERIALIZED VIEW geo_queue_mv TO geo AS
SELECT id, uuid, created_date_time, last_modified_date_time, lat, lng
FROM geo_queue;

drop view geo_queue_mv

SELECT *
FROM KafkaEngine.geo;








































-- 1. First, we will define the target MergeTree table.

CREATE TABLE KafkaEngine.person_address_enriched (
  P_ID String,
  FIRST_NAME String,
  CITY String
) ENGINE = MergeTree 
ORDER BY (P_ID);

-- 2. create a table using the Kafka engine to connect to the topic and read data.

CREATE TABLE KafkaEngine.person_address_enriched_queue (
  P_ID String,
  FIRST_NAME String,
  CITY String
)
ENGINE = Kafka
SETTINGS kafka_broker_list = 'localhost:29092',
       kafka_topic_list = 'person_address_enriched',
       kafka_group_name = 'streaming_etl_db_consumer_group1',
       kafka_format = 'JSONEachRow',
       kafka_max_block_size = 1048576;

-- 3. Finally, we create a materialized view to transfer data between Kafka and the merge tree table.

CREATE MATERIALIZED VIEW KafkaEngine.person_address_enriched_queue_mv TO KafkaEngine.person_address_enriched AS
SELECT 
  P_ID,
  FIRST_NAME,
  CITY
FROM KafkaEngine.person_address_enriched_queue;

SELECT *
FROM KafkaEngine.person_address_enriched;
















