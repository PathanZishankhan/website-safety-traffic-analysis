-- Business scenario

-- -- A company is developing a website/platform aimed at children and wants to identify what makes a website safe, trustworthy, private, and successful with its target audience.
-- Main question

-- this is just checking the data i.e. profiling

use global_websites_analytics;


-- We're going to answer:

-- How many rows do we have?
SELECT COUNT(*) as total_rows FROM websites_raw;




-- How many unique websites?
SELECT COUNT(DISTINCT Website) FROM websites_raw;
-- the answer is 3401 unique websites




-- now we dont need all columns so first we will create a copy of our orignal raw data and then 
-- remove unnecessary columns to make the wrk easier
create Table websites_analysis 
select * from websites_raw;


-- now we see columns 
DESCRIBE websites_analysis;
-- we dont need these columns:
-- Subnetworks
-- Registrant
-- Registrar
-- Hosted_by

-- and also the social media metrics
-- Facebook_likes
-- Twitter_mentions
-- Google_pluses
-- LinkedIn_mentions
-- Pinterest_pins
-- StumbleUpon_views


ALTER TABLE websites_analysis
DROP COLUMN Facebook_likes,
DROP COLUMN Twitter_mentions,
DROP COLUMN Google_pluses,
DROP COLUMN LinkedIn_mentions,
DROP COLUMN Pinterest_pins,
DROP COLUMN StumbleUpon_views,
DROP COLUMN Subnetworks,
DROP COLUMN Registrant,
DROP COLUMN Registrar,
DROP COLUMN Hosted_by
;

ALTER TABLE websites_analysis
DROP COLUMN Location,
DROP COLUMN Avg_Daily_Pageviews,
DROP COLUMN Reach_Day,
DROP COLUMN Daily_Pageviews,
DROP COLUMN Reach_Day_percentage,
DROP COLUMN Month_Average_Daily_Reach_percentage,
DROP COLUMN Daily_Pageviews_percentage,
DROP COLUMN Month_Average_Daily_Pageviews_percentage,
DROP COLUMN Daily_Pageviews_per_user_percentage;

-- now we will just check all the columns and see which ones have null values adn not 
SELECT SUM(CASE 
    WHEN ISNULL(Country_Rank) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(website) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Trustworthiness`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Avg_Daily_Pageviews`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Child_Safety`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Avg_Daily_Pageviews`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Privacy`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Status`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Traffic_Rank`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Reach_Day`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Month_Average_Daily_Reach`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Daily_Pageviews`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Month_Average_Daily_Pageviews`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Daily_Pageviews_per_user`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Reach_Day_percentage`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Month_Average_Daily_Reach_percentage`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Daily_Pageviews_percentage`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Month_Average_Daily_Pageviews_percentage`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Daily_Pageviews_per_user_percentage`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(`Location`) THEN 1  
    ELSE 0 
END), SUM(CASE 
    WHEN ISNULL(country) THEN 1  
    ELSE 0 
END)
FROM websites_analysis;
-- everything is 0 so there are no null values 

-- now we will check unique values from each column, we can change the cilumn name in this same query and check individually 
SELECT DISTINCT `Child_Safety`
FROM websites_analysis;

DESCRIBE websites_analysis;
-- now we will check if there are any character values in our numerical columns:
-- daily, monthly, average ones, daily pageviews, traffic rank, avg daily visirors


SELECT COUNT(Avg_Daily_visitors)
FROM websites_analysis
WHERE TRIM(REPLACE(`Avg_Daily_Visitors`,' ','')) REGEXP '^[0-9]+(\.[0-9]+)?$'
-- here there are 144 N/A values

SELECT SUM(CASE 
    WHEN TRIM(REPLACE(`Avg_Daily_Visitors`,' ','')) REGEXP '^[0-9]+(\.[0-9]+)?$' THEN 0 
    ELSE  1
END) as count_avg_Daily_visitors,  SUM(CASE 
    WHEN TRIM(REPLACE(`Month_Average_Daily_Reach`,' ','')) REGEXP '^[0-9]+(\.[0-9]+)?$' THEN 0 
    ELSE  1
END) as count_Month_avg_Daily_visitors, SUM(CASE 
    WHEN TRIM(REPLACE(`Month_Average_Daily_Pageviews`,' ','')) REGEXP '^[0-9]+(\.[0-9]+)?$' THEN 0 
    ELSE  1
END) as count_Month_avg_Daily_Pageviews, SUM(CASE 
    WHEN TRIM(REPLACE(`Daily_Pageviews_per_user`,' ','')) REGEXP '^[0-9]+(\.[0-9]+)?$' THEN 0 
    ELSE  1
END) as count_Daily_Pageviews_per_user

 FROM websites_analysis;

 

 
--  which website occurs multiple times 
SELECT country, COUNT(country) as country_count
FROM websites_analysis
GROUP BY country;


-- mininmum and maximum values of each column to check outliers
SELECT MIN(`Country_Rank`), MAX(`Country_Rank`), MIN(`Avg_Daily_Visitors`), MAX(`Avg_Daily_Visitors`), MIN(`Traffic_Rank`), MAX(`Traffic_Rank`),
MIN(`Month_Average_Daily_Reach`), MAX(`Month_Average_Daily_Reach`), MIN(`Month_Average_Daily_Pageviews`), MAX(`Month_Average_Daily_Pageviews`),
MIN(`Daily_Pageviews_per_user`), MAX(`Daily_Pageviews_per_user`)
FROM websites_analysis;

-- the avg values contain NA and all so mini max are not wroking properl after we do cleaning we will check again 


SELECT * from websites_analysis;
-- now finally we will check any DUPLICATE ROWS
-- there are three techniques firs is from group by, second self join, third is by window funstions

-- 1. the group by method
SELECT `Country_Rank`, Website, Trustworthiness, Avg_Daily_Visitors, Child_Safety, Privacy, Status, Traffic_Rank, `Month_Average_Daily_Reach`, `Month_Average_Daily_Pageviews`, `Daily_Pageviews_per_user`, country
FROM websites_analysis
GROUP BY `Country_Rank`, Website, Trustworthiness, Avg_Daily_Visitors, Child_Safety, Privacy, Status, Traffic_Rank, `Month_Average_Daily_Reach`, `Month_Average_Daily_Pageviews`, `Daily_Pageviews_per_user`, country
HAVING COUNT(*)>1;
-- we saw there is nothign in output so there are no dupliates 


-- we will try join method now 
-- but there is no primary key and we can temporarily create one but the it would create pronlems with 'null' so it will not work properly 



-- now with partition functions

WITH numbered_table AS(
    SELECT `Country_Rank`, Website, Trustworthiness, Avg_Daily_Visitors, Child_Safety, Privacy, Status, Traffic_Rank, `Month_Average_Daily_Reach`, `Month_Average_Daily_Pageviews`, `Daily_Pageviews_per_user`, country,
ROW_NUMBER() OVER(PARTITION BY `Country_Rank`, Website, Trustworthiness, Avg_Daily_Visitors, Child_Safety, Privacy, Status, Traffic_Rank, `Month_Average_Daily_Reach`, `Month_Average_Daily_Pageviews`, `Daily_Pageviews_per_user`, country) as row_num
FROM websites_analysis
)
SELECT * FROM numbered_table
WHERE row_num >1;



-- we will check why the websites appear multiple time  
SELECT `Country_Rank`, Website, Trustworthiness, Avg_Daily_Visitors, Child_Safety, Privacy, Status, Traffic_Rank, `Month_Average_Daily_Reach`, `Month_Average_Daily_Pageviews`, `Daily_Pageviews_per_user`, country,
ROW_NUMBER() OVER(PARTITION BY Website) as row_num
FROM websites_analysis;
-- we saw that some of them have same data but the country is different so every 
-- website is there according to different countries