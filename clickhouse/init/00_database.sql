-- Runs once, on the first start of the clickhouse container.
-- The Kafka engine tables are created by hand in step 05 (documentation/ClickHouse.MD),
-- after ksqlDB has created the person_address_enriched topic.
CREATE DATABASE IF NOT EXISTS KafkaEngine;
