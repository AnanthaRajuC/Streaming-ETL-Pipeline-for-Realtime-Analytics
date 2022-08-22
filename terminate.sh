#!/bin/bash
echo -e "Stopping Streaming ETL \n\n"

echo -e "Running containers \n\n"

docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'

echo -e "Stopping Kafka-ui \n\n"
echo -e "docker stop kafka-ui"

docker stop kafka-ui

# Wait for kafka-ui to stop
sleep 5s

echo -e "Removing Kafka-ui \n\n"
echo -e "docker rm kafka-ui"

docker rm kafka-ui

# Wait for kafka-ui to be removed
sleep 5s

echo -e  "docker-compose down \n\n"
docker-compose down

# Wait for containers to be stopped and removed
sleep 10s

echo -e "docker ps \n\n"
docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'

echo -e "docker ps -a  \n\n"
docker ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}'

echo -e "docker network ls  \n\n"
docker network ls

echo -e "docker system df  \n\n"
docker system df

echo "DONE"