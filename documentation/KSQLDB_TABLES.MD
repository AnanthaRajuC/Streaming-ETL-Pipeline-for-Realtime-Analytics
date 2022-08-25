### Accessing ksqlDb via ksqldb-cli

### ksqlDB

*   Check topics, streams and tables

~~~sql
show topics;
show streams;
show tables;
~~~

### Tables

*	Declare Tables

~~~sql
CREATE TABLE PERSON (id bigint PRIMARY KEY,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,name VARCHAR,username VARCHAR,address_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.person',VALUE_FORMAT='JSON');

CREATE TABLE ADDRESS (id bigint PRIMARY KEY,uuid VARCHAR,created_date_time TIMESTAMP,last_modified_date_time TIMESTAMP,city VARCHAR,street VARCHAR,suite VARCHAR,zipcode VARCHAR,geo_id bigint) WITH (KAFKA_TOPIC='mysql.streaming_etl_db.address',VALUE_FORMAT='JSON');
~~~

~~~sql
SELECT * FROM PERSON EMIT CHANGES LIMIT 1;

SELECT * FROM ADDRESS EMIT CHANGES LIMIT 1;
~~~

Joins

~~~sql
SELECT 
	P.NAME,
	A.CITY
FROM PERSON P
LEFT JOIN ADDRESS A on A.id = P.address_id
EMIT CHANGES 
LIMIT 1;
~~~

~~~sql
SELECT 
  P.NAME, 
  A.CITY
FROM PERSON P
INNER JOIN ADDRESS A
ON A.id = P.address_id
EMIT CHANGES
LIMIT 1;
~~~

~~~sql
CREATE TABLE PERSON_ADDRESS_ENRICHED (P_ID bigint,A_ID bigint,NAME VARCHAR,CITY VARCHAR) WITH (KAFKA_TOPIC='person_address_enriched',VALUE_FORMAT='JSON');
~~~

*	Others

~~~sql
DROP TABLE IF EXISTS PERSON;
~~~


