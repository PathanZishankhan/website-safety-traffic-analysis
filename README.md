# Website Safety, Privacy and Traffic Analysis

## Project Overview

This project uses MySQL to analyze website traffic, user engagement, child safety, privacy, and trustworthiness ratings.

The project was developed around a fictional business scenario in which a company wants to build a children-focused website or digital platform. The objective is to understand which characteristics are associated with website popularity, user engagement, and a safer online experience.

The analysis focuses on transforming raw website data into meaningful business insights.

---

## Business Problem

A company planning to develop a children-focused platform wants to understand:

- Which website characteristics are associated with higher traffic?
- Do privacy and trustworthiness relate to stronger user engagement?
- Are highly visited websites also highly engaging?
- Which combinations of child safety, privacy, and trustworthiness perform well?
- What characteristics should the new platform prioritize?

---

## Dataset

The dataset contains information about websites from different countries, including:

- Website name
- Country
- Country rank
- Traffic rank
- Average daily visitors
- Monthly average reach
- Monthly average pageviews
- Daily pageviews per user
- Child safety classification
- Privacy classification
- Trustworthiness classification
- Website status

The raw dataset was preserved separately, while a working copy was created for cleaning and analysis.

---

## Tools Used

- MySQL
- SQL
- Visual Studio Code
- Git and GitHub

---

## Project Workflow

### 1. Data Import

The raw CSV dataset was imported into MySQL using `LOAD DATA LOCAL INFILE`.

### 2. Data Cleaning

The cleaning process included:

- Creating a separate analysis copy
- Removing irrelevant columns
- Trimming unnecessary spaces
- Removing spaces from numeric values
- Converting missing-value indicators such as `N/A` and `NA` into `NULL`
- Converting numeric columns from text into appropriate numeric data types
- Checking for negative or invalid values

### 3. Data Quality Checks

The dataset was checked for:

- Missing values
- Duplicate records
- Invalid numeric values
- Numeric ranges
- Distinct values in categorical columns
- Repeated website names across countries

### 4. Business Analysis

The analysis explored:

1. The overall website landscape
2. Website traffic by country
3. The relationship between privacy and user engagement
4. The relationship between trustworthiness and website popularity
5. The combined effect of child safety, privacy, and trustworthiness
6. The difference between website popularity and user engagement
7. Websites with high traffic but low engagement
8. Websites with low traffic but high engagement
9. The characteristics of a potential children-focused platform

---

## Key Insights

- Website traffic is highly skewed because a small number of extremely popular websites have very large visitor counts.
- Median traffic is therefore more useful than average traffic when separating high-traffic and low-traffic websites.
- Websites with stronger privacy classifications generally show higher average pages per user.
- Websites classified as highly trustworthy tend to have stronger traffic and reach, although the relationship is not perfectly consistent.
- Website popularity and user engagement are different performance measures.
- Some websites attract many visitors but have relatively low engagement.
- Some smaller websites have lower traffic but stronger engagement.
- A successful children-focused platform should prioritize child safety, privacy, and trustworthiness rather than focusing only on visitor numbers.

These findings show associations in the dataset and should not be interpreted as proof that one characteristic directly causes another.

---

## Project Structure

```text
website-safety-traffic-analysis/
│
├── data/
│   └── raw/
│        └──Web_Scrapped_websites.csv
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_data_profiling.sql
│   ├── 03_data_cleaning.sql
│   └── 04_data_analysis.sql
│
|
│
├── README.md
└── .gitignore