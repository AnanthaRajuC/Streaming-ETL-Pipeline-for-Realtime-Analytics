## Initial MySQL Database Preparation

This section covers the setup and configuration of the MySQL source database that serves as the entry point for the streaming ETL pipeline. The database preparation involves creating the schema, configuring database users with appropriate permissions for change data capture, establishing table structures with foreign key relationships, and populating initial sample data.

<details open="open">
	<ul>
		<li><a href="#mysql">MySQL</a></li>
	</ul>
</details>

### Schema and Database Configuration

The initial setup creates the dedicated schema and verifies MySQL version compatibility:

~~~sql
-- create schema
CREATE SCHEMA streaming_etl_db;

-- use schema
USE streaming_etl_db;
~~~

**MySQL Version Verification** Before proceeding with setup, verify MySQL version compatibility using:

~~~bash
mysql --version
~~~

## Debezium User Configuration

The pipeline requires a dedicated MySQL user with specific privileges to enable change data capture functionality. The `debezium` user must have replication permissions to read the MySQL binary log.

**User Creation and Privileges**

~~~sql
-- Create user 
CREATE USER 'debezium' IDENTIFIED WITH mysql_native_password BY 'Debezium@123#';

-- Grant privileges to user
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium';

-- Reload the grant tables in the mysql database enabling the changes to take effect without reloading or restarting mysql service
FLUSH PRIVILEGES;
~~~

**Required Privileges Explained**

| Privilege             | Purpose                                   |
|------------------------|-------------------------------------------|
| `SELECT`              | Read table data for initial snapshots     |
| `RELOAD`              | Flush tables and logs during setup        |
| `SHOW DATABASES`      | List databases for connector configuration|
| `REPLICATION SLAVE`   | Read binary log entries                   |
| `REPLICATION CLIENT`  | Check replication status                  |

## Table Structure and Relationships

The database schema implements a hierarchical data model with three interconnected tables representing geographical data, address information, and person records.

**Table Definitions**

The `geo` table stores geographical coordinates and serves as the foundation of the hierarchy:

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

The `address` table contains location information with foreign key reference to `geo`:

~~~sql
CREATE TABLE `address` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID for each entry.',
  `uuid` VARCHAR(50) DEFAULT (uuid()),
  `created_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Field representing the date the entity containing the field was created.',
  `last_modified_date_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `city` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `geo_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_geo_id` (`geo_id`),
  CONSTRAINT `FKC_geo_id` FOREIGN KEY (`geo_id`) REFERENCES `geo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
~~~

The `person` table stores individual records with foreign key reference to `address`:

~~~sql
CREATE TABLE `person` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID for each entry.',
  `uuid` VARCHAR(50) DEFAULT (uuid()),
  `created_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Field representing the date the entity containing the field was created.',
  `last_modified_date_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `registration` datetime DEFAULT NULL,
  `age` int DEFAULT NULL,
  `address_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_address_id` (`address_id`),
  CONSTRAINT `FKC_address_id` FOREIGN KEY (`address_id`) REFERENCES `address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
~~~

## Data Population Strategy

The database preparation includes multiple approaches for populating initial data, from single record examples to bulk dataset loading and automated event generation.

**Sample Record Insertion**

Basic sample data can be inserted to verify table relationships:

~~~sql
INSERT INTO `streaming_etl_db`.`geo`(`lat`,`lng`)VALUES('la14','lo14');
INSERT INTO `streaming_etl_db`.`address`(`city`,`zipcode`,`state`,`geo_id`)VALUES('c14','z14','s14',1);
INSERT INTO `streaming_etl_db`.`person`(`first_name`,`last_name`,`email`,`gender`,`registration`,`age`,`address_id`)VALUES('fn14','ln14','example@domain.com','M',now(),34,1);
~~~

## Bulk Data Loading Sequence

The data files in the `/data/` directory must be executed in the correct order to maintain referential integrity:

**Loading Order**:

- **1_geo.sql** - Creates 50 geographical coordinate records
- **2_address.sql** - Creates 50 address records with `geo_id` foreign keys
- **3_person.sql** - Creates 50 person records with `address_id` foreign keys

## Automated Event Generation

For continuous testing and demonstration purposes, the system includes a Python-based event generator:

**Event Generator Location**: `/data/fake-events.py`

This script generates ongoing database changes to simulate real-world operational data modifications, enabling demonstration of the streaming ETL pipeline's change data capture capabilities.

## Data Verification and Testing

**Basic Data Queries**: Basic Data Queries

~~~sql
-- Individual table verification
SELECT * FROM streaming_etl_db.person;
SELECT * FROM streaming_etl_db.address;
SELECT * FROM streaming_etl_db.geo;
~~~

**Relationship Verification Query**: Confirm foreign key relationships and data integrity:

~~~sql
SELECT * 
FROM streaming_etl_db.person p
LEFT JOIN streaming_etl_db.address a on a.id = p.address_id
LEFT JOIN streaming_etl_db.geo g on g.id = a.geo_id;
~~~

This query performs the same JOIN operations that will be replicated in the ksqlDB stream processing layer, making it useful for validating expected results.

## Integration with Debezium Configuration

The prepared database connects to the Debezium MySQL connector through specific configuration parameters that reference the database setup:

**Connection Parameters**

| Parameter               | Value             | Purpose                         |
|-------------------------|-------------------|----------------------------------|
| `database.hostname`     | 172.17.0.1        | MySQL host address              |
| `database.port`         | 3306              | MySQL port                      |
| `database.user`         | debezium          | User created in preparation     |
| `database.password`     | Debezium@123#     | User password                   |
| `database.include.list` | streaming_etl_db  | Target schema                   |
| `topic.prefix`          | dbserver          | Kafka topic prefix              |

The connector creates Kafka topics with the naming pattern: **dbserver.streaming_etl_db.{table_name}**

**Generated Topics**:

- `dbserver.streaming_etl_db.geo `
- `dbserver.streaming_etl_db.address`  
- `dbserver.streaming_etl_db.person`  