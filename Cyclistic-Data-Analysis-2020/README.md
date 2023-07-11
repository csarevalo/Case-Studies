# Cyclistic Data Analysis 2020

**By** Cristian Arevalo 

**Last Updated** July 10, 2023

## About this Project
This case study is my capstone project for the Google Data Analatics Professional Certificated (via Coursera).

Here, I assume the role of a junior data analyst working in a marketing analyst team at Cylistic, a fictional bike-share company stationed in Chicago based on [Divvy](https://divvybikes.com) bikes. The objective is to understand how casual riders and annual members use Cyclistic bikes differently. These insights will help the marketing team to develop new marketting strategies to convert casual riders into annual members. But first, Cyclistic executives must be compelled with data insights and professional data visualizations.

***Special Notes***: 

All data cleaning and analysis is accomplish through the use of *SQL* in *Google CLoud BigQuery (Sandbox Edition)*. Python is used to upload large datasets (over 10MBs), the rest are manually uploaded through the site from csv files.

The analysis is based on the Divvy case study "'Sophisticated, Clear, and Polished’: Divvy and Data Visualization" written by Kevin Hartman ([found here]( https://artscience.blog/home/divvy-dataviz-case-study))

## Introduction
<img src="https://github.com/csarevalo/Case-Studies/blob/cbcdc43ae32a54666f73902b52cce8ff2130137c/Cyclistic-Data-Analysis-2020/images/cyclist2.png">

Cyclistic is a bike-share company based in Chicago, USA. In 2016, Cyclistic Launched a successful bike-share program offering bike rentals throughout the city. Since then, the program has expanded to a fleet over 5,800 bicyclesk that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

<p align="center">
  <img src = "https://github.com/csarevalo/Case-Studies/blob/4d3f62ffda82b91eaf0586ab1a65ab92b10ec643/Cyclistic-Data-Analysis-2020/images/divvy-bicycles.png" alt="Image" width="650">
</p>

<h5 align="center"> <a href="https://divvybikes.com">Divvy</a> Bikes Stationed in Chicago</h5>

Customers are divided into two classes: casual riders (those who purchase either the single-ride or full-day passes) and Cyclistic members (who purchase annual memberships). 

Until now, Cyclistic's marketing strategy relied on building general awareness and appealing to broad consumer segments. The flexible pricing plans (single-ride passes, full-day passes, and annual memberships) aided in bringing in new customers.

Although pricing flexibility helps in attracking new customers, Cyclistic's finance analyst have concluded that annual members are much more profitable than casual riders. The director of marketting (Lily Moreno) believes that increasing the number of annual members will be the key to future growth. Since casual riders have chosen Cyclistic for their mobility needs and are already aware of the annual membership program, a marketing strategy aimed at converting casual riders into members is to be held.

### Business Task

The marketing team would like to know:
* How do annual members and casual riders use Cyclistic bikes differently?
* Why would casual riders buy Cyclistic annual memberships?
* How can Cyclistic use digital media to influence casual riders to become members?

Specifically, my focus will revolve around on ***how do annual members and casual riders use Cyclistic bikes differently***.

## About Data Sources

* Historical trip data is publicly available [here](https://divvy-tripdata.s3.amazonaws.com/index.html) (Note: The datasets have different names because Cyclistic is a fictional company).

* The data has been made available by Motivate International Inc. under this [liscense](https://ride.divvybikes.com/data-license-agreement).

* Data is reliable, original, comprehensive, and cited. Since only trips occuring in 2020 are studied. Thus, the data is not current. **It mostly ROCCCs**!

* The data collected contains ride ids, rideable type, start/end timestamps, station names & ids, latitude & longitude, and usertype. Overall, 13 parameters.

## Prep Work

### Step 1: Collect Data

* Download Divvy datasets containing all trip data occuring in 2020 (Jan-Dec).

* Uploaded Divvy datasets (csv files) individuall through browser in Google Cloud BigQuery (Sandbox)

* Files that were too large were uploaded via python script ([shown here](https://github.com/csarevalo/Case-Studies/blob/0c5a0745d1742ce9c8195db2f770e81325d5f2de/Cyclistic-Data-Analysis-2020/python-code/upload_df_to_gbq_v5.py))

### Step 2: Wrangle Data and Combine into a Single File

* Once uploaded, compare schemas (column names, type,...) for each of the tables.

* Inspect the tables (through preview) and look for incongruencies

***Notes***:

* Though column names matched, column types differed accross tables. The reason being that I did not format the dataframe in python prior to uploading (useful for the future).

* From Jan 2020 to Nov 2020, station ids were purely numeric. On Dec 2020, alphanumeric station ids were added; however, on several occasions their previous numeric ids were also used. (this created a need to change column type from integer to string and select a specific id)

**The following code is ran for multiple tables to correct column types.**

```sql
CREATE OR REPLACE TABLE `project.dataset.table` AS (
  SELECT * REPLACE (
    CAST(started_at AS TIMESTAMP) AS started_at, 	
    CAST(ended_at AS TIMESTAMP) AS ended_at, 
    CAST(start_station_id AS STRING) AS  start_station_id, 
    CAST(end_station_id AS STRING) AS end_station_id 
    )
  FROM `project.dataset.table`);
```

**Then, a new table containing all trip data occuring in 2020 is created.**

```sql
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020`
SELECT * FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020_*`;
```

* This makes use of naming conventions (specifically, *similar names*) to combine all data from 2020 into a single table.

### Step 3: Clean Up and Add Data to Prepare for Analysis

* Inspect the new table that has been created

  - Column names and type look great (they match)
  
  - Station names and/or ids (check for and remove duplicates)
 
  - There is no trip duration (create field and scrutinize)
 
  - Check for distinct values across columns (all good here)

***Notes***
1. Some station names can have more than one id (create new unique station ids)

  * Prior to Dec ids were unique intergers, afterward alphanumeric ids were added but old ids were still being used.

  * The result, the station id is sometimes in accordance with the previous data, at times missing, and at others a combination of alphanumeric characters.

2. There are some station names that corresponds to quality checks

  * Filter them out when interest on insights only about customers

  * Relevant NEW IDS: 310, 311, 312, 631, 455, and 45 (hubbard warehouse)

3. The data can only be aggregated at the ride-level, which is too granular.
  * 

### Data CLeaning and Manipulation








