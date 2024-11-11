CREATE MATERIALIZED VIEW mv_population_growth
BUILD IMMEDIATE
REFRESH COMPLETE
AS

WITH population_prep AS 
(
SELECT 
    GEOID,
    METRO_NAME,
    "YEAR",
    TOTAL_POPULATION,
    LAG(TOTAL_POPULATION) over(PARTITION BY METRO_NAME ORDER BY "YEAR" ASC) AS lag_pop
FROM DW117.HOUSING_DATA hd
WHERE "YEAR" IN (2019,2023)
)
SELECT GEOID,Metro_name,round(100 * (pp.TOTAL_POPULATION - pp.lag_pop)/(pp.lag_pop),2) AS pop_growth_rate_2019_2023
FROM population_prep pp
WHERE pp."YEAR" = 2023;


CREATE OR REPLACE VIEW popvsincome AS

WITH median_income AS ( 
    SELECT GEOID, METRO_NAME, MEDIAN_HOUSEHOLD_INCOME
    FROM HOUSING_DATA hd 
    WHERE "YEAR" = 2023
),
houseprice AS (
    SELECT GEOID, METRO, MEDIAN_HOME_PRICE 
    FROM MEDIAN_HOUSE_PRICE mhp 
    WHERE "YEAR" = 2023
),
ratio_ AS (
    SELECT 
        mi.METRO_NAME,
        ROUND(hp.MEDIAN_HOME_PRICE * 1000 / mi.MEDIAN_HOUSEHOLD_INCOME, 2) AS homeprice_income_ratio
    FROM median_income mi 
    JOIN houseprice hp ON mi.GEOID = hp.GEOID
)
SELECT 
    r.METRO_NAME,
    r.homeprice_income_ratio,
    mpg.POP_GROWTH_RATE_2019_2023
FROM ratio_ r 
JOIN MV_POPULATION_GROWTH mpg ON r.METRO_NAME = mpg.METRO_NAME;
