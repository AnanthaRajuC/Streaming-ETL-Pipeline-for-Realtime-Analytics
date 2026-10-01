-- ksqlDB objects for the pipeline. Run automatically by the ksqldb-init
-- service in docker-compose.yaml; every statement is safe to re-run.
--
-- Each CDC topic is read as a TABLE keyed by the row's primary key, so
-- ksqlDB always holds the latest version of every row. Foreign-key
-- table-table joins then re-emit a person whenever the person, their
-- address or the address's geo row changes, with no time window.
--
-- Deleted MySQL rows arrive as normal records with __deleted = 'true'
-- (Debezium's delete.tombstone.handling.mode=rewrite) and are passed
-- through as IS_DELETED, so ClickHouse can drop them.

SET 'auto.offset.reset' = 'earliest';

CREATE TABLE IF NOT EXISTS GEO (
    ID BIGINT PRIMARY KEY,
    UUID VARCHAR,
    CREATED_DATE_TIME TIMESTAMP,
    LAST_MODIFIED_DATE_TIME TIMESTAMP,
    LAT VARCHAR,
    LNG VARCHAR,
    `__deleted` VARCHAR
) WITH (
    KAFKA_TOPIC = 'dbserver.streaming_etl_db.geo',
    KEY_FORMAT = 'JSON',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 1
);

CREATE TABLE IF NOT EXISTS ADDRESS (
    ID BIGINT PRIMARY KEY,
    UUID VARCHAR,
    CREATED_DATE_TIME TIMESTAMP,
    LAST_MODIFIED_DATE_TIME TIMESTAMP,
    CITY VARCHAR,
    ZIPCODE VARCHAR,
    STATE VARCHAR,
    GEO_ID BIGINT,
    `__deleted` VARCHAR
) WITH (
    KAFKA_TOPIC = 'dbserver.streaming_etl_db.address',
    KEY_FORMAT = 'JSON',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 1
);

CREATE TABLE IF NOT EXISTS PERSON (
    ID BIGINT PRIMARY KEY,
    UUID VARCHAR,
    CREATED_DATE_TIME TIMESTAMP,
    LAST_MODIFIED_DATE_TIME TIMESTAMP,
    FIRST_NAME VARCHAR,
    LAST_NAME VARCHAR,
    EMAIL VARCHAR,
    GENDER VARCHAR,
    REGISTRATION TIMESTAMP,
    AGE INT,
    ADDRESS_ID BIGINT,
    `__deleted` VARCHAR
) WITH (
    KAFKA_TOPIC = 'dbserver.streaming_etl_db.person',
    KEY_FORMAT = 'JSON',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 1
);

-- Address enriched with its coordinates, keyed by address ID.
CREATE TABLE IF NOT EXISTS ADDRESS_GEO WITH (
    KAFKA_TOPIC = 'address_geo',
    KEY_FORMAT = 'JSON',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 1
) AS
SELECT
    A.ID AS A_ID,
    A.CITY AS CITY,
    A.STATE AS STATE,
    A.ZIPCODE AS ZIPCODE,
    CAST(G.LAT AS DOUBLE) AS LAT,
    CAST(G.LNG AS DOUBLE) AS LNG
FROM ADDRESS A
LEFT JOIN GEO G ON A.GEO_ID = G.ID
EMIT CHANGES;

-- One row per person with their current address and coordinates.
-- AS_VALUE copies the key into the message value, which is all the
-- ClickHouse Kafka engine reads.
CREATE TABLE IF NOT EXISTS PERSON_ADDRESS_ENRICHED WITH (
    KAFKA_TOPIC = 'person_address_enriched',
    KEY_FORMAT = 'JSON',
    VALUE_FORMAT = 'JSON',
    PARTITIONS = 1
) AS
SELECT
    P.ID AS PERSON_KEY,
    AS_VALUE(P.ID) AS P_ID,
    P.FIRST_NAME AS FIRST_NAME,
    P.LAST_NAME AS LAST_NAME,
    P.GENDER AS GENDER,
    P.AGE AS AGE,
    P.REGISTRATION AS REGISTRATION,
    P.ADDRESS_ID AS A_ID,
    AG.CITY AS CITY,
    AG.STATE AS STATE,
    AG.ZIPCODE AS ZIPCODE,
    AG.LAT AS LAT,
    AG.LNG AS LNG,
    P.CREATED_DATE_TIME AS CREATED_AT,
    P.LAST_MODIFIED_DATE_TIME AS UPDATED_AT,
    CASE WHEN P.`__deleted` = 'true' THEN 1 ELSE 0 END AS IS_DELETED
FROM PERSON P
LEFT JOIN ADDRESS_GEO AG ON P.ADDRESS_ID = AG.A_ID
EMIT CHANGES;
