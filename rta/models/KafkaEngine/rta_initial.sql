{{ config(materialized='view') }}

-- Reads the MergeTree table populated by the materialized view, never the
-- Kafka engine table: selecting from that would consume messages the
-- materialized view needs.
with transformed as (
    select
    CITY,
    COUNT(*) as occurrences
    from {{ source('KafkaEngine', 'person_address_enriched') }}
    GROUP BY CITY
    ORDER BY occurrences DESC
    LIMIT 5
)

select * from transformed
