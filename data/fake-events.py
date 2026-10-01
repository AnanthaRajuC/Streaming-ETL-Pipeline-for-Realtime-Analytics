"""Generate a stream of changes in the MySQL source database.

Each event is one of: insert a new person (with a new geo row and address),
update a person, move an address to another city, or delete a person. The
pipeline should reflect every one of them in ClickHouse and Grafana within
seconds.

Usage (from the repository root, after ./deploy.sh):

    pip install -r requirements.txt
    python data/fake-events.py                  # 100 events, 2-5 s apart
    python data/fake-events.py --events 20 --min-delay 0.5 --max-delay 1

Connection settings come from .env (MYSQL_USER, MYSQL_PASSWORD), which
./deploy.sh creates.
"""

import argparse
import os
import random
import time
import uuid
from pathlib import Path

import mysql.connector
from dotenv import load_dotenv
from faker import Faker

# Relative weights of each kind of event.
EVENT_WEIGHTS = {
    "insert": 6,
    "update_person": 2,
    "change_address": 1,
    "delete_person": 1,
}

fake = Faker()


def insert_person(cursor):
    cursor.execute(
        "INSERT INTO geo (uuid, lat, lng) VALUES (%s, %s, %s)",
        (str(uuid.uuid4()), fake.latitude(), fake.longitude()),
    )
    geo_id = cursor.lastrowid
    cursor.execute(
        "INSERT INTO address (uuid, city, zipcode, state, geo_id) VALUES (%s, %s, %s, %s, %s)",
        (str(uuid.uuid4()), fake.city(), fake.zipcode(), fake.state(), geo_id),
    )
    address_id = cursor.lastrowid
    first_name = fake.first_name()
    cursor.execute(
        "INSERT INTO person (uuid, first_name, last_name, email, gender, registration, age, address_id)"
        " VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
        (
            str(uuid.uuid4()),
            first_name,
            fake.last_name(),
            fake.email(),
            fake.random_element(elements=("Male", "Female")),
            fake.date_time_this_decade(),
            fake.random_int(min=18, max=80),
            address_id,
        ),
    )
    return f"inserted person {cursor.lastrowid} ({first_name})"


def random_id(cursor, table):
    cursor.execute(f"SELECT id FROM {table} ORDER BY RAND() LIMIT 1")
    row = cursor.fetchone()
    return row[0] if row else None


def update_person(cursor):
    person_id = random_id(cursor, "person")
    if person_id is None:
        return insert_person(cursor)
    age = fake.random_int(min=18, max=80)
    cursor.execute("UPDATE person SET age = %s WHERE id = %s", (age, person_id))
    return f"updated person {person_id}: age {age}"


def change_address(cursor):
    address_id = random_id(cursor, "address")
    if address_id is None:
        return insert_person(cursor)
    city = fake.city()
    cursor.execute("UPDATE address SET city = %s WHERE id = %s", (city, address_id))
    return f"moved address {address_id} to {city}"


def delete_person(cursor):
    person_id = random_id(cursor, "person")
    if person_id is None:
        return insert_person(cursor)
    cursor.execute("DELETE FROM person WHERE id = %s", (person_id,))
    return f"deleted person {person_id}"


EVENTS = {
    "insert": insert_person,
    "update_person": update_person,
    "change_address": change_address,
    "delete_person": delete_person,
}


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--events", type=int, default=100, help="number of events (default: 100)")
    parser.add_argument("--min-delay", type=float, default=2.0, help="minimum seconds between events (default: 2)")
    parser.add_argument("--max-delay", type=float, default=5.0, help="maximum seconds between events (default: 5)")
    parser.add_argument("--host", default="localhost", help="MySQL host (default: localhost)")
    parser.add_argument("--port", type=int, default=3306, help="MySQL port (default: 3306)")
    args = parser.parse_args()
    if args.min_delay < 0 or args.max_delay < args.min_delay:
        parser.error("need 0 <= --min-delay <= --max-delay")
    return args


def main():
    args = parse_args()
    load_dotenv(Path(__file__).resolve().parent.parent / ".env")
    connection = mysql.connector.connect(
        host=args.host,
        port=args.port,
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        database="streaming_etl_db",
    )
    cursor = connection.cursor()
    kinds, weights = zip(*EVENT_WEIGHTS.items())
    try:
        for n in range(1, args.events + 1):
            kind = random.choices(kinds, weights=weights)[0]
            message = EVENTS[kind](cursor)
            connection.commit()
            print(f"[{n}/{args.events}] {message}", flush=True)
            if n < args.events:
                time.sleep(random.uniform(args.min_delay, args.max_delay))
    except KeyboardInterrupt:
        print("Stopped.")
    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    main()
