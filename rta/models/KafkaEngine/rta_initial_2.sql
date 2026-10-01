{{ config(order_by='(CITY)', engine='MergeTree()', materialized='table') }}

with abc as
(select
    ifNull(CITY, 'Unknown') as CITY,
    COUNT(*) as occurrences
    from {{ ref('person_current') }}
    GROUP BY CITY
    ORDER BY occurrences DESC
    LIMIT 5
)

select *
from abc
