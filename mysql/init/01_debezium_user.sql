-- Dedicated CDC user for the Debezium MySQL connector (see debeziumConfig.json).
CREATE USER 'debezium'@'%' IDENTIFIED WITH mysql_native_password BY 'Debezium@123#';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';
FLUSH PRIVILEGES;
