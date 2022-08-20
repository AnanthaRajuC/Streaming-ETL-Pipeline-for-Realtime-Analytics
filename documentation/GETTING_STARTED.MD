## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

<details open="open">
	<ul>
		<li><a href="#mysql">MySQL</a></li>
		<li><a href="#ksqldb">ksqlDB</a></li>
	</ul>
</details>

### MySQL

~~~sql
-- create schema
CREATE SCHEMA streaming_etl_db;

-- use schema
USE streaming_etl_db;

-- Create user 
CREATE USER 'debezium' IDENTIFIED WITH mysql_native_password BY 'Debezium@123#';

-- Grant privileges to user
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium';

-- Reload the grant tables in the mysql database enabling the changes to take effect without reloading or restarting mysql service
FLUSH PRIVILEGES;
~~~

*	Tables

~~~sql
CREATE TABLE `geo` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID for each entry.',
  `uuid` VARCHAR(50) DEFAULT (uuid()),
  `created_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Field representing the date the entity containing the field was created.',
  `last_modified_date_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `lat` varchar(255) DEFAULT NULL,
  `lng` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='Application Log.';
~~~

~~~sql
CREATE TABLE `address` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID for each entry.',
  `uuid` VARCHAR(50) DEFAULT (uuid()),
  `created_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Field representing the date the entity containing the field was created.',
  `last_modified_date_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `city` varchar(255) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `suite` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `geo_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_geo_id` (`geo_id`),
  CONSTRAINT `FKC_geo_id` FOREIGN KEY (`geo_id`) REFERENCES `geo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
~~~

~~~sql
CREATE TABLE `person` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID for each entry.',
  `uuid` VARCHAR(50) DEFAULT (uuid()),
  `created_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Field representing the date the entity containing the field was created.',
  `last_modified_date_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `address_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_address_id` (`address_id`),
  CONSTRAINT `FKC_address_id` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
~~~

*	Sample Data

~~~sql
INSERT INTO `streaming_etl_db`.`geo`(`lat`,`lng`)VALUES('la14','lo14');
INSERT INTO `streaming_etl_db`.`address`(`city`,`street`,`suite`,`zipcode`,`geo_id`)VALUES('c14','s14','su14','z14',1);
INSERT INTO `streaming_etl_db`.`person`(`name`,`username`,`address_id`)VALUES('d14','dbz14','1');
~~~

*	Select Statement

~~~sql
SELECT * 
FROM streaming_etl_db.person p
LEFT JOIN streaming_etl_db.address a on a.id = p.address_id
LEFT JOIN streaming_etl_db.geo g on g.id = a.geo_id;
~~~

### ksqlDB

~~~sql

docker exec -it ksqldb-cli ksql http://ksqldb-server:8088

show topics;
show streams;
show tables;

CREATE TABLE PERSON (id bigint PRIMARY KEY,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,name VARCHAR,username VARCHAR,address_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.person',VALUE_FORMAT='JSON');

CREATE TABLE ADDRESS (id bigint PRIMARY KEY,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,city VARCHAR,street VARCHAR,suite VARCHAR,zipcode VARCHAR,geo_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.address',VALUE_FORMAT='JSON');

CREATE TABLE PERSON_ADDRESS_ENRICHED (P_ID bigint,A_ID bigint,NAME VARCHAR,CITY VARCHAR) WITH (KAFKA_TOPIC='person_address_enriched',VALUE_FORMAT='JSON');

show tables;

SELECT * FROM PERSON EMIT CHANGES LIMIT 1;
SELECT * FROM ADDRESS EMIT CHANGES LIMIT 1;

SELECT 
	P.NAME,
	A.CITY
FROM PERSON P
LEFT JOIN ADDRESS A on A.id = P.address_id
EMIT CHANGES LIMIT 1;

SELECT P.NAME, A.CITY
    FROM PERSON P
    INNER JOIN ADDRESS A
    ON A.id = P.address_id
    EMIT CHANGES
    LIMIT 1;
	
DROP TABLE IF EXISTS PERSON;

CREATE STREAM PERSON_STREAM (id bigint,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,name VARCHAR,username VARCHAR,address_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.person',VALUE_FORMAT='JSON');

CREATE STREAM ADDRESS_STREAM (id bigint,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,city VARCHAR,street VARCHAR,suite VARCHAR,zipcode VARCHAR,geo_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.address',VALUE_FORMAT='JSON');

CREATE STREAM person_address_enriched WITH (KAFKA_TOPIC = 'person_address_enriched',FORMAT='JSON') AS
SELECT
	P.ID,
	A.ID,
	P.NAME,
	A.CITY
FROM PERSON_STREAM P
LEFT OUTER JOIN ADDRESS_STREAM A on A.id = P.address_id;

CREATE STREAM PERSON_ADDRESS_ENRICHED WITH (FORMAT='JSON', KAFKA_TOPIC='person_address_enriched', PARTITIONS=1, REPLICAS=1) AS SELECT
  P.ID P_ID,
  A.ID A_ID,
  P.NAME NAME,
  A.CITY CITY
FROM PERSON_STREAM P
LEFT OUTER JOIN ADDRESS_STREAM A WITHIN 1 HOURS GRACE PERIOD 30 MINUTES ON ((A.ID = P.ADDRESS_ID))
EMIT CHANGES;

DESCRIBE PERSON_STREAM;



~~~




