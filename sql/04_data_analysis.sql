use global_websites_analytics;

-- Understand the size and coverage of the available market.
-- How many records are there?
-- How many unique websites?
-- How many countries?
-- What is the overall average traffic?
-- What is the overall average pageview engagement?
-- How many websites have missing values for important metrics?








-- 1. What does the overall website landscape look like?
-- Goal: Establish the dataset baseline.
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT Website) AS unique_websites,
    COUNT(DISTINCT country) AS unique_countries,
    ROUND(AVG(Avg_Daily_Visitors), 2) AS avg_daily_visitors,
    ROUND(AVG(Month_Average_Daily_Pageviews), 2) AS avg_monthly_pageviews,
    ROUND(AVG(Daily_Pageviews_per_user), 2) AS avg_pages_per_user
FROM websites_cleaned;


-- 2. Which countries have the strongest website traffic?
-- Business purpose: Identify promising geographic markets.
SELECT country, AVG(`Avg_Daily_Visitors`) as avg_visitors_per_country, SUM(`Avg_Daily_Visitors`) as sum_of_avg_visitors_by_country,
COUNT(DISTINCT `Website`) as num_of_websites_per_country
FROM websites_cleaned
GROUP BY country
ORDER BY avg_visitors_per_country DESC;


-- 3. Is privacy associated with stronger user engagement?
SELECT
    Privacy,
    COUNT(DISTINCT Website) AS unique_websites,
    ROUND(AVG(Daily_Pageviews_per_user), 2) AS avg_pages_per_user,
    ROUND(AVG(Month_Average_Daily_Pageviews), 2) AS avg_monthly_pageviews,
    ROUND(AVG(Avg_Daily_Visitors), 2) AS avg_daily_visitors
FROM websites_cleaned
WHERE Privacy IS NOT NULL
GROUP BY Privacy
ORDER BY avg_pages_per_user DESC;

-- Observation: 
-- Privacy classification appears to be positively associated with user engagement. 
-- Websites classified as Excellent privacy have the highest average engagement at 4.43 pages per user, followed by Good at 3.98. 
-- In contrast, Very poor websites average only 1.46 pages per user. However, the lower privacy categories contain very few websites, 
-- so their averages should be interpreted cautiously. The Unknown category also represents a substantial group and should not be treated as either 
-- strong or weak privacy.

-- Business interpretation:
-- This suggests that privacy may be more than a compliance requirement. Websites with stronger privacy classifications 
-- also tend to show higher user engagement. For the proposed children-focused platform, strong privacy controls could therefore support 
-- both user trust and meaningful engagement. However, the analysis shows association, not proof that privacy directly causes higher engagement.




-- 4. Do websites with higher trustworthiness ratings receive more visitors or pageviews?
SELECT
    Trustworthiness,
    COUNT(DISTINCT Website) AS unique_websites,

    ROUND(AVG(Avg_Daily_Visitors), 2)
        AS avg_daily_visitors,

    ROUND(AVG(Month_Average_Daily_Pageviews), 2)
        AS avg_monthly_pageviews,

    ROUND(AVG(Month_Average_Daily_Reach), 2)
        AS avg_monthly_reach

FROM websites_cleaned

WHERE Trustworthiness IS NOT NULL

GROUP BY Trustworthiness

ORDER BY avg_daily_visitors DESC;

-- Observation: 
-- Trustworthiness appears to be associated with website popularity. Websites classified as Excellent have the highest average daily visitors, 
-- at approximately 612.5 million, and the highest average monthly reach, at 4.86. However, the relationship is not perfectly consistent across 
-- all categories. The Poor category, for example, has a higher average traffic value than the Good category despite having a weaker classification. 
-- This may be influenced by the small number of websites in the lower trustworthiness categories and by extreme traffic values.

-- Business insight
-- Insight: Strong trustworthiness may be an important characteristic of popular websites and should be considered a core design priority for 
-- the proposed children-focused platform. However, the company should not rely on average traffic alone when evaluating trustworthiness. 
-- Median traffic and category sample sizes should also be considered to avoid conclusions being dominated by a few extremely popular websites.






-- 6. Which combination of safety, privacy, and trust performs best?
-- Business purpose
-- Identify the characteristics that a successful children-focused platform should prioritize.
SELECT
    Child_Safety,
    Privacy,
    Trustworthiness,

    COUNT(DISTINCT Website) AS unique_websites,

    ROUND(AVG(Avg_Daily_Visitors), 2)
        AS avg_daily_visitors,

    ROUND(AVG(Daily_Pageviews_per_user), 2)
        AS avg_pages_per_user,

    ROUND(AVG(Month_Average_Daily_Pageviews), 2)
        AS avg_monthly_pageviews

FROM websites_cleaned

WHERE Child_Safety IS NOT NULL
  AND Privacy IS NOT NULL
  AND Trustworthiness IS NOT NULL

GROUP BY
    Child_Safety,
    Privacy,
    Trustworthiness

HAVING COUNT(DISTINCT Website) >= 30

ORDER BY avg_daily_visitors DESC;

-- Observation: 
-- The combination of Excellent child safety, Excellent privacy, and Excellent trustworthiness represents the largest group, 
-- with 1,374 unique websites. It has an average of 4.29 pages per user and approximately 600.4 million average daily visitors. 
-- The Good child-safety, Excellent privacy, and Excellent trustworthiness combination shows slightly higher engagement at 4.49 pages per user, 
-- but it contains only 98 websites. Overall, combinations with stronger privacy and trustworthiness classifications tend to show higher engagement 
-- than combinations containing weaker or unknown classifications.

-- Business Insight: 
-- The results suggest that the proposed children-focused platform should aim for a combined profile of excellent privacy, 
-- strong trustworthiness, and excellent child-safety standards. However, the company should prioritize the large and more reliable 
-- Excellent–Excellent–Excellent group rather than selecting a profile only because it has the highest average traffic. Further analysis 
-- using medians would help determine whether the traffic differences are caused by a few exceptionally popular websites.





-- 7.
-- Do highly visited websites also have strong user engagement?
--
-- Business purpose:
-- Distinguish website popularity from engagement quality.
--
-- Business question:
-- Are websites with more daily visitors also the websites
-- where users view more pages per user?



-- Understand the distribution of daily visitors
--
-- We check the minimum, maximum, and average traffic.
-- This helps us identify whether extreme values exist.
-- ------------------------------------------------------------
SELECT
    MIN(Avg_Daily_Visitors) AS minimum_visitors,
    MAX(Avg_Daily_Visitors) AS maximum_visitors,
    ROUND(AVG(Avg_Daily_Visitors), 2) AS average_visitors
FROM websites_cleaned
WHERE Avg_Daily_Visitors IS NOT NULL;


-- Observation from this check:
-- Minimum visitors: 171
-- Maximum visitors: 518,108,189
-- Average visitors: approximately 40,611,403
--
-- The maximum is extremely high compared with the minimum.
-- This suggests that website traffic is heavily skewed.
-- A small number of extremely popular websites may increase
-- the overall average.


-- Calculate the median daily visitors
--
-- The median is more useful than the average for defining
-- high-traffic and low-traffic websites because it is less
-- affected by extreme values.
--
-- If the number of records is odd, the median is the middle
-- value. If it is even, the median is the average of the
-- two middle values.
WITH ordered_visitors AS (
    SELECT
        Avg_Daily_Visitors,

        ROW_NUMBER() OVER (
            ORDER BY Avg_Daily_Visitors
        ) AS row_num,

        COUNT(*) OVER () AS total_rows

    FROM websites_cleaned

    WHERE Avg_Daily_Visitors IS NOT NULL
)

SELECT
    AVG(Avg_Daily_Visitors) AS median_visitors
FROM ordered_visitors
WHERE row_num IN (
    FLOOR((total_rows + 1) / 2),
    CEIL((total_rows + 1) / 2)
);


-- Observation from this check:
-- Median visitors: approximately 4,164,688
--
-- The average is approximately 40.6 million, while the median
-- is approximately 4.16 million.
--
-- This large difference confirms that traffic is strongly
-- right-skewed. Therefore, the median is a better threshold
-- for separating high-traffic and low-traffic websites.

-- Compare high-traffic and low-traffic websites
--
-- High traffic = above the median
-- Low traffic  = at or below the median
--
-- We compare average visitors, engagement, and pageviews
-- for both groups.
WITH traffic_median AS (

    SELECT
        AVG(Avg_Daily_Visitors) AS median_visitors

    FROM (
        SELECT
            Avg_Daily_Visitors,

            ROW_NUMBER() OVER (
                ORDER BY Avg_Daily_Visitors
            ) AS row_num,

            COUNT(*) OVER () AS total_rows

        FROM websites_cleaned

        WHERE Avg_Daily_Visitors IS NOT NULL
    ) AS ordered_visitors

    WHERE row_num IN (
        FLOOR((total_rows + 1) / 2),
        CEIL((total_rows + 1) / 2)
    )
)

SELECT
    CASE
        WHEN w.Avg_Daily_Visitors > m.median_visitors
            THEN 'High traffic'
        ELSE 'Low traffic'
    END AS traffic_group,

    COUNT(DISTINCT w.Website) AS unique_websites,

    ROUND(AVG(w.Avg_Daily_Visitors), 2)
        AS avg_daily_visitors,

    ROUND(AVG(w.Daily_Pageviews_per_user), 2)
        AS avg_pages_per_user,

    ROUND(AVG(w.Month_Average_Daily_Pageviews), 2)
        AS avg_monthly_pageviews

FROM websites_cleaned AS w

CROSS JOIN traffic_median AS m

WHERE w.Avg_Daily_Visitors IS NOT NULL
  AND w.Daily_Pageviews_per_user IS NOT NULL

GROUP BY traffic_group

ORDER BY avg_pages_per_user DESC;
-- Business insight
-- High-traffic websites show slightly stronger average user engagement than low-traffic websites. This suggests that popularity and 
-- engagement may be positively associated, but the difference in pages per user is relatively small. Therefore, high visitor numbers do 
-- not automatically guarantee substantially deeper user engagement.
-- High-traffic websites are associated with slightly higher engagement, but the relationship is relatively weak based on the difference 
-- in average pages per user.




-- Question 8:
-- Which websites have high traffic but low engagement?
--
-- High traffic = above the median visitor count
-- Low engagement = below the median pages-per-user value
--
-- We first create one record per website because the same
-- website may appear multiple times for different countries.
WITH website_level AS (

    SELECT
        Website,

        AVG(Avg_Daily_Visitors) AS avg_daily_visitors,

        AVG(Daily_Pageviews_per_user) AS avg_pages_per_user

    FROM websites_cleaned

    WHERE Avg_Daily_Visitors IS NOT NULL
      AND Daily_Pageviews_per_user IS NOT NULL

    GROUP BY Website
),
-- Calculate the median traffic using one row per website
ordered_traffic AS (

    SELECT
        Website,
        avg_daily_visitors,

        ROW_NUMBER() OVER (
            ORDER BY avg_daily_visitors
        ) AS row_num,

        COUNT(*) OVER () AS total_rows

    FROM website_level
),
traffic_median AS (

    SELECT
        AVG(avg_daily_visitors) AS median_visitors

    FROM ordered_traffic

    WHERE row_num IN (
        FLOOR((total_rows + 1) / 2),
        CEIL((total_rows + 1) / 2)
    )
),
-- Calculate the median engagement using one row per website
ordered_engagement AS (

    SELECT
        Website,
        avg_pages_per_user,

        ROW_NUMBER() OVER (
            ORDER BY avg_pages_per_user
        ) AS row_num,

        COUNT(*) OVER () AS total_rows

    FROM website_level
),
engagement_median AS (

    SELECT
        AVG(avg_pages_per_user) AS median_pages_per_user

    FROM ordered_engagement

    WHERE row_num IN (
        FLOOR((total_rows + 1) / 2),
        CEIL((total_rows + 1) / 2)
    )
)
-- Find websites with high traffic but low engagement
SELECT
    w.Website,

    ROUND(w.avg_daily_visitors, 2)
        AS avg_daily_visitors,

    ROUND(w.avg_pages_per_user, 2)
        AS avg_pages_per_user,

    ROUND(t.median_visitors, 2)
        AS median_visitors,

    ROUND(e.median_pages_per_user, 2)
        AS median_pages_per_user

FROM website_level AS w

CROSS JOIN traffic_median AS t
CROSS JOIN engagement_median AS e

WHERE w.avg_daily_visitors > t.median_visitors
  AND w.avg_pages_per_user < e.median_pages_per_user

ORDER BY w.avg_daily_visitors DESC;
-- Business insight
-- A meaningful portion of websites attract relatively high traffic without achieving above-median user engagement. 
-- This shows that visitor volume alone is not a sufficient measure of website success. The company should also focus on content quality, 
-- navigation, and features that encourage users to explore multiple pages.











-- Question 9:
-- Which websites have low traffic but high engagement?
-- Low traffic = below or equal to the median visitor count
-- High engagement = above the median pages-per-user value
-- We aggregate to one row per website before calculating
-- the medians.
-- 
WITH website_level AS (

    SELECT
        Website,

        AVG(Avg_Daily_Visitors) AS avg_daily_visitors,

        AVG(Daily_Pageviews_per_user) AS avg_pages_per_user

    FROM websites_cleaned

    WHERE Avg_Daily_Visitors IS NOT NULL
      AND Daily_Pageviews_per_user IS NOT NULL

    GROUP BY Website
),
-- Calculate the median traffic
ordered_traffic AS (

    SELECT
        Website,
        avg_daily_visitors,

        ROW_NUMBER() OVER (
            ORDER BY avg_daily_visitors
        ) AS row_num,

        COUNT(*) OVER () AS total_rows

    FROM website_level
),
traffic_median AS (

    SELECT
        AVG(avg_daily_visitors) AS median_visitors

    FROM ordered_traffic

    WHERE row_num IN (
        FLOOR((total_rows + 1) / 2),
        CEIL((total_rows + 1) / 2)
    )
),
-- Calculate the median engagement
ordered_engagement AS (

    SELECT
        Website,
        avg_pages_per_user,

        ROW_NUMBER() OVER (
            ORDER BY avg_pages_per_user
        ) AS row_num,

        COUNT(*) OVER () AS total_rows

    FROM website_level
),
engagement_median AS (

    SELECT
        AVG(avg_pages_per_user) AS median_pages_per_user

    FROM ordered_engagement

    WHERE row_num IN (
        FLOOR((total_rows + 1) / 2),
        CEIL((total_rows + 1) / 2)
    )
)
-- Find websites with low traffic but high engagement
SELECT
    w.Website,

    ROUND(w.avg_daily_visitors, 2)
        AS website_avg_daily_visitors,

    ROUND(w.avg_pages_per_user, 2)
        AS website_avg_pages_per_user,

    ROUND(t.median_visitors, 2)
        AS median_visitors,

    ROUND(e.median_pages_per_user, 2)
        AS median_pages_per_user

FROM website_level AS w

CROSS JOIN traffic_median AS t
CROSS JOIN engagement_median AS e

WHERE w.avg_daily_visitors <= t.median_visitors
  AND w.avg_pages_per_user > e.median_pages_per_user

ORDER BY w.avg_pages_per_user DESC;

-- Business insight
-- Website traffic and user engagement measure different aspects of performance. Some websites attract relatively few visitors but 
-- generate substantial interaction from those users. Therefore, the company should not evaluate potential design ideas only by studying the 
-- largest websites; smaller websites may provide useful examples of strong engagement and loyal user behavior.











-- Question 10:
-- What profile should our new children-focused platform aim for?
--
-- Business purpose:
-- Summarize the strongest characteristics associated with
-- traffic and engagement.
--
-- We compare child safety, privacy, and trustworthiness
-- together with website performance.
SELECT
    Child_Safety,
    Privacy,
    Trustworthiness,

    COUNT(DISTINCT Website) AS unique_websites,

    ROUND(AVG(Avg_Daily_Visitors), 2)
        AS avg_daily_visitors,

    ROUND(AVG(Daily_Pageviews_per_user), 2)
        AS avg_pages_per_user,

    ROUND(AVG(Month_Average_Daily_Pageviews), 2)
        AS avg_monthly_pageviews

FROM websites_cleaned

WHERE Child_Safety IS NOT NULL
  AND Privacy IS NOT NULL
  AND Trustworthiness IS NOT NULL

GROUP BY
    Child_Safety,
    Privacy,
    Trustworthiness

HAVING COUNT(DISTINCT Website) >= 10

ORDER BY
    avg_daily_visitors DESC;

-- Observation
-- The analysis indicates that websites with stronger trustworthiness and privacy classifications generally show stronger performance 
-- across traffic and engagement metrics. The strongest combinations of child safety, privacy, and trustworthiness also tend to show better 
-- overall performance, although results vary between categories.

-- Business insight
-- The new children-focused platform should prioritize a combination of strong child-safety controls, excellent privacy protection, 
-- and trustworthy design rather than focusing on traffic alone. These features can support user confidence while creating a safer and 
-- more valuable experience.