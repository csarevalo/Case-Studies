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

* Uploaded Divvy datasets (csv files) individuall through browser in Google Cloud BigQuery (Sandbox).

* Files that were too large were uploaded via python script ([shown here](https://github.com/csarevalo/Case-Studies/blob/0c5a0745d1742ce9c8195db2f770e81325d5f2de/Cyclistic-Data-Analysis-2020/python-code/upload_df_to_gbq_v5.py)).


### Step 2: Wrangle Data and Combine into a Single Table
* Once uploaded, compare schemas (column names, type,...) for each of the tables.

* Inspect the tables (through preview) and look for incongruencies.

***Notes***:
* Though column names matched, column types differed accross tables.

  - The reason being that I did not format the dataframe in python prior to uploading (useful for the future).

* From Jan 2020 to Nov 2020, station ids were purely numeric. On Dec 2020, alphanumeric station ids were added; however, on several occasions their previous numeric ids were also used.

  - Change data type for ids from INT64 to STRING. There is also a need for new unique ids that remains.


#### Fixing Column Data Type
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

#### Combine Trip Data
**Then, a new table containing all trip data occuring in 2020 is created.**
* We'll call this new table **divvy_trips_2020** for reference.

* This makes use of naming conventions (specifically, *similar names*) to combine all data from 2020 into a single table.

```sql
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020`
SELECT * FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020_*`;
```

### Step 3: Clean Up and Add Data to Prepare for Analysis
* Inspect the new table that has been created

  - Column names and type look great (they match)

  - Station names and ids (check for and remove duplicates)

  - There is no trip duration (create field and scrutinize)

  - Check for distinct values across columns (all good here)

* Check for nulls


#### ***Key Problems and Solutions***
The first part of tidying data is look for issues/concerns regarding the data. Here are some of them:

1. Some station names can have more than one id.
    * *Create* new unique station ids.
    
    * Prior to Dec ids were unique intergers, afterward alphanumeric ids were added but old ids were still being used.

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
    * *Add additional columns* of data -- such as the **weekday** & **month** when trips begin -- that provide additional opportunities to aggregate the data.

1. There are some rides were trip durations are negative.
    * *Remove* bad data.
    
    * This includes several hundred rides where Divvy took bikes out of circulation for Quality Control reasons.

    * This may also correspond to early cancellation times of rides by users.
  
1. Some crucial data is missing in columns with Null values.
    * These instances are represented by Null values and it is important to be aware of them for data cleaning.

#### Checking For Missing Data
First order of business is finding out if anything important is missing from the data, so we *check* which columns contain NULLS.

```sql
SELECT column_name, COUNT(1) AS nulls_count
FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020` as table1,
UNNEST(REGEXP_EXTRACT_ALL(TO_JSON_STRING(table1), r'"(\w+)":null')) column_name
GROUP BY column_name
ORDER BY nulls_count DESC
```

**Results**

After checking for nulls or missing data, we discover that some important information is missing from the trips: start/end station names & ids. Without this information we can't track the trips, so we need to *remove these instances* -- not right away though. Before proceeding to do so, we need to identify if there is anything else we need look out for. 

| column_name	       | nulls_count  |
| :----------        | ----------:  |
| end_station_id     | 111342       |
| end_station_name   | 110881       |
| start_station_id   | 95282        |
| start_station_name | 94656        |
| end_lat            | 4255         |
| end_lng            | 4255         |


#### Checking for duplicate data 
A common problem is *duplicate data*, which we'll tackle in the next section. 

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

After querying a list of stations with their respective ids, I download the it as a CSV file to view in EXCEL (some station names are cut off when viewing ing Google Cloud BigQuery). A quick and up-close inspection confirms the source of duplicate data. Below is two primary examples showcasing duplicates by either having the different ids or names.


| station_name | station_id |
| :----------- | ---------: | 
| Damen Ave & Walnut (Lake) St | 656 |
| Damen Ave & Walnut (Lake) St | KA17018054 |
| Damen Ave & Walnut (Lake) St (*) | 656 |
| Wentworth Ave & Cermak Rd | 120 | 
| Wentworth Ave & Cermak Rd	| 13075
| Wentworth Ave & Cermak Rd (Temp)	| 120 |








#### Preparing and Cleaning
Building on... key problems and solutions.

* After checking for nulls or missing data, we discover that some important information is missing from the trips: start/end station names & ids.
  - Without this information, we can't track the trips so we need to **remove these instances**.

* Additionally, since we are only interested in bike trips where we have trip durates

* After 



* The full query to clean clean and add data is available [here] (0) and is also **progressively detailed [here] (link needed)**.




### Step 3.1: Breakdown of Creating a New Table with SQL
* Due to various nulls in station names & ids, and other concerns outlined in **Step 3**, there is a need to create a new table without any of the undesirable traits mentioned above.

* The whole query is available [here](https://github.com/csarevalo/Case-Studies/blob/d4eb3479ac0b2a925180045230226046771f0d9d/Cyclistic-Data-Analysis-2020/sql-queries/step3_create_table_w_clean_data.sql)

* Moreover, a breakdown of how to create the desired table is provided [here] (need link)
 
Here, I will provide a brief summary of the steps taken to **Create a new version of combined 2020 trip data where unnecessary or bias data is removed**

1. Create a function to make station names into proper case

    * Example: "I wANt Bananas from 23RD ST!" ---> "I Want Bananas From 23rd St!"

2. Begin the statement to create the specific table with a desp

#### (1.1) **Create a function to make station names into Proper Case**
* Example: "I wANt Bananas from 23RD ST!" ---> "I Want Bananas From 23rd St!"

* Code is edited from [stackoverflow](https://stackoverflow.com/questions/51351948/proper-case-in-big-query)

```sql
CREATE TEMP FUNCTION PROPER(str STRING) AS ((
  SELECT STRING_AGG(CONCAT(UPPER(SUBSTR(w,1,1)), LOWER(SUBSTR(w,2))), '' ORDER BY pos) 
  FROM UNNEST(REGEXP_EXTRACT_ALL(str,  r'[[:^alnum:]]|[[:alnum:]]*')) w WITH OFFSET pos #uppercase alphanumeric substrings 
)); 
```

#### (1.2) **Begin creating new table for the will-be selected data**

```sql
-- CREATE OR REPLACE TABLE `divvy_trips_2020_data.divvy_trips_2020_v2`
CREATE TABLE IF NOT EXISTS `divvy_trips_2020_data.divvy_trips_2020_v2`
OPTIONS(
  description = "Removed cases where station names are missing (null), removed duplicates of station name, removed cases where trip duration is less than or equal to a min (60 secs), and also removed cases where trip duration is more a 24 hours...CAN cast station ids to INT64 but will leave as STRING."
) AS 

## TODO: INSERT WITH CLAUSE right here

```

#### (1.3) **Select all appropriate trip data from 2020, then filter out unnecessary trips with skewed ride length**
* This query alone produces 3,475,816 rows.

* Records of trips less than 1 min are removed because they can be **false starts** and are charged the same fee regardless (for a trip duration of 1 min or less).

* Bikes out longer than a day are also removed. During this scenario, bikes can be considered 'stolen' and riders are required to bring rideable back to an eligible station.

```sql
#### START OF WITH CLAUSE ####
WITH 
  ### Use combined datasets of all 2020 trip data
  ## Filter out when trip duration is less than or equal to zero(0) (~10k rows)
  divvy_trips_2020 AS (
    SELECT* FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020`
    WHERE (TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 60) #60secs
    AND (TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 60*60*24) #1day
  ),
```

#### (1.4) **Filter non-distinct duplicates and nulls from station names**
* This query produces 3,330,296 rows

* Although old station ids can be used to cross reference the start/end station names for trips that are not missing their respective start/end station names. Majority of the cases where the station names are missing occurs in both the start & end of the trip.

* Additionally, 95.81% of the rows from the *previous query* are retained. Only 145,520 rows are eliminated.

* Thus, this issues is negligible. 

```sql
  ## Filter non-distinct duplicates and nulls from station names
  station_names AS (SELECT ride_id, --edit: start/end station name
      CASE ENDS_WITH(start_station_name, "(*)")
        WHEN TRUE THEN RTRIM(start_station_name, " (*)") #removes trailing chars
        ELSE TRIM(start_station_name, " *") #removes leading & trailing chars
      END AS new_start_station_name, #--
      CASE ENDS_WITH(end_station_name, "(*)")
        WHEN TRUE THEN RTRIM(end_station_name, " (*)")
        ELSE TRIM(end_station_name, " *") 
      END AS new_end_station_name #--
    FROM divvy_trips_2020 
    WHERE start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL
  ),
```
#### (1.5) **Get list of distinct station names from start & end stations**
* This query produces 683 rows (or unique station names)

```sql
  ## Get distinct station names in LOWER case ("i want banana!")
  unique_station_names AS (
    SELECT DISTINCT station_name as unique_station_name
    FROM (
      (SELECT DISTINCT LOWER(new_start_station_name) as station_name FROM station_names)
      UNION ALL
      (SELECT DISTINCT LOWER(new_end_station_name) as station_name FROM station_names)
    )
  ),
```

#### (1.6) **Create unique station ids**
* This query produces 683 rows (or station names with unique ids)

```sql
  ## Create new station ids for distinct, non-duplicate stations and make station names PROPER case ("I Want Banana!")
  divvy_stations_2020 AS (
    SELECT
      IF(st_name='HQ QR', 'HQ QR', PROPER(st_name)) AS new_station_name,
      ROW_NUMBER() OVER(ORDER BY st_name) as new_station_id 
    FROM (SELECT DISTINCT unique_station_name as st_name FROM unique_station_names)
    ORDER BY new_station_id
  ),
```

#### (1.7) **Update start and end station info**
* This query produces 3,330,296 rows (with unique station names and ids)

```sql
  ## Assign new station ids (and names) to start stations
  new_start_station_info AS (
    SELECT station_names.ride_id, 
      divvy_stations_2020.new_station_name as new_start_station_name,
      divvy_stations_2020.new_station_id as new_start_station_id 
    #-- LEFT JOIN because station_names filters NULLS in start/end station names
    FROM station_names LEFT JOIN divvy_stations_2020 
    ON LOWER(station_names.new_start_station_name) = LOWER(divvy_stations_2020.new_station_name)
  ),

  ## Assign new station ids (and names) to end stations
  new_end_station_info AS (
    SELECT station_names.ride_id, 
      divvy_stations_2020.new_station_name as new_end_station_name,
      divvy_stations_2020.new_station_id as new_end_station_id 
    #-- LEFT JOIN because station_names filters NULLS in start/end station names
    FROM station_names LEFT JOIN divvy_stations_2020 
    ON LOWER(station_names.new_end_station_name) = LOWER(divvy_stations_2020.new_station_name)
  ),

  ## Update new station info for 2020 biketrip data
  divvy_trips_2020_updated_station_info AS (
    SELECT st1.ride_id,  
      st1.new_start_station_name, st1.new_start_station_id,
      st2.new_end_station_name, st2.new_end_station_id
    FROM new_start_station_info as st1 INNER JOIN new_end_station_info as st2
    ON st1.ride_id = st2.ride_id
  ),
```

#### (1.8) **Create final query for the new table**

```sql
  ## Create new version of 2020 divvy trip data because we are removing rows
  divvy_trips_2020_v2 AS (
    SELECT
      divvy_trips_2020.* 
      REPLACE (upd_st.new_start_station_name as start_station_name,
        upd_st.new_start_station_id as start_station_id,
        upd_st.new_end_station_name as end_station_name,
        upd_st.new_end_station_id as end_station_id),
      EXTRACT(MONTH FROM started_at) as month_num, # [1-12] --> [Jan-Dec]
      FORMAT_TIMESTAMP('%b', started_at) as starting_month, # [Jan-Dec]
      EXTRACT(DAYOFWEEK FROM started_at) as weekday_num, # [1-7] -> [Sun-Sat]
      FORMAT_TIMESTAMP('%a', started_at) as weekday,# [Sun-Sat]
      TIMESTAMP_DIFF(ended_at, started_at, SECOND) as ride_length
    FROM divvy_trips_2020_updated_station_info as upd_st
    LEFT JOIN divvy_trips_2020
    ON upd_st.ride_id = divvy_trips_2020.ride_id 
  )

### END OF WITH CLAUSE & ###
### END SUBQUERIES USED TO CREATE TABLE ###
```
#### (1.9) **Finish creating new table with clean data and additional data**

```sql
######## CREATE TABLE STATEMENT ########
SELECT*
FROM divvy_trips_2020_v2
ORDER BY started_at;
########################################
```

#### (1.10) **Sample of First 5 Rows - Ordered By Date**

| ride_id          | rideable_type | started_at                     | ended_at                       | start_station_name             | start_station_id | end_station_name               | end_station_id | start_lat | start_lng | end_lat | end_lng  | member_casuaL | month_num | starting_month | weekday_num | weekday | ride_length |
| ---------------- | ------------- | ------------------------------ | ------------------------------ | ------------------------------ | ---------------- | ------------------------------ | -------------- | --------- | --------- | ------- | -------- | ------------- | --------- | -------------- | ----------- | ------- | ----------- |
| 1068AB1B8F12FE23 | docked_bike   | 2020-01-01 00:04:44.000000 UTC | 2020-01-01 00:17:08.000000 UTC | Sheffield Ave & Wellington Ave | 532              | Ashland Ave & Belle Plaine Ave | 25             | 41.9363   | -87.6527  | 41.9561 | -87.6688 | casual        | 1         | Jan            | 4           | Wed     | 744         |
| 4DE50A4FC7687A0D | docked_bike   | 2020-01-01 00:11:14.000000 UTC | 2020-01-01 00:15:32.000000 UTC | Daley Center Plaza             | 182              | Dearborn St & Van Buren St     | 210            | 41.8842   | -87.6296  | 41.8763 | -87.6292 | member        | 1         | Jan            | 4           | Wed     | 258         |
| 1C78B5F337CBFC93 | docked_bike   | 2020-01-01 00:11:27.000000 UTC | 2020-01-01 00:13:15.000000 UTC | Sheridan Rd & Irving Park Rd   | 538              | Broadway & Sheridan Rd         | 62             | 41.9542   | -87.6544  | 41.9528 | -87.65   | member        | 1         | Jan            | 4           | Wed     | 108         |
| D231CE7990A3AA52 | docked_bike   | 2020-01-01 00:12:34.000000 UTC | 2020-01-01 00:14:29.000000 UTC | Delano Ct & Roosevelt Rd       | 211              | Wabash Ave & Roosevelt Rd      | 622            | 41.8675   | -87.6322  | 41.8672 | -87.626  | member        | 1         | Jan            | 4           | Wed     | 115         |
| 2295556346560999 | docked_bike   | 2020-01-01 00:19:12.000000 UTC | 2020-01-01 00:26:36.000000 UTC | Clark St & Leland Ave          | 141              | Southport Ave & Irving Park Rd | 556            | 41.9671   | -87.6674  | 41.9542 | -87.6644 | member        | 1         | Jan            | 4           | Wed     | 444         |


