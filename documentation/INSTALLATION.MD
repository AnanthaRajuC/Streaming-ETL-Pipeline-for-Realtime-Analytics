## Installation

These instructions will provide you with the installation information necessary to run the repository on your local machine for development and testing purposes.

<details open="open">
	<ul>
		<li><a href="#softwares">Softwares</a></li>
		<li><a href="#configuration">Configuration</a></li>
	</ul>
</details>

## Softwares

*	[Docker](https://docs.docker.com/)

*	You need to have **MySQL** database installed on your machine.

*   `MySQL Workbench` or on any other MySQL database client/console.  

## Configuration

*	**mysql.cnf** MySQL database configuration

~~~txt
[mysqld]
server-id         = 223344
log_bin           = mysql-bin
expire_logs_days  = 1
binlog_format     = row
~~~