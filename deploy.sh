#!/bin/bash
echo "Streaming ETL"

docker-compose up -d

sleep 30s

docker run --name=kafka-ui --network=streaming-etl-pipeline-for-realtime-analytics_webproxy -p 9099:8080 -e KAFKA_CLUSTERS_0_NAME=local -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka:9092 -d provectuslabs/kafka-ui:latest

sleep 30s

docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'

docker exec -it ksqldb-cli ksql http://ksqldb-server:8088

echo "DONE"
