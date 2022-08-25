docker run --tty --network mysql_debezium_cdc_apache_pinot_webproxy confluentinc/cp-kafkacat kafkacat -b kafka:9092 -C -s key=s -s value=avro -r http://schema-registry:8081 -t mysql.activemq.person


docker run --tty --network streaming_etl_pipeline_mysql_webproxy confluentinc/cp-kafkacat kafkacat -b kafka:9092 -C -t person_address_enriched



https://docs.confluent.io/platform/current/app-development/kafkacat-usage.html


https://github.com/debezium/debezium-examples/tree/main/unwrap-mongodb-smt





curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" 127.0.0.1:8083/connectors/ -d '{
  "name": "jdbc-sink",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "database.hostname": "172.17.0.1",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "Debezium@123#",
    "database.server.name": "mysql",
	  "database.server.id": "223344",
    "database.include.list": "streaming_etl_db",
	"topics" : "person_address_enriched",
	"auto.create" : "true",
        "auto.evolve" : "true",
        "insert.mode" : "upsert",
		"pk.fields" : "P_ID",
	  "database.allowPublicKeyRetrieval": true,
	  "database.history.kafka.bootstrap.servers": "kafka:9092",
	  "database.history.kafka.topic": "mysql-streaming_etl_db-person",
	  "time.precision.mode": "connect",
    "include.schema.changes": false,
    "transforms": "unwrap,dropTopicPrefix",
	  "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
	  "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
	  "transforms.dropTopicPrefix.regex":"asgard.demo.(.*)",
	  "transforms.dropTopicPrefix.replacement":"$1",
	  "key.converter":"org.apache.kafka.connect.json.JsonConverter",
	  "key.converter.schemas.enable": "false",
	  "value.converter":"org.apache.kafka.connect.json.JsonConverter",
	  "value.converter.schemas.enable": "false"
  }
}'











curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" 127.0.0.1:8083/connectors/ -d '{
  "name": "jdbc-sink",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "database.hostname": "172.17.0.1",
    "database.port": "3306",
    "database.user": "debezium",
    "database.password": "Debezium@123#",
    "database.server.name": "mysql",
	  "database.server.id": "223344",
    "database.include.list": "streaming_etl_db",
	"topics" : "person_address_enriched",
	"auto.create" : "true",
        "auto.evolve" : "true",
        "insert.mode" : "upsert",
		"pk.fields" : "P_ID",
	  "database.allowPublicKeyRetrieval": true,
	  "database.history.kafka.bootstrap.servers": "kafka:9092",
	  "database.history.kafka.topic": "mysql-streaming_etl_db-person",
	  "time.precision.mode": "connect",
    "include.schema.changes": false,
    "transforms": "unwrap,dropTopicPrefix",
	  "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
	  "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
	  "transforms.dropTopicPrefix.regex":"asgard.demo.(.*)",
	  "transforms.dropTopicPrefix.replacement":"$1",
	  "key.converter":"org.apache.kafka.connect.json.JsonConverter",
	  "key.converter.schemas.enable": "false",
	  "value.converter":"org.apache.kafka.connect.json.JsonConverter",
	  "value.converter.schemas.enable": "false"
  }
}'










