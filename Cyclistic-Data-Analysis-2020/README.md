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

* Files that were too large were uploaded via this python script ([shown here](python-code/upload_df_to_gbq_v5.py)).


### Step 2: Wrangle Data and Combine into a Single Table
#### Preliminary Inspection
Once data is uploaded, it is important to compare schemas (e.g. column names and data type) for each of the tables and inspect the tables through preview to look for incongruencies. Here are the results:

* Though column names matched, column types differed accross tables.

  - The reason being that I did not format the dataframe in python prior to uploading (useful for the future).

* From Jan 2020 to Nov 2020, station ids were purely numeric. On Dec 2020, alphanumeric station ids were added; however, on several occasions their previous numeric ids were also used.

  - It is necessary to change data type for station ids from INT64 to STRING.

  - There is also a need for new and unique ids for the stations.

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

The following query is used to create a new table, called **divvy_trips_2020** for reference, containing all trip data occuring in 2020 is created.
* Additionally, this query makes use of naming conventions (specifically, *similar names*) to combine all data from 2020 into a single table.

```sql
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`
SELECT * FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020_*`;
```

#### Inspecting Combined Trip Data
Briefly skiming the new table shows that:

- Column names and type look great (they match).

- Station names and ids need to be checked for duplicates (to remove them).

- There is no trip duration among the columns to compare casual riders with members (there is a need to create the field and scrutinized it for abnormal ride lengths).

- Check for distinct values across columns (all good here: 2 usertypes, 3 ridable types; station information needs to be verified seperatly, latitude and longitude values are not unique per station).

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

    * Relevant NEW IDS: 310, 311, 312, 631, 455, and 45

      - Hubbard st bike checking (Lbs-wh-test) (id=311),
      - HQ QR (id=310),
      - Watson Testing-divvy (id=631); **new id is 633**
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
* The source for the following query comes from [stackoverflow](https://stackoverflow.com/questions/58716640/bigquery-check-entire-table-for-null-values)

```sql
SELECT column_name, COUNT(1) AS nulls_count
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020` as table1,
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
  FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020` 
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


#### Creating A New Table Containing Station Info
Due to the present duplicate data occuring in start & end stations, there is a need to fix the problem to not have excess information and be concise. A way to address these stations is by creating a new table as a list of station information. The desired parameters will be **station_name**, **station_id**, **lat**, **lng**, and later down the line we will add the number of users per *member_casual* as **member_riders** and **casual_riders** (to display overall station activity for marketing purposes).

A summary of the steps taken to create a new table showcasing the station info is presented below (meanwhile, the full query will be available [here](sql-queries/step-2_9-create-divvy_station_2020.sql)):


1. The new table will be called *divvy_stations_2020*.

1. We begin by identifying unique station names from start & end station names, fixing duplicates to only present unique station names.

1. Then, we create unique station ids that correspond to only one station.

1. Finally, we average the latitude and longitude values of all ride trips corresponding to the stations to determine the **lat** and **lng** geo-location of each station.

    * Now that we have the most basic station information, we need consider the trip data from 2020 where we notice that the geo-location can be different for the same station.

    * Latitude / Longitude values for the stations are included in the same row as each ride’s information. Since each bike has its own GPS device, there is slight variance in the lat/long values of every station per ride. However, each station can only have one unique geo-location, so we take mean value for all respective lat/long values of a station.
  
    * These values are then used to replaced the start and end station lat/long values for each ride.


#### Cleaning Operations
Now that we have established a solid foundation of information about each station, we will use this data (station_name, station_id, lat, lng) to replace the trips corresponding information about start & end stations. The full query is available [here] (link), however below I will discussion a brief overview of the steps taken.

1. The goal of this new query is to create a new version of *divvy_trip_data* (*v2*), where certain cases are excluded, to make analysis of the trip data easier.

1. Rides are removed when:
    - Station names are missing (meaning they are NULL) from *start* or *end station names* because **these rides cannot be tracked**.
        * The new station ids will be assigned based on their station names. 
  
    - Trip durations that are less than 60 seconds because **these *ride lengths* are similar to a false start**.
        * Moreover, the first minute of all rides are charged a fix fee (even if rides are less than a minute).
  
    - Trip durations are greater than 24 hours because **Cyclistic bikes are spected to be returned to an appropriate station once they are no longer being used**.
        * Keeping a bike longer than a day is synonymous to stealing it and such cases result in an additional fee.

1. Station names are altered to prevent duplicate names.
    - Duplicates end with a word or symbol in parathesis.
  
    - This makes implementing new station ids smoother.
  
1. Using **divvy_stations_2020**, station information is updated for both *start & end stations*.
    - Specifically, the following parameters are updated (8 parameters total):
      
        * Station name
        * Station id
        * Starting latitude
        * Startting longitude

1. Additional data is added to aggregate trip info more easily during analysis
    - The following fields of data are implemented:
      
        * Starting month number (1-12) as **month_num**
        * Starting month name as **starting_month**
        * Starting day of the week (number) as **weekday_num** [1-7]
        * Starting day of the week as **weekday** [Sun-Sat]
        * Trip duration as **ride_length** measured in seconds



#### Manipulating Data
After the cleaning operation, our data is nearly ready for analysis. But before that, we manipulate it to ease our analysis.
* The total number of members and casual riders visiting any station holds potential in identifying key differences among Cyclistic users. We can figure out the total rides from starting and ending stations by grouping data and counting the rows in a query.


## Data Summary

The data can be summarized as below:

* Total number of stations is **669**.

* Out 3.54 million rows of trip data, **3.3 million rides** remain.
    - this data was removed (elaborate)
 
    - less than a min (and reason: less than 0 bad and less than 1min is false start or set price) and more than a day (and reason: stolen? must return!)
 
    - what other data was removed and why

* Out of the 3.4 million rides, **61.6%** were taken by subscribers and **38.4%** were taken by casual customers.

* Average ride by a casual biker is **46 minutes** long, while by a subscriber is **12 minutes** long.


| summary_of | started_with | ended_with | eliminated | retained (%) |
| ---------- | ------------ | ---------- | ---------- | ------------ |
| rides      | 3,541,683    | 3,330,296  | 211,387    | 94.031 |
| stations   | 696          | 683        | 13         | 98.132 |





































