-- models/fact_housing_data.sql

WITH base_data AS (
    SELECT
        geoid,
        metro_name,
        year,
        total_population,
        median_age,
        average_household_size,
        average_family_size,
        population_25_and_over,
        median_household_income,
        owner_occupied_units,
        renter_occupied_units,
        less_than_30_percent_owner,
        over_30_percent_owner,
        less_than_30_percent_renter,
        over_30_percent_renter
     FROM {{ source('housing_source', 'housing_data') }}  -- Referencing the raw housing data
)

SELECT
    geoid,
    metro_name,
    year,
    total_population,
    median_age,
    average_household_size,
    average_family_size,
    population_25_and_over,
    median_household_income,
    owner_occupied_units,
    renter_occupied_units,
    less_than_30_percent_owner,
    over_30_percent_owner,
    less_than_30_percent_renter,
    over_30_percent_renter
FROM base_data
