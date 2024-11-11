-- models/dim_date.sql

WITH date_generator AS (
    SELECT DISTINCT year
    FROM {{ source('housing_source', 'housing_data') }}  -- Referenrencing the raw housing data
)

SELECT
    year AS date_value,
    year AS year
FROM date_generator
