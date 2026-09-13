use global_websites_analytics;

SELECT * FROM websites_analysis;

DESCRIBE websites_analysis;

-- first we will remove every white space from first and last from all the COLUMNS

-- FIRST we will create a copy of that table and then perform the cleaning

CREATE Table websites_cleaned
select * from websites_analysis;


DESCRIBE websites_cleaned;


UPDATE websites_cleaned
SET `Country_Rank` = TRIM(`Country_Rank`), `Website` = TRIM(`Website`), `Trustworthiness` = TRIM(`Trustworthiness`),
`Avg_Daily_Visitors` = TRIM(`Avg_Daily_Visitors`), `Child_Safety` = TRIM(`Child_Safety`), `Privacy` = TRIM(`Privacy`), `Status`= TRIM(`Status`),
`Traffic_Rank` = TRIM(`Traffic_Rank`), `Month_Average_Daily_Reach` = TRIM(`Month_Average_Daily_Reach`), `Month_Average_Daily_Pageviews` = TRIM(`Month_Average_Daily_Pageviews`),
`Daily_Pageviews_per_user` = TRIM(`Daily_Pageviews_per_user`), country = TRIM(country);
-- white spaces are removed



-- now the numeric columns we will remove all the inside spaces as well, in profiling we already checked that everything is in number except N/A 
-- we will tacle N/A afterwards
UPDATE websites_cleaned
SET `Avg_Daily_Visitors` = REPLACE(`Avg_Daily_Visitors`, ' ', ''), `Traffic_Rank` = REPLACE(`Traffic_Rank`, ' ', ''),
`Month_Average_Daily_Reach` = REPLACE(`Month_Average_Daily_Reach`, ' ', ''), `Month_Average_Daily_Pageviews` = REPLACE(`Month_Average_Daily_Pageviews`, ' ', ''),
`Daily_Pageviews_per_user` = REPLACE(`Daily_Pageviews_per_user`, ' ', '');


UPDATE websites_cleaned
SET `Country_Rank` = REPLACE(`Country_Rank`, ' ', '')

-- now we will tackle the N/A parts we will turn those to null valuesUPDATE websites_cleaned
SET
    Avg_Daily_Visitors =
        CASE
            WHEN UPPER(TRIM(Avg_Daily_Visitors)) IN ('N/A', 'NA')
                THEN NULL
            ELSE TRIM(Avg_Daily_Visitors)
        END,

    Traffic_Rank =
        CASE
            WHEN UPPER(TRIM(Traffic_Rank)) IN ('N/A', 'NA')
                THEN NULL
            ELSE TRIM(Traffic_Rank)
        END,

    Month_Average_Daily_Reach =
        CASE
            WHEN UPPER(TRIM(Month_Average_Daily_Reach)) IN ('N/A', 'NA')
                THEN NULL
            ELSE TRIM(Month_Average_Daily_Reach)
        END,

    Month_Average_Daily_Pageviews =
        CASE
            WHEN UPPER(TRIM(Month_Average_Daily_Pageviews)) IN ('N/A', 'NA')
                THEN NULL
            ELSE TRIM(Month_Average_Daily_Pageviews)
        END,

    Daily_Pageviews_per_user =
        CASE
            WHEN UPPER(TRIM(Daily_Pageviews_per_user)) IN ('N/A', 'NA')
                THEN NULL
            ELSE TRIM(Daily_Pageviews_per_user)
        END;


DESCRIBE websites_cleaned;
SELECT DISTINCT `Country_Rank`
FROM websites_cleaned;

-- everything clened




-- now we will convert the datatypes
ALTER TABLE websites_cleaned
MODIFY COLUMN Country_Rank INT,
MODIFY COLUMN Avg_Daily_Visitors DECIMAL(12,3),
MODIFY COLUMN Traffic_Rank INT,
MODIFY COLUMN Month_Average_Daily_Reach DECIMAL(12,3),
MODIFY COLUMN Month_Average_Daily_Pageviews DECIMAL(12,3),
MODIFY COLUMN Daily_Pageviews_per_user DECIMAL(12,3);


-- now all the columns are completely changed to required and wanted data types
DESCRIBE websites_cleaned;


-- checking the missing or null values(total) from every column for further cleaning
SELECT
    COUNT(*) AS total_rows,

    SUM(Country_Rank IS NULL) AS missing_country_rank,
    SUM(Website IS NULL OR TRIM(Website) = '') AS missing_website,
    SUM(Trustworthiness IS NULL OR TRIM(Trustworthiness) = '') AS missing_trustworthiness,
    SUM(Avg_Daily_Visitors IS NULL) AS missing_avg_daily_visitors,
    SUM(Child_Safety IS NULL OR TRIM(Child_Safety) = '') AS missing_child_safety,
    SUM(Privacy IS NULL OR TRIM(Privacy) = '') AS missing_privacy,
    SUM(Status IS NULL OR TRIM(Status) = '') AS missing_status,
    SUM(Traffic_Rank IS NULL) AS missing_traffic_rank,
    SUM(Month_Average_Daily_Reach IS NULL) AS missing_monthly_reach,
    SUM(Month_Average_Daily_Pageviews IS NULL) AS missing_monthly_pageviews,
    SUM(Daily_Pageviews_per_user IS NULL) AS missing_pageviews_per_user,
    SUM(country IS NULL OR TRIM(country) = '') AS missing_country
FROM websites_cleaned;

-- there are some in these columns: missing_avg_daily_visitors, missing_traffic_rank, missing_monthly_reach, missing_pageviews_per_user, missing_pageviews_per_user

-- Now we need to check whether categories are consistent.
SELECT DISTINCT Trustworthiness
FROM websites_cleaned
ORDER BY Trustworthiness; --proper

SELECT DISTINCT Child_Safety
FROM websites_cleaned
ORDER BY Child_Safety; --proper

SELECT DISTINCT Privacy
FROM websites_cleaned
ORDER BY Privacy; --proper

SELECT DISTINCT Status
FROM websites_cleaned
ORDER BY Status; --proper


-- we will check the impossible negative values 
SELECT *
FROM websites_cleaned
WHERE Country_Rank < 0
   OR Avg_Daily_Visitors < 0
   OR Traffic_Rank < 0
   OR Month_Average_Daily_Reach < 0
   OR Month_Average_Daily_Pageviews < 0
   OR Daily_Pageviews_per_user < 0;
-- it returned 0 rows so everything good here as well 


-- now we will check the range of columns max and min values 
SELECT
    MIN(Country_Rank) AS min_country_rank,
    MAX(Country_Rank) AS max_country_rank,

    MIN(Avg_Daily_Visitors) AS min_avg_daily_visitors,
    MAX(Avg_Daily_Visitors) AS max_avg_daily_visitors,

    MIN(Traffic_Rank) AS min_traffic_rank,
    MAX(Traffic_Rank) AS max_traffic_rank,

    MIN(Month_Average_Daily_Reach) AS min_monthly_reach,
    MAX(Month_Average_Daily_Reach) AS max_monthly_reach,

    MIN(Month_Average_Daily_Pageviews) AS min_monthly_pageviews,
    MAX(Month_Average_Daily_Pageviews) AS max_monthly_pageviews,

    MIN(Daily_Pageviews_per_user) AS min_pages_per_user,
    MAX(Daily_Pageviews_per_user) AS max_pages_per_user
FROM websites_cleaned;
-- everything is good here as well 


-- finally removing duplicate values from dataset and then everythign will be done 
-- for that we first have to create a primary key  
ALTER TABLE websites_cleaned
ADD COLUMN row_id BIGINT AUTO_INCREMENT PRIMARY KEY;

WITH duplicate_CTE AS (
    SELECT
        row_id,
        ROW_NUMBER() OVER (
            PARTITION BY
                Country_Rank,
                Website,
                Trustworthiness,
                Avg_Daily_Visitors,
                Child_Safety,
                Privacy,
                Status,
                Traffic_Rank,
                Month_Average_Daily_Reach,
                Month_Average_Daily_Pageviews,
                Daily_Pageviews_per_user,
                country
            ORDER BY row_id
        ) AS row_num
    FROM websites_cleaned
)
DELETE w
FROM websites_cleaned AS w
JOIN duplicate_CTE AS d
    ON w.row_id = d.row_id
WHERE d.row_num > 1;

-- now the dataset is completely cleaned, standardised and ready for analysis 





