## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

<details open="open">
	<ul>
		<li><a href="#prerequisites">Prerequisites</a></li>
	</ul>
</details>

### Prerequisites

*	[Docker](https://docs.docker.com/)

*	You need to have **MySQL** installed on your machine. Using the `MySQL Workbench` or on any other MySQL client/console, create a database/schema named `streaming_etl_db`. 

~~~sql
-- create schema
CREATE SCHEMA streaming_etl_db;

-- use schema
USE streaming_etl_db;

-- Create user 
create user 'streaming_etl_db'@'localhost' identified by 'streaming_etl_db';

-- Grant privileges to user
grant all privileges on *.* to 'streaming_etl_db'@'localhost' with grant option;
~~~
