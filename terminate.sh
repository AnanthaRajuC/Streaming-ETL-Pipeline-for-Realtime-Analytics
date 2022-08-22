#!/bin/bash
echo "Stopping Streaming ETL"

echo "Running containers"

docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'

echo "Stopping Kafka-ui"
echo "docker stop kafka-ui"

docker stop kafka-ui

sleep 5s

echo "Removing Kafka-ui"
echo "docker rm kafka-ui"

docker rm kafka-ui

sleep 5s

echo "docker-compose down"
docker-compose down

sleep 10s

echo "docker ps"
docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'

echo "docker ps -a"
docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'

echo "docker network ls"
docker network ls

echo "docker system df"
docker system df

echo "DONE"