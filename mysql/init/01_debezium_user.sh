#!/bin/bash
# Dedicated CDC user for the Debezium MySQL connector (see debeziumConfig.json).
# Its password comes from DEBEZIUM_DB_PASSWORD in .env.
set -euo pipefail

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
CREATE USER 'debezium'@'%' IDENTIFIED WITH mysql_native_password BY '${DEBEZIUM_DB_PASSWORD}';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'debezium'@'%';
FLUSH PRIVILEGES;
SQL
