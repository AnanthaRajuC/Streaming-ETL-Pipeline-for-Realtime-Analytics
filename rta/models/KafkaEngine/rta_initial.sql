{{ config(materialized='view') }}

-- Reads person_current (one row per live person), never the Kafka engine
-- table: selecting from that would consume messages the materialized
-- view needs.
with transformed as (
    select
    ifNull(CITY, 'Unknown') as CITY,
    COUNT(*) as occurrences
    from {{ ref('person_current') }}
    GROUP BY CITY
    ORDER BY occurrences DESC
    LIMIT 5
)

select * from transformed
