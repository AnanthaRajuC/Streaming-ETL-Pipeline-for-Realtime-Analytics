## DBT

dbt init rta  

cd rta  

touch profiles.yml  

dbt debug  

dbt docs generate  

dbt docs serve --port 8001    

cd models  

mkdir KafkaEngine

cd KafkaEngine  

touch rta_initial.sql   

cd ..

cd ..  

dbt build  













