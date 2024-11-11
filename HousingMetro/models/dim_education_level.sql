WITH education_data AS (
    SELECT DISTINCT
        less_than_high_school AS LTHS,
        high_school_graduate AS HSGrad,
        college_associate AS Assoc,
        bachelors_degree AS Bach,
        graduate_degree AS Grad
    FROM {{ source('housing_source', 'housing_data') }}   -- Reference the housing_data table
)

SELECT
    CASE
        WHEN LTHS IS NOT NULL THEN 'LTHS'
        WHEN HSGrad IS NOT NULL THEN 'HSGrad'
        WHEN Assoc IS NOT NULL THEN 'Assoc'
        WHEN Bach IS NOT NULL THEN 'Bach'
        WHEN Grad IS NOT NULL THEN 'Grad'
        ELSE 'Unknown'
    END AS edu_level
FROM education_data
