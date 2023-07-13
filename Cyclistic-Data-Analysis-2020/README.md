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

Cyclistic is a bike-share company based in Chicago, USA. In 2016, Cyclistic Launched a successful bike-share program offering bike rentals throughout the city. Since then, the program has expanded to a fleet over 5,800 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

<p align="center">
  <img src = "https://github.com/csarevalo/Case-Studies/blob/4d3f62ffda82b91eaf0586ab1a65ab92b10ec643/Cyclistic-Data-Analysis-2020/images/divvy-bicycles.png" alt="Image" width="650">
</p>

<p align="center"> <strong> <a href="https://divvybikes.com">Divvy</a> Bikes Stationed in Chicago </strong></p>

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

* Data is reliable, original, comprehensive, and cited. Since only trips occuring in 2020 are studied, the data is not current. **It mostly ROCCCs**! However, it is **not** adviseable to make full business decisions based on this data.
  - For business decisions, it is recommended to use current data (from 2022/23). 

* The data collected contains ride ids, rideable type, start/end timestamps, station names & ids, latitude & longitude, and usertype. Overall, 13 parameters.


## Prep Work
The data is downloaded, skimmed, prepared, cleaned, and manipulated. This section deals with all the dirty work prior to the actual analysis and visualization. The prep-work lays the foundation of our data problem solving, and takes more than twice the time and effort as the analysis.

If you are more interested with the analysis, and results, you can jump ahead to [Data Summary] (link here).

### Step 1: Collect Data
* Download Divvy datasets containing all trip data occuring in 2020 (Jan-Dec).

* Uploaded Divvy datasets (csv files) individuall through browser in Google Cloud BigQuery (Sandbox).

* Files that were too large were uploaded via python script ([shown here](https://github.com/csarevalo/Case-Studies/blob/0c5a0745d1742ce9c8195db2f770e81325d5f2de/Cyclistic-Data-Analysis-2020/python-code/upload_df_to_gbq_v5.py)).


### Step 2: Wrangle Data and Combine into a Single Table
* Once uploaded, compare schemas (e.g. column names and data type) for each of the tables.

* Inspect the tables (through preview) and look for incongruencies.

#### Results
* Though column names matched, column types differed accross tables.

  - The reason being that I did not format the dataframe in python prior to uploading (useful for the future).

* From Jan 2020 to Nov 2020, station ids were purely numeric. On Dec 2020, alphanumeric station ids were added; however, on several occasions their previous numeric ids were also used.

  - Change data type for ids from INT64 to STRING. There is also a need for new unique ids that remains.

#### Fixing Column Data Type
The following query is ran for multiple tables to correct column types.

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

#### Combine Trip Data
The bike trip data is divided into 10 tables, however we interested in looking at all rides occuring during 2020. 

The following query is used to create a new table containing all trip data occuring in 2020 is created.
* The new table will be called **divvy_trips_2020** for reference.

* This query makes use of naming conventions (specifically, *similar names*) to combine all data from 2020 into a single table.

```sql
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020`
SELECT * FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020_*`;
```

#### Inspecting Combined Trip Data
Briefly skiming the new table shows that:

- Column names and type look great (they match)

- Station names and ids (check for and remove duplicates)

- There is no trip duration for comparing casual riders with members (create field and scrutinize)

- Check for distinct values across columns (all good here)

There is still a need to check for nulls or missing values.


### Step 3: Clean Up and Add Data to Prepare for Analysis
#### ***Key Problems and Solutions***
The first part of tidying data is look for issues/concerns regarding the data. Here are some of them:

1. Some station names can have more than one id.
    * *Create* new unique station ids.
    
    * Prior to December ids were unique intergers, afterward alphanumeric ids were added but old ids were still being used.

    * The result, the station id is sometimes in accordance with the previous data, at times missing, and at others a combination of alphanumeric characters.

1. Some station names have duplicates that end with a word or symbol in parathesis.

    * *Establish* a single unique name per station.
  
    * There are two sources of duplicates: those that end with "(*)" and those that end with "(Temp)".

1. There are some station names that corresponds to quality checks or other.
    * *Filter* these stations when interest on insights only about customers

    * Relevant NEW IDS: 310, 311, 312, 631, 455, and 45 (hubbard warehouse)

      - Hubbard st bike checking (Lbs-wh-test) (id=311),
      - HQ QR (id=310),
      - Watson Testing-divvy (id=631)
      - Hubbard_test_lws (id=312)
      - Base-2132 W Hubbard Warehouse (id=45)
      - Mt1-Eco5.1-01 (id=455)

1. The data can only be aggregated at the ride-level, which is too granular.
    * *Add additional columns* of data, such as the **weekday** & **month** when trips begin. This provide additional opportunities to aggregate the data.

1. There is no field measuring *trip duration*.
    * *Create* a new column indicating **ride_length** and *Scrutinize* ride duration.
  
    * This presents more opportunities to compare user behavior between casual and member riders.

1. Additionally, there are some rides were trip durations are negative.
    * *Remove* bad data.
    
    * This includes several hundred rides where Divvy took bikes out of circulation for Quality Control reasons.

    * This may also correspond to early cancellation times of rides by users.
  
1. Some crucial data is missing in columns with Null values.
    * These instances are represented by Null values and it is important to be aware of them for data cleaning.

#### Checking For Missing Data
First order of business is finding out if anything important is missing from the data, so we *check* which columns contain NULLS using the following query.

```sql
SELECT column_name, COUNT(1) AS nulls_count
FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020` as table1,
UNNEST(REGEXP_EXTRACT_ALL(TO_JSON_STRING(table1), r'"(\w+)":null')) column_name
GROUP BY column_name
ORDER BY nulls_count DESC
```

**Results**

After checking for nulls or missing data, we discover that some important information is missing from the trips: *start/end station names & ids*. 
* Without this information we can't track the trips, which means we need to *remove these instances*. Before proceeding to do delete rows, we need to identify if there is anything else we need look out for when cleaning the data.

The table below showcases which columns have missing information and how many rows are missing. 

| column_name	       | nulls_count  |
| :----------        | ----------:  |
| end_station_id     | 111342       |
| end_station_name   | 110881       |
| start_station_id   | 95282        |
| start_station_name | 94656        |
| end_lat            | 4255         |
| end_lng            | 4255         |


#### Checking For Duplicate Data 
A common problem often encounter while cleaning data is *duplicate names*, which we'll tackle in this section. Specifically, we will be looking for duplicate station names or multiple ids for one station using the following query.

```sql
WITH all_stations AS (
  SELECT start_station_name, start_station_id, end_station_name, end_station_id
  FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020` 
)
SELECT DISTINCT station_name, station_id
FROM ( (SELECT DISTINCT start_station_name AS station_name, start_station_id AS station_id FROM all_stations)
UNION ALL (SELECT DISTINCT end_station_name AS station_name, end_station_id AS station_id FROM all_stations)
)
GROUP BY station_name, station_id
ORDER BY station_name
```

**Results**

After querying a list of stations with their respective ids, the outcome is downloaded as a csv file to view in EXCEL (unfortunately, some station names were cut off when viewing the table in BigQuery). 
* A quick and up-close inspection confirms the source of duplicate data: "(*)" and "(Temp)". 

* Additionally, multiple ids are often found for the same station.

Below are two primary examples showcasing duplicates by either having the different ids or names.

| station_name | station_id |
| :----------- | ---------: | 
| Damen Ave & Walnut (Lake) St | 656 |
| Damen Ave & Walnut (Lake) St | KA17018054 |
| Damen Ave & Walnut (Lake) St (*) | 656 |
| Wentworth Ave & Cermak Rd | 120 | 
| Wentworth Ave & Cermak Rd	| 13075 |
| Wentworth Ave & Cermak Rd (Temp)	| 120 |


#### Manipulating Data
After the cleaning operation, our data is nearly ready for analysis. But before that, we manipulate it to ease our analysis.
* Latitude / Longitude values for the stations are included in the same row as each ride’s information. Since each bike has its own GPS device, there is slight variance in the lat/long values of every station per ride. However, each station can only have one unique geo-location, so we take mean value for all respective lat/long values of a station. These values are then used to replaced the start and end station lat/long values for each ride.

* 


## Data Summary

The data can be summarized as below:

* Total number of stations is **669**.

* Out 3.54 million rows of trip data, **3.3 million rides** remain.
    - this data was removed (elaborate)
 
    - less than a min (and reason: less than 0 bad and less than 1min is false start or set price) and more than a day (and reason: stolen? must return!)
 
    - what other data was removed and why

* Out of the 3.4 million rides, **61.6%** were taken by subscribers and **38.4%** were taken by casual customers.

* Average ride by a casual biker is **46 minutes** long, while by a subscriber is **12 minutes** long.




#### Preparing and Cleaning
this bullet should go at the top of **STEP 3**
* The full query to clean clean and add data is available [here] (0) and is also **progressively detailed [here] (link needed)**.




### Step 3.1: Breakdown of Creating a New Table with SQL
* Due to various nulls in station names & ids, and other concerns outlined in **Step 3**, there is a need to create a new table without any of the undesirable traits mentioned above.

* The whole query is available [here](https://github.com/csarevalo/Case-Studies/blob/d4eb3479ac0b2a925180045230226046771f0d9d/Cyclistic-Data-Analysis-2020/sql-queries/step3_create_table_w_clean_data.sql)

* Moreover, a breakdown of how to create the desired table is provided [here] (need link)
 
Here, I will provide a brief summary of the steps taken to **Create a new version of combined 2020 trip data where unnecessary or bias data is removed**
































