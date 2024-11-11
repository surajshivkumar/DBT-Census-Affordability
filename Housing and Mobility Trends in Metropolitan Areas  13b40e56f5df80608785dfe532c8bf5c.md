# Housing and Mobility Trends in Metropolitan Areas: A Data-Driven Analysis

---

Presented by :

- Suraj Shivakumar
- Shivani
- Satvik

![image.png](Housing%20and%20Mobility%20Trends%20in%20Metropolitan%20Areas%20%2013b40e56f5df80608785dfe532c8bf5c/image.png)

# 1. Executive Summary

This project focuses on understanding **housing affordability** across different metropolitan areas in the United States. By leveraging data from the **U.S. Census API**, the goal is to explore the factors influencing housing affordability and assess where each metro area stands in terms of home prices, income levels, and population growth.

The project begins by collecting raw data from the Census API, which provides key metrics like median household income, housing prices, and population data. This data is then loaded into an **Oracle database**, where **dbt (data build tool)** is used to transform and organize the data into a dimensional model. The final step involves creating **materialized views** to optimize query performance, ensuring fast access for **Tableau dashboards**.

These dashboards will allow stakeholders, such as city planners, real estate investors, and policymakers, to visually analyze trends in housing affordability across metropolitan areas. The project aims to provide actionable insights to help decision-makers understand the state of housing markets and affordability in the U.S., with the goal of identifying areas of growth, investment opportunities, and areas where policy interventions may be necessary.

By combining data warehousing techniques, analytic SQL, and data visualization, this project creates a comprehensive framework for exploring housing affordability in the U.S. metropolitan context.

## 2. Problem Statement

The challenge this project addresses is the increasing difficulty in predicting home prices and identifying the factors that influence housing markets. Real estate investors, city planners, and policymakers often face difficulties in assessing future market trends due to the complexity of factors like income growth, population dynamics, and regional disparities. The objective of this project is to build a data warehouse that integrates various data sources, focusing specifically on metropolitan housing prices, income levels, and population growth, to help stakeholders make informed decisions.

**The 5W+H Approach:**

- **Who**: Real estate investors, city planners, and government policymakers.
- **What**: Identifying the key drivers of home price fluctuations and understanding how population growth and income levels impact housing prices in metropolitan areas.
- **When and Where**: The project focuses on 2023 data for major U.S. metropolitan areas.
- **Why**: Understanding these relationships is crucial for better urban planning, investment strategies, and policy-making.
- **How**: By building a data warehouse with integrated housing, income, and population data, and applying advanced SQL analytics.

This project aims to provide an actionable tool for understanding housing market trends and offer insights into future investments.

# **3. Literature Review**

The literature review for this project draws on several key data sources and frameworks that provide insights into housing affordability, socio-economic trends, and metropolitan area characteristics. These sources will help contextualize the analysis and guide decision-making in urban planning and policy.

1. **Census Data**
    
    The U.S. Census Bureau provides comprehensive data on demographic trends, household income, and housing characteristics across different metropolitan areas. Census data serves as a foundational resource for understanding the socio-economic makeup of various regions, which is essential for assessing housing affordability and planning transportation and infrastructure.
    
2. **FRED (Federal Reserve Economic Data)**
    
    The Federal Reserve Bank of St. Louis hosts the FRED database, which offers a wide range of economic data, including housing market trends, economic indicators, and income levels. FRED is particularly useful for tracking the relationship between economic health and housing affordability, helping to identify broader economic patterns and trends that influence real estate markets in urban regions.
    
3. **NBC (National Bureau of Economic Research)**
    
    The National Bureau of Economic Research (NBER) offers studies and reports on economic factors influencing urban and housing markets, including income disparity, economic mobility, and housing price trends. This research helps in understanding the economic forces shaping housing markets and provides insight into the long-term trends that affect affordability and quality of life in metropolitan areas.
    
4. **NACO (National Association of Counties)**
    
    NACO provides data on county-level socio-economic metrics, including housing and transportation statistics. Their reports focus on the challenges and solutions faced by urban areas, particularly in terms of affordability, public policy, and infrastructure planning. NACO’s data helps inform the geographic and demographic boundaries within which housing affordability issues are studied.
    
5. **Redfin**
    
    Redfin, a leading real estate platform, offers real-time housing market data that covers trends in home prices, sales activity, and other housing metrics across metropolitan areas. This data is invaluable for understanding current housing market conditions and identifying regional variations in housing affordability. Redfin's data enables a granular view of housing price fluctuations, which directly impacts the analysis of housing affordability in specific metro regions.
    

# **4. Data Collection and Preparation**

### **Data Sources**

The primary data sources for this project are various U.S. Census datasets, along with economic and housing data from additional sources like the Federal Reserve (FRED), Redfin, NACO, and more. Below is a description of the data collection process for each source:

**Census Data**:

Raw housing and demographic data were pulled from the U.S. Census API. These datasets include key socio-economic indicators such as:

- Median household income
- Housing affordability indices
- Population data (by region)
- Housing stock and vacancy ratesThis data is collected from the American Community Survey (ACS), Decennial Census, and other specialized surveys (like the Economic Census) available through the Census Bureau.

**Data Preparation**

After collecting the data, we used **Pandas** to clean, transform, and structure the data for use in the analysis and dimensional modeling. Below are the steps undertaken to prepare the data:

1. **Data Cleaning Using Pandas**:
    - **Handling Missing Data**: Any missing values in the dataset (e.g., absent income or home price data) were identified and addressed. Pandas' `fillna()` function was used for imputation, and rows with excessive missing values were removed using `dropna()`.
    - **Standardizing Data Formats**: The data was cleaned by ensuring consistent formats across datasets. For example, categorical variables like metro area names were standardized using Pandas' `str.strip()` and `str.replace()` functions to remove redundant state names and ensure consistent formatting.
    
    Example:
    
    ```python
    def clean(x):
        try:
            x = str(x)
            x = x.replace(',','').replace('%','')
            x = float(x)
            return x
        except:
            return x
    def extract_data(file):
        df  = pd.read_csv(file)
        df = df[[i for i in df.columns if  'Total!!Estimate' in i or 'Label' in i]]
        df = df.T
        df.columns = df[:1].values[0]
        df  = df[1:]
        df.columns = [i.replace('\xa0','') for i in df.columns]
        burden = df.iloc[:,-7:]
        burden.columns = ['SELECTED MONTHLY OWNER COSTS AS A PERCENTAGE OF HOUSEHOLD INCOME IN THE PAST 12 MONTHS',
                          'less_than_30%_Owner','over_30%_Owner','Renter-occupied housing units',
                          'GROSS RENT AS A PERCENTAGE OF HOUSEHOLD INCOME IN THE PAST 12 MONTHS',
                          'less_than_30%_renter',
                          'over_30%_renter']
        burden = burden[[ 'less_than_30%_Owner','over_30%_Owner','less_than_30%_renter',
                          'over_30%_renter']]
        final = df[req_list]
        final = pd.concat([final,burden],axis=1)
        for cols in final.columns:
            final[cols] = final[cols].map(lambda x: clean(x))
        return final
        
    from tqdm import tqdm
    data = pd.DataFrame()
    for file in tqdm(files):
        d = extract_data(file)
        year = file.split('.')[1][-4:]
        d['year'] = year
        data = pd.concat([data,d],axis=0)
        
      
    ```
    
2. **Loading Data into Oracle DB**:
After cleaning and transforming the data, it was loaded into Oracle DB as a staging table for further processing and modeling. This was done using Python's `cx_Oracle` library, which allowed for seamless insertion of data from the cleaned Pandas DataFrame into the database.
    
    Example of data insertion into Oracle:
    
    ```python
    import pandas as pd
    oracle_username = 'DW117'
    oracle_password = '****'
    oracle_host = 'reade.forest.usf.edu'
    oracle_port = '1521'
    oracle_service = 'cdb9'
    
    # Set up Oracle connection using cx_Oracle
    conn = cx_Oracle.connect(oracle_username, oracle_password, f"{oracle_host}:{oracle_port}/{oracle_service}")
    cursor = conn.cursor()
    
    # Load HousingData CSV into pandas DataFrame
    housing_data_df = pd.read_csv('HousingData.csv')
    
    # Insert each row into Oracle housing_data table
    for row in housing_data_df.itertuples(index=False):
        cursor.execute("""
            INSERT INTO housing_data (
                geoid, metro_name, total_population, median_age, average_household_size, 
                average_family_size, population_25_and_over, less_than_high_school, 
                high_school_graduate, college_associate, bachelors_degree, graduate_degree, 
                median_household_income, owner_occupied_units, renter_occupied_units, 
                less_than_30_percent_owner, over_30_percent_owner, 
                less_than_30_percent_renter, over_30_percent_renter, year
            ) VALUES (
                :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20
            )""", row)
    
    # Load TransportData CSV into pandas DataFrame
    transport_data_df = pd.read_csv('TransportData.csv')
    
    # Insert each row into Oracle transport_data table
    for row in transport_data_df.itertuples(index=False):
        cursor.execute("""
            INSERT INTO transport_data (
                geoid, metro_name, mean_travel_time_to_work, median_earnings, year
            ) VALUES (
                :1, :2, :3, :4, :5
            )""", row)
    
    # Commit the changes and close the cursor and connection
    conn.commit()
    cursor.close()
    conn.close()
    
    print("Data loaded successfully!")
    
    ```
    
3. **Staging Tables for Dimensional Modeling**:
The cleaned and transformed data was then placed into staging tables in Oracle DB to create the following dimensions and facts:

Some Examples : 

- **Dimensions**: `Metro Area`, `Year`, `Income Level`, `Housing Type`
- **Facts**: `Median Household Income`, `Median Home Price`, `Population Growth Rate`, `Housing Affordability Index`

# 5: Database Design

Dimensional modeling (DM) is used for data warehousing and focuses on making it easier to run analytical queries. Unlike OLTP systems, dimensional models simplify the data by using denormalized tables. These models are designed around business processes and user queries, typically supporting operations like reporting, dashboards, and analytical functions. They are well-suited to support decision-making processes for managers and business analysts.

In dimensional modeling, we typically have two types of tables:

1. **Fact Tables**: These contain numerical data (facts) and foreign keys to dimension tables. Fact tables usually store transactional data that we want to analyze.
2. **Dimension Tables**: These describe the context of the facts. They are typically descriptive data about dimensions (e.g., time, location, demographic information).

For the project, I used **DBT (Data Build Tool)** to implement dimensional modeling. DBT is a transformation tool that enables the building, testing, and documentation of data transformations directly in a data warehouse. DBT allows us to transform raw transactional data into a format that is easy to query for analytical purposes, typically in a Snowflake schema or Star schema layout.

![image.png](Housing%20and%20Mobility%20Trends%20in%20Metropolitan%20Areas%20%2013b40e56f5df80608785dfe532c8bf5c/image%201.png)

# **6: Reporting, Modeling, and Storytelling**

### What is the trend of home price to income ratio over time and its correlation with population growth for different metros?

```sql
CREATE OR REPLACE VIEW home_price_income_trend AS
WITH median_income AS ( 
    SELECT GEOID, METRO_NAME, MEDIAN_HOUSEHOLD_INCOME
    FROM HOUSING_DATA
    WHERE "YEAR" BETWEEN 2021 AND 2023
),
houseprice AS (
    SELECT GEOID, METRO, MEDIAN_HOME_PRICE 
    FROM MEDIAN_HOME_PRICE
    WHERE "YEAR" BETWEEN 2021 AND 2023
),
ratio_ AS (
    SELECT 
        mi.METRO_NAME,
        mi."YEAR",
        ROUND(hp.MEDIAN_HOME_PRICE * 1000 / mi.MEDIAN_HOUSEHOLD_INCOME, 2) AS homeprice_income_ratio
    FROM median_income mi 
    JOIN houseprice hp ON mi.GEOID = hp.GEOID
),
population_growth AS (
    SELECT METRO_NAME, POP_GROWTH_RATE_2021_2023
    FROM MV_POPULATION_GROWTH
)
SELECT 
    r.METRO_NAME,
    r."YEAR",
    r.homeprice_income_ratio,
    pg.POP_GROWTH_RATE_2021_2023,
    CORR(r.homeprice_income_ratio, pg.POP_GROWTH_RATE_2021_2023) OVER (PARTITION BY r.METRO_NAME) AS correlation
FROM ratio_ r 
JOIN population_growth pg ON r.METRO_NAME = pg.METRO_NAME
ORDER BY r.METRO_NAME, r."YEAR";

```

**Which metros have seen the highest growth in home prices relative to median income between 2021 and 2023?**

- **Use Case**: This helps identify metros where housing affordability has become more challenging as home prices rise faster than income.

```sql
CREATE OR REPLACE VIEW homeprice_income_growth AS
WITH median_income AS ( 
    SELECT GEOID, METRO_NAME, MEDIAN_HOUSEHOLD_INCOME
    FROM HOUSING_DATA
    WHERE "YEAR" BETWEEN 2021 AND 2023
),
houseprice AS (
    SELECT GEOID, METRO, MEDIAN_HOME_PRICE 
    FROM MEDIAN_HOME_PRICE
    WHERE "YEAR" BETWEEN 2021 AND 2023
),
ratio_ AS (
    SELECT 
        mi.METRO_NAME,
        mi."YEAR",
        ROUND(hp.MEDIAN_HOME_PRICE * 1000 / mi.MEDIAN_HOUSEHOLD_INCOME, 2) AS homeprice_income_ratio
    FROM median_income mi 
    JOIN houseprice hp ON mi.GEOID = hp.GEOID
)
SELECT 
    r.METRO_NAME,
    MAX(r.homeprice_income_ratio) - MIN(r.homeprice_income_ratio) AS price_to_income_growth
FROM ratio_ r
GROUP BY r.METRO_NAME
HAVING MAX(r.homeprice_income_ratio) - MIN(r.homeprice_income_ratio) > 0
ORDER BY price_to_income_growth DESC;

```

**What is the total and average home price to income ratio by metro, and how does it change across years?**

- **Use Case**: This query uses `ROLLUP` to calculate total and average home price to income ratios for each metro, and across all metros and years, to understand trends and comparisons over time.

```sql
CREATE OR REPLACE VIEW home_price_income_aggregated AS
WITH median_income AS ( 
    SELECT GEOID, METRO_NAME, MEDIAN_HOUSEHOLD_INCOME
    FROM HOUSING_DATA
    WHERE "YEAR" BETWEEN 2021 AND 2023
),
houseprice AS (
    SELECT GEOID, METRO, MEDIAN_HOME_PRICE 
    FROM MEDIAN_HOME_PRICE
    WHERE "YEAR" BETWEEN 2021 AND 2023
),
ratio_ AS (
    SELECT 
        mi.METRO_NAME,
        mi."YEAR",
        ROUND(hp.MEDIAN_HOME_PRICE * 1000 / mi.MEDIAN_HOUSEHOLD_INCOME, 2) AS homeprice_income_ratio
    FROM median_income mi 
    JOIN houseprice hp ON mi.GEOID = hp.GEOID
)
SELECT 
    r.METRO_NAME,
    r."YEAR",
    SUM(r.homeprice_income_ratio) AS total_homeprice_income_ratio,
    AVG(r.homeprice_income_ratio) AS avg_homeprice_income_ratio
FROM ratio_ r
GROUP BY ROLLUP(r.METRO_NAME, r."YEAR")
ORDER BY r.METRO_NAME, r."YEAR";

```

This section serves as the core of the project, where the focus shifts to reporting, data modeling, and storytelling. In this project, we have pursued a combination of **reporting**, **data modeling**, and **storytelling** to explore the housing affordability landscape in metro areas.

We created a Housing Affordability Report card by Metros

![image.png](Housing%20and%20Mobility%20Trends%20in%20Metropolitan%20Areas%20%2013b40e56f5df80608785dfe532c8bf5c/image%202.png)

This dashboard provides an overview of **housing affordability** in a given metro area, summarizing key metrics related to the local housing market and population. Here’s a breakdown of the sections:

1. **Metro Population**:
    - Displays the total population of the area.
2. **% Population Over 25**:
    - Shows the percentage of the population that is above 25 years old, which is relevant for analyzing potential homeowners or renters.
3. **Median Income in USD**:
    - Represents the median income in the area, which is crucial for understanding the financial context in which housing costs are considered.
4. **Median Home Value**:
    - A graph that shows how the median home value has changed over time (from 2021 to 2023). It provides insights into the general trend in home prices in the area.
5. **Homeowners**:
    - **% Owner Occupied Units**: Indicates what proportion of homes are owned by residents.
    - **% Cost Burdened Owners**: Shows the percentage of homeowners who are spending a significant portion of their income (more than 30%) on housing costs, which is considered a sign of financial strain.
6. **Renters**:
    - **% Renter Occupied Units**: Indicates the percentage of homes being rented in the area.
    - **% Cost Burdened Renters**: Highlights the percentage of renters who are spending a significant portion of their income on rent.

Together, these metrics help assess the **affordability** of housing in the metro area by looking at the balance between home prices, income levels, and the burden of housing costs on both homeowners and renters.

# 8: **Conclusions**

The housing affordability dashboard provides valuable insights into the dynamics of homeownership and rental conditions in metropolitan areas. By looking at key indicators like population demographics, median income, home values, and housing burdens, the dashboard allows for a clear understanding of the financial strain felt by both homeowners and renters.

Key takeaways from the dashboard include:

- **Affordability Trends**: The variation in home prices and income over time highlights whether housing is becoming more or less affordable.
- **Cost Burden**: The percentage of homeowners and renters who are considered cost-burdened—spending more than 30% of their income on housing—serves as an important indicator of financial health within the metro area.
- **Potential Policy Insights**: By identifying metros with high cost-burdened populations, policymakers can target these areas for intervention in affordable housing programs or rent control measures.

The dashboard serves as a useful tool for urban planners, policymakers, and stakeholders to better understand and address housing affordability issues in specific areas.

# 9: **GitHub**

You can access the full project, including code, SQL queries, and the Tableau dashboard, at the following GitHub repository:

[**GitHub Repository: Housing Affordability Dashboard**](https://github.com/your-github-username/housing-affordability-dashboard)

This repository includes all necessary files for running the project, including data transformations, DBT models, and Tableau visualizations.