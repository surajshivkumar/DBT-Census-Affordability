-- models/fact_housing_data.sql

WITH base_data AS (
    SELECT
        geoid,
        metro,
        year,
        median_home_price
        
     FROM {{ source('houseprice_source', 'median_house_price') }}  -- Referencing the raw housing data
)

SELECT
    geoid,
    metro,
    year,
    median_home_price
FROM base_data
