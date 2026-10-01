{{ config(materialized='view') }}

-- Current state of every person: FINAL collapses the versions that
-- ReplacingMergeTree has not merged yet and drops deleted people.
select
    P_ID,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    AGE,
    REGISTRATION,
    A_ID,
    CITY,
    STATE,
    ZIPCODE,
    LAT,
    LNG,
    UPDATED_AT
from {{ source('KafkaEngine', 'person_address_enriched') }} FINAL
where IS_DELETED = 0
