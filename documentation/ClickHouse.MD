## ClickHouse

~~~sql
Create database KafkaEngine;
Use KafkaEngine;
show tables;
~~~

--- 

1. First, we will define the target MergeTree table.

~~~sql
CREATE TABLE KafkaEngine.person_address_enriched (
  P_ID String,
  FIRST_NAME String,
  CITY String
) ENGINE = MergeTree 
ORDER BY (P_ID);
~~~

2. create a table using the Kafka engine to connect to the topic and read data.

~~~sql
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
~~~

3. Finally, we create a materialized view to transfer data between Kafka and the merge tree table.

~~~sql
CREATE MATERIALIZED VIEW KafkaEngine.person_address_enriched_queue_mv TO KafkaEngine.person_address_enriched AS
SELECT 
  P_ID,
  FIRST_NAME,
  CITY
FROM KafkaEngine.person_address_enriched_queue;
~~~

In the data folder initiate the fake-events.py program or insert few records manually to view the data getting populated in the person_address_enriched table.

~~~sql
SELECT *
FROM KafkaEngine.person_address_enriched;
~~~

--- 

* First, we will define the target MergeTree table.

~~~sql
CREATE TABLE geo (
  id String,
  uuid String,
  created_date_time String,
  last_modified_date_time String,
  lat String,
  lng String
) ENGINE = MergeTree 
ORDER BY (id);
~~~

* create a table using the Kafka engine to connect to the topic and read data.

~~~sql
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
~~~

* Finally, we create a materialized view to transfer data between Kafka and the merge tree table.

~~~sql
CREATE MATERIALIZED VIEW geo_queue_mv TO geo AS
SELECT id, uuid, created_date_time, last_modified_date_time, lat, lng
FROM geo_queue;
~~~

* View the data

~~~sql
SELECT 
*
FROM KafkaEngine.geo;
~~~
























































