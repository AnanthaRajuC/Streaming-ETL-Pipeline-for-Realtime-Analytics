## Installation

These instructions will provide you with the installation information necessary to run the repository on your local machine for development and testing purposes.

This project should work for any type of installation, but you’ll need to change host names accordingly. 

<details open="open">
	<ul>
		<li><a href="#softwares">Softwares</a></li>
		<li><a href="#configuration">Configuration</a></li>
	</ul>
</details>

## Linux Commands (Optional)

~~~shell
$ docker system info | grep Memory
~~~

*In case of permission issue*

~~~shell
sudo chmod 777 /var/run/docker.sock
~~~

## Softwares

*	[Docker](https://docs.docker.com/)

~~~shell
docker --version
~~~

*	[Docker Compose](https://docs.docker.com/compose/)

~~~shell
docker-compose --version
~~~

*	[MySQL](https://www.mysql.com/)

~~~shell
mysql --version
~~~

*	[ClickHouse](https://clickhouse.com/) 

*   `MySQL Workbench` or any other MySQL database client/console.  
*   [DBeaver Community](https://dbeaver.io/) or any other ClickHouse database client/console.  

## MySQL Configuration

*/etc/mysql/mysql.conf.d/*

*	**mysql.cnf** MySQL database configuration

~~~txt
[mysqld]
server-id         = 223344
log_bin           = mysql-bin
expire_logs_days  = 1
binlog_format     = row
~~~