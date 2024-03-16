{{ config(materialized='view') }}

with transformed as (
    select
    CITY,
    COUNT(*) as occurrences
    from  KafkaEngine.person_address_enriched_queue
    GROUP BY CITY
    ORDER BY occurrences DESC
    LIMIT 5
)

select * from transformed