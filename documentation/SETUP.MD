These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

<details open="open">
	<ul>
		<li><a href="#prerequisites">Prerequisites</a></li>
		<li><a href="#setup">Setup</a></li>
	</ul>
</details>

## Prerequisites

*	[Docker](https://docs.docker.com/)

*	You need to have **MySQL** installed on your machine. Using the `MySQL Workbench` or on any other MySQL client/console, create a database/schema named `streaming_etl_db`. 

*	**mysql.cnf** MySQL database configuration

~~~txt
[mysqld]
server-id         = 223344
log_bin           = mysql-bin
expire_logs_days  = 1
binlog_format     = row
~~~

## Setup

1. Clone the repository

~~~shell
git clone https://github.com/AnanthaRajuC/Streaming_ETL_pipeline_MySQL.git
cd Streaming_ETL_pipeline_MySQL
~~~

2. Start up the environment

The first time that you do this, the Docker images will be pulled down from the remote server. This may take a while!_

~~~shell
docker-compose up
~~~

3. Launch the KSQL CLI in another terminal window.

~~~shell
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
~~~