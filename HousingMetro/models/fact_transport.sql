-- models/fact_transport_data.sql

WITH base_data AS (
    SELECT
        geoid,
        metro_name,
        year,
        mean_travel_time_to_work,
        median_earnings
    FROM {{ source('transport_source', 'transport_data') }}  -- Referencing the raw transport data
)

SELECT
    geoid,
    metro_name,
    year,
    mean_travel_time_to_work,
    median_earnings
FROM base_data
