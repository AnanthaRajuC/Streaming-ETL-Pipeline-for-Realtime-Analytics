-- Runs once, on the first start of the mysql container (empty data volume).
-- Mirrors documentation/INITIAL_MYSQL_PREPARATION.MD.
USE streaming_etl_db;

CREATE TABLE `geo` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID for each entry.',
  `uuid` VARCHAR(50) DEFAULT (uuid()),
  `created_date_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Field representing the date the entity containing the field was created.',
  `last_modified_date_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `lat` varchar(255) DEFAULT NULL,
  `lng` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='Application Log.';

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
