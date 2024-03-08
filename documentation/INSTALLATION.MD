## Installation

These instructions will provide you with the installation information necessary to run the repository on your local machine for development and testing purposes.

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

*	You need to have **MySQL** database installed on your machine.

~~~shell
mysql --version
~~~

*   `MySQL Workbench` or on any other MySQL database client/console.  

## Configuration

*/etc/mysql/mysql.conf.d/*

*	**mysql.cnf** MySQL database configuration

~~~txt
[mysqld]
server-id         = 223344
log_bin           = mysql-bin
expire_logs_days  = 1
binlog_format     = row
~~~