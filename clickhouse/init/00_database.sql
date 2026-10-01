-- Runs once, on the first start of the clickhouse container.
-- See documentation/ClickHouse.MD for how these tables fit together.
CREATE DATABASE IF NOT EXISTS KafkaEngine;

-- Latest state of every person. ksqlDB emits a new message each time a
-- person, their address or its geo row changes, so the same P_ID arrives
-- many times. ReplacingMergeTree keeps the row with the highest VERSION
-- (the Kafka offset) per P_ID, and drops rows whose latest version has
-- IS_DELETED = 1. Query it with FINAL to get exact results before
-- background merges have run.
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

-- Kafka consumer for the ksqlDB output topic. Never SELECT from this
-- table directly: reading it consumes the messages.
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

-- Moves each consumed message into the ReplacingMergeTree table, turning
-- epoch-millisecond timestamps into DateTime64 and using the Kafka
-- offset as the row version.
CREATE MATERIALIZED VIEW IF NOT EXISTS KafkaEngine.person_address_enriched_queue_mv
TO KafkaEngine.person_address_enriched AS
SELECT
  P_ID,
  FIRST_NAME,
  LAST_NAME,
  GENDER,
  AGE,
  fromUnixTimestamp64Milli(REGISTRATION) AS REGISTRATION,
  A_ID,
  CITY,
  STATE,
  ZIPCODE,
  LAT,
  LNG,
  fromUnixTimestamp64Milli(CREATED_AT) AS CREATED_AT,
  fromUnixTimestamp64Milli(UPDATED_AT) AS UPDATED_AT,
  IS_DELETED,
  _offset AS VERSION
FROM KafkaEngine.person_address_enriched_queue;
