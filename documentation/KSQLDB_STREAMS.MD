### Accessing ksqlDb via ksqldb-cli

### ksqlDB

*   Check topics, streams and tables

~~~sql
show topics;
show streams;
show tables;
~~~

### Streams

*	Declare Streams

~~~sql
SET 'auto.offset.reset' = 'earliest';
~~~

~~~sql
CREATE STREAM PERSON_STREAM (id bigint,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,name VARCHAR,username VARCHAR,address_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.person',VALUE_FORMAT='JSON');

CREATE STREAM ADDRESS_STREAM (id bigint,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,city VARCHAR,street VARCHAR,suite VARCHAR,zipcode VARCHAR,geo_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.address',VALUE_FORMAT='JSON');
~~~

~~~sql
SELECT * FROM PERSON_STREAM EMIT CHANGES LIMIT 1;

+-------------------------+-------------------------+-------------------------+-------------------------+-------------------------+-------------------------+-------------------------+
|ID                       |UUID                     |CREATED_DATE_TIME        |LAST_MODIFIED_DATE_TIME  |NAME                     |USERNAME                 |ADDRESS_ID               |
+-------------------------+-------------------------+-------------------------+-------------------------+-------------------------+-------------------------+-------------------------+
|1                        |ce8d2120-1f93-11ed-8647-0|2022-08-19T13:22:00.000  |2022-08-19T13:22:00.000  |d14                      |dbz14                    |1                        |
|                         |c9a3cfadc50              |                         |                         |                         |                         |                         |
Limit Reached
Query terminated
~~~

~~~sql
DESCRIBE PERSON_STREAM;
select * from PERSON_STREAM;
~~~

*	stream-stream join

~~~sql
CREATE STREAM PERSON_ADDRESS_ENRICHED_STREAM WITH (FORMAT='JSON', KAFKA_TOPIC='person_address_enriched', PARTITIONS=1, REPLICAS=1) AS 
SELECT
  P.ID P_ID,
  A.ID A_ID,
  P.NAME NAME,
  A.CITY CITY
FROM PERSON_STREAM P
LEFT OUTER JOIN ADDRESS_STREAM A WITHIN 1 HOURS GRACE PERIOD 30 MINUTES ON ((A.ID = P.ADDRESS_ID))
EMIT CHANGES;
~~~

### Kafka Sink MySQL DB

~~~sql
CREATE SINK CONNECTOR SINK_PERSON_ADDRESS_ENRICHED_STREAM WITH (
    'connector.class'                     = 'io.confluent.connect.jdbc.JdbcSinkConnector',
    'connection.url'                      = 'jdbc:mysql://172.17.0.1:3306/',
    'connection.user'                     = 'debezium',
    'connection.password'                 = 'Debezium@123#',
    'topics'                              = 'PERSON_ADDRESS_ENRICHED_STREAM',
    'key.converter'						            = 'org.apache.kafka.connect.json.JsonConverter',	
	  'key.converter.schemas.enable'		    = 'false',
	  'value.converter'					            = 'org.apache.kafka.connect.json.JsonConverter',
	  'value.converter.schemas.enable'      = 'false'
);
~~~
