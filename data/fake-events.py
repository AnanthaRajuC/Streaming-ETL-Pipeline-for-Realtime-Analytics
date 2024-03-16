import mysql.connector
import time
import uuid
import random
from faker import Faker

# Establishing a connection to the MySQL database
db_connection = mysql.connector.connect(
    host="localhost",
    user="admin",
    password="password",
    database="streaming_etl_db"
)

# Creating a cursor object to execute SQL queries
cursor = db_connection.cursor()

# Creating a Faker object to generate fake data
fake = Faker()

# Define the number of records you want to insert
num_records = 100

# Define the time interval between each record insertion (in seconds)
time_interval = random.uniform(2, 5)

try:
    for _ in range(num_records):
        # Inserting data into geo table
        lat = fake.latitude()
        lng = fake.longitude()
        geo_insert_query = "INSERT INTO geo (uuid, lat, lng) VALUES (%s, %s, %s)"
        cursor.execute(geo_insert_query, (str(uuid.uuid4()), lat, lng))
        geo_id = cursor.lastrowid
        print("Data inserted into geo table successfully")

        # Inserting data into address table
        city = fake.city()
        zipcode = fake.zipcode()
        state = fake.state()
        address_insert_query = "INSERT INTO address (uuid, city, zipcode, state, geo_id) VALUES (%s, %s, %s, %s, %s)"
        cursor.execute(address_insert_query, (str(uuid.uuid4()), city, zipcode, state, geo_id))
        address_id = cursor.lastrowid
        print("Data inserted into address table successfully")

        # Inserting data into person table
        first_name = fake.first_name()
        last_name = fake.last_name()
        email = fake.email()
        gender = fake.random_element(elements=("Male", "Female"))
        registration = fake.date_time_this_decade()
        age = fake.random_int(min=18, max=80)
        person_insert_query = "INSERT INTO person (uuid, first_name, last_name, email, gender, registration, age, address_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
        cursor.execute(person_insert_query, (str(uuid.uuid4()), first_name, last_name, email, gender, registration, age, address_id))
        print("Data inserted into person table successfully")

        # Committing the changes after each iteration
        db_connection.commit()

        # Wait for the specified time interval
        time.sleep(time_interval)

except mysql.connector.Error as error:
    print("Error inserting data into MySQL tables:", error)

finally:
    # Closing the cursor and database connection
    if db_connection.is_connected():
        cursor.close()
        db_connection.close()
        print("MySQL connection is closed")
