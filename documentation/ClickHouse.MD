## ClickHouse Analytics Integration

**Purpose and Scope**

This document describes ClickHouse, the analytics database at the end of the streaming ETL pipeline. ClickHouse consumes the `person_address_enriched` topic produced by ksqlDB and keeps the current state of every person for fast analytical queries.

## Setup

ClickHouse runs as the `clickhouse` service in `docker-compose.yaml` (HTTP on `localhost:8123`, native protocol on `localhost:9000`; user and password are `CLICKHOUSE_USER` and `CLICKHOUSE_PASSWORD` in `.env`). On first start, [`clickhouse/init/00_database.sql`](../clickhouse/init/00_database.sql) creates the `KafkaEngine` database and the three objects below, so no manual steps are needed.

Open a client with:

~~~shell
docker exec -it clickhouse sh -c 'clickhouse-client --password "$CLICKHOUSE_PASSWORD"'
~~~

~~~sql
USE KafkaEngine;
SHOW TABLES;
~~~

## How Data Flows In

~~~
person_address_enriched (Kafka topic)
  -> person_address_enriched_queue     Kafka engine table: consumes the topic
  -> person_address_enriched_queue_mv  materialized view: converts and copies each message
  -> person_address_enriched           ReplacingMergeTree table: latest version per person
~~~

ksqlDB emits a new message for a person every time the person, their address or its coordinates change, and when the person is deleted. The target table therefore receives several versions of the same `P_ID`, and needs to keep only the newest one.

### 1. Target table: ReplacingMergeTree

~~~sql
CREATE TABLE IF NOT EXISTS KafkaEngine.person_address_enriched (
  P_ID Int64,
  FIRST_NAME Nullable(String),
  LAST_NAME Nullable(String),
  GENDER Nullable(String),
  AGE Nullable(Int32),
  REGISTRATION Nullable(DateTime64(3)),
  A_ID Nullable(Int64),
  CITY Nullable(String),
  STATE Nullable(String),
  ZIPCODE Nullable(String),
  LAT Nullable(Float64),
  LNG Nullable(Float64),
  CREATED_AT Nullable(DateTime64(3)),
  UPDATED_AT Nullable(DateTime64(3)),
  IS_DELETED UInt8,
  VERSION UInt64
) ENGINE = ReplacingMergeTree(VERSION, IS_DELETED)
ORDER BY (P_ID);
~~~

| Setting          | Purpose                                                                                     |
|------------------|---------------------------------------------------------------------------------------------|
| `ORDER BY (P_ID)`| Rows with the same `P_ID` are versions of the same person                                   |
| `VERSION`        | The Kafka offset of the message; the highest one wins                                       |
| `IS_DELETED`     | When the winning version has `IS_DELETED = 1`, the person is removed                        |

### 2. Kafka engine table

~~~sql
CREATE TABLE IF NOT EXISTS KafkaEngine.person_address_enriched_queue (
  P_ID Int64,
  FIRST_NAME Nullable(String),
  LAST_NAME Nullable(String),
  GENDER Nullable(String),
  AGE Nullable(Int32),
  REGISTRATION Nullable(Int64),
  A_ID Nullable(Int64),
  CITY Nullable(String),
  STATE Nullable(String),
  ZIPCODE Nullable(String),
  LAT Nullable(Float64),
  LNG Nullable(Float64),
  CREATED_AT Nullable(Int64),
  UPDATED_AT Nullable(Int64),
  IS_DELETED UInt8
)
ENGINE = Kafka
SETTINGS kafka_broker_list = 'kafka:9092',
       kafka_topic_list = 'person_address_enriched',
       kafka_group_name = 'streaming_etl_db_consumer_group1',
       kafka_format = 'JSONEachRow',
       kafka_max_block_size = 1048576;
~~~

ClickHouse is on the same Docker network as Kafka, so it uses the internal listener `kafka:9092`. Never `SELECT` from this table directly: reading a Kafka engine table consumes the messages, and the materialized view would miss them.

### 3. Materialized view

~~~sql
CREATE MATERIALIZED VIEW IF NOT EXISTS KafkaEngine.person_address_enriched_queue_mv
TO KafkaEngine.person_address_enriched AS
SELECT
  P_ID, FIRST_NAME, LAST_NAME, GENDER, AGE,
  fromUnixTimestamp64Milli(REGISTRATION) AS REGISTRATION,
  A_ID, CITY, STATE, ZIPCODE, LAT, LNG,
  fromUnixTimestamp64Milli(CREATED_AT) AS CREATED_AT,
  fromUnixTimestamp64Milli(UPDATED_AT) AS UPDATED_AT,
  IS_DELETED,
  _offset AS VERSION
FROM KafkaEngine.person_address_enriched_queue;
~~~

It converts ksqlDB's epoch-millisecond timestamps to `DateTime64(3)` and uses the Kafka engine's `_offset` virtual column as the row version.

## Querying

ReplacingMergeTree removes old versions during background merges, at an unpredictable time. Add `FINAL` to get exact results at any moment. It removes old versions and deleted people at query time:

~~~sql
-- Current people
SELECT * FROM KafkaEngine.person_address_enriched FINAL;

-- Top cities right now
SELECT CITY, count() AS people
FROM KafkaEngine.person_address_enriched FINAL
GROUP BY CITY
ORDER BY people DESC
LIMIT 5;
~~~

Without `FINAL`, the same person can appear several times:

~~~sql
SELECT count() AS raw_rows, uniqExact(P_ID) AS people
FROM KafkaEngine.person_address_enriched;
~~~

The dbt model `person_current` wraps the `FINAL` query in a view; see [dbt](DBT.MD).

## Trying It Out

Run `python data/fake-events.py` (it mixes inserts, updates, address changes and deletes) or change rows by hand, and watch the results update within a few seconds:

~~~shell
docker exec -i mysql sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" mysql -u"$MYSQL_USER" streaming_etl_db' -e "
  UPDATE person  SET first_name = 'Renamed' WHERE id = 1;
  UPDATE address SET city = 'NewCity'       WHERE id = 2;
  DELETE FROM person                        WHERE id = 5;"
~~~

~~~sql
SELECT P_ID, FIRST_NAME, CITY
FROM KafkaEngine.person_address_enriched FINAL
WHERE P_ID IN (1, 2, 5);
-- 1  Renamed  Sacramento
-- 2  Stacey   NewCity
-- (person 5 is gone)
~~~
