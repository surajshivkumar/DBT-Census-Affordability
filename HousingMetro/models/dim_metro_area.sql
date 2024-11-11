-- models/dim_metro_area.sql

SELECT DISTINCT
    geoid,
    metro_name
FROM {{ source('housing_source', 'housing_data') }}  -- Referencing the raw housing data
