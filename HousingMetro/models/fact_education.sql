-- models/fact_education_data.sql

WITH base_data AS (
    SELECT
        geoid,
        metro_name,
        year,
        less_than_high_school,
        high_school_graduate,
        college_associate,
        bachelors_degree,
        graduate_degree
    FROM {{ source('housing_source', 'housing_data') }}  -- Referencing the raw education data
)

SELECT
    geoid,
    metro_name,
    year,
    less_than_high_school,
    high_school_graduate,
    college_associate,
    bachelors_degree,
    graduate_degree
FROM base_data
