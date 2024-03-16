{{ config(order_by='(CITY)', engine='MergeTree()', materialized='table') }}

with abc as
(select
    CITY,
    COUNT(*) as occurrences
    from  KafkaEngine.person_address_enriched
    GROUP BY CITY
    ORDER BY occurrences DESC
    LIMIT 5
)

select *
from abc