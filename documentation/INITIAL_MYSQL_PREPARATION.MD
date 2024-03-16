## Initial MySQL preparation

Initial Data setup.

<details open="open">
	<ul>
		<li><a href="#mysql">MySQL</a></li>
	</ul>
</details>

### MySQL

MySQL version Check

~~~shell
mysql --version
~~~

* Declare schema, user and permissions.

~~~sql
-- create schema
CREATE SCHEMA streaming_etl_db;

-- use schema
USE streaming_etl_db;

-- Check User exists or not
SELECT * FROM mysql.user where User = 'debezium';

-- Create user 
CREATE USER 'debezium' IDENTIFIED WITH mysql_native_password BY 'Debezium@123#';

-- Grant privileges to user
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium';

-- Reload the grant tables in the mysql database enabling the changes to take effect without reloading or restarting mysql service
FLUSH PRIVILEGES;
~~~

*	Declare Tables

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
  `zipcode` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
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

*	Sample Record

~~~sql
INSERT INTO `streaming_etl_db`.`geo`(`lat`,`lng`)VALUES('la14','lo14');
INSERT INTO `streaming_etl_db`.`address`(`city`,`zipcode`,`state`,`geo_id`)VALUES('c14','z14','s14',1);
INSERT INTO `streaming_etl_db`.`person`(`first_name`,`last_name`,`email`,`gender`,`registration`,`age`,`address_id`)VALUES('fn14','ln14','example@domain.com','M',now(),34,1);
~~~

* Sample Dataset

Execute the sample files in **/data/** folder in the following order 

- 1_geo.sql  
- 2_address.sql  
- 3_person.sql  

* Sample Events generator

**/data/fake-events.py**

*	Select Statement

~~~sql
SELECT * FROM streaming_etl_db.person;
SELECT * FROM streaming_etl_db.address;
SELECT * FROM streaming_etl_db.geo;
~~~

*	Join Statement

~~~sql
SELECT * 
FROM streaming_etl_db.person p
LEFT JOIN streaming_etl_db.address a on a.id = p.address_id
LEFT JOIN streaming_etl_db.geo g on g.id = a.geo_id;
~~~
