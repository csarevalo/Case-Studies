<div>
    <span style="display: inline-flex; border-radius: 5px; background-color: #159957; background-image: linear-gradient(120deg, #155799, #159957);">
        <a href="https://csarevalo.github.io/Case-Studies/" class="btn" style="margin: 0; padding: 0.6rem 0.9rem;"><strong>My Case Studies</strong></a>
    </span>
</div>

<hr>

# **Cyclistic Case Study Analysis 2020** <a href="#the-title" id="the-title"></a>
Using Spreadsheets, Google Bigquery (SQL), and Tableau

**By** Cristian Arevalo 

**Last Updated** November 14, 2023

<p align="left">
    <a href="#the-title" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#table-of-contents" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#about-this-project" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p> 


## **Table of Contents**
<hr>

<p align="left">
    <a href="#the-title" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#about-this-project" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p> 


- [**Cyclistic Case Study Analysis 2020** ](#cyclistic-case-study-analysis-2020-)
  - [**Table of Contents**](#table-of-contents)
  - [**About This Project**](#about-this-project)
  - [**Introduction**](#introduction)
  - [**Defining The Problem**](#defining-the-problem)
    - [**Business Task**](#business-task)
  - [**About Data Sources**](#about-data-sources)
  - [**Prep Work**](#prep-work)
  - [**Step 1: Collect Data** ](#step-1-collect-data-)
  - [**Step 2: Wrangle Data and Combine into a Single Table** ](#step-2-wrangle-data-and-combine-into-a-single-table-)
    - [**Preliminary Inspection**](#preliminary-inspection)
    - [**Fixing Column Data Type**](#fixing-column-data-type)
    - [**Combine Trip Data**](#combine-trip-data)
    - [**Inspecting Combined Trip Data**](#inspecting-combined-trip-data)
  - [**Step 3: Clean Up and Add Data to Prepare for Analysis** ](#step-3-clean-up-and-add-data-to-prepare-for-analysis-)
    - [**Key Problems and Solutions**](#key-problems-and-solutions)
    - [**Checking For Missing Data**](#checking-for-missing-data)
    - [**Checking For Duplicate Data**](#checking-for-duplicate-data)
    - [**Creating Table About Stations**](#creating-table-about-stations)
    - [**Cleaning Operations**](#cleaning-operations)
    - [**Manipulating Data**](#manipulating-data)
  - [**Step 4: Perform Analysis** ](#step-4-perform-analysis-)
    - [**Cyclistic Weekly Analysis**](#cyclistic-weekly-analysis)
    - [**Cyclistic Monthly Analysis**](#cyclistic-monthly-analysis)
    - [**Cyclistic Time of Day Analysis**](#cyclistic-time-of-day-analysis)
    - [**Cyclistic Rideable Analysis**](#cyclistic-rideable-analysis)
    - [**Cyclistic Geographic Analysis**](#cyclistic-geographic-analysis)
  - [**Data Summary**](#data-summary)
  - [**Data Story: Cyclistic Bikeshare Analysis of 2020** ](#data-story-cyclistic-bikeshare-analysis-of-2020-)
    - [**Customer Usage**](#customer-usage)
    - [**Monthly Analysis**](#monthly-analysis)
    - [**Weekly Analysis**](#weekly-analysis)
    - [**Daily Analysis**](#daily-analysis)
    - [**Geographical Analysis**](#geographical-analysis)
    - [**Conclusion**](#conclusion)
  - [**Recommendations**](#recommendations)
  - [**Final Thoughts**](#final-thoughts)
    - [**Thank you for taking the time to read this case study** ](#thank-you-for-taking-the-time-to-read-this-case-study-)


## **About This Project**
<hr>

<p align="left">
    <a href="#table-of-contents" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#introduction" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>

This case study is my capstone project for the Google Data Analatics Professional Certificated (via Coursera).

Here, I assume the role of a junior data analyst working in a marketing analyst team at Cylistic, a fictional bike-share company stationed in Chicago based on [Divvy](https://divvybikes.com) bikes. The objective is to understand how casual riders and annual members use Cyclistic bikes differently by identifying trends and more. These insights will help the marketing team to develop new marketting strategies to convert casual riders into annual members. But first, Cyclistic executives must be compelled with data insights and professional data visualizations.

The main tools I use are spreadsheets/excel, SQL and Tableau. Here are the highlights:

* [Github: Cyclistic Data Analysis, Summary, and Story](#data-summary)

* [Tableau Story: Cyclistic Bikeshare in Chicago](#data-story)

A more in-depth breakdown of the case study scenario is included below, followed by my full report.


> **The analysis is based on the Divvy case study "'Sophisticated, Clear, and Polished’: Divvy and Data Visualization" written by Kevin Hartman ([found here]( https://artscience.blog/home/divvy-dataviz-case-study))**
 
> Additionally, all data cleaning and analysis is accomplish through the use of *SQL* in *Google CLoud BigQuery (Sandbox Edition)*. Python is used to upload large datasets (over 10MBs), the rest are manually uploaded through the site from csv files. Spreadsheets (Excel) is used to inspect data closely after being broken down through SQL queries. Finally, Tableau is used to provided compelling visuals.


## **Introduction** 
<hr>

<p align="left">
    <a href="#about-this-project" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#defining-the-problem" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>

<img src="images/logo/cyclist2.png">

Cyclistic is a bike-share company based in Chicago, USA. In 2016, Cyclistic Launched a successful bike-share program offering bike rentals throughout the city. Since then, the program has expanded to a fleet over 5,800 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

<p align="center">
  <img src = "images/divvy-bicycles.png" alt="Divvy Bikes in Chicago" width="650">
</p>

<p align="center"> <strong>Based on <a href="https://divvybikes.com">Divvy</a> Bikes Stationed in Chicago </strong></p>

Customers are divided into two classes: casual riders (those who purchase either the single-ride or full-day passes) and Cyclistic members (who purchase annual memberships). 

Until now, Cyclistic's marketing strategy relied on building general awareness and appealing to broad consumer segments. The flexible pricing plans (single-ride passes, full-day passes, and annual memberships) aided in bringing in new customers.

Although pricing flexibility helps in attracking new customers, Cyclistic's finance analyst have concluded that annual members are much more profitable than casual riders. The director of marketting (Lily Moreno) believes that increasing the number of annual members will be the key to future growth. Since casual riders have chosen Cyclistic for their mobility needs and are already aware of the annual membership program, a marketing strategy aimed at converting casual riders into members is to be held.


## **Defining The Problem**
<hr>

<p align="left">
    <a href="#introduction" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#business-task" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>

Lily, the director of marketing, and the marketing analytics team are looking for ways to convert Cyclistic's casual riders into annual members. The main problem is designing marketing strategies to accomplishing this task by identifying and understading the difference between casual riders & member riders in their usage of Cyclistic Bikeshare program. There are three questions that will guide the marketing team in their future marketing program.

The marketing team would like to know:

* How do annual members and casual riders use Cyclistic bikes differently?

* Why would casual riders buy Cyclistic annual memberships?

* How can Cyclistic use digital media to influence casual riders to become members?

Specifically, my focus will revolve around on ***how do annual members and casual riders use Cyclistic bikes differently***.

By looking at the data, we will be able to first get a broad sense of certain patterns that are occurring in the two different groups. Understanding the differences will provide more accurate customer profiles for each group. These insights will help the marketing analytics team design high quality targeted marketing for converting casual riders into members. For the Cyclistic executive team, these insights will help Cyclistic maximize the number of annual members and will fuel future growth for the company.

### **Business Task**
<p align="left">
    <a href="#defining-the-problem" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#about-data-sources" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>

> **Analyze historical bike trip data to identify trends in how annual members and casual riders use Cyclistic bikes differently.**


## **About Data Sources**
<hr>

<p align="left">
    <a href="#business-task" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
</p>

* Historical trip data is publicly available [here](https://divvy-tripdata.s3.amazonaws.com/index.html) (Note: The datasets have different names because Cyclistic is a fictional company).

* The data has been made available by Motivate International Inc. under this [liscense](https://ride.divvybikes.com/data-license-agreement).

* Data is reliable, original, comprehensive, and cited. Since only trips occuring in 2020 are studied, the data is not current. **It mostly ROCCCs**! However, it is **not** adviseable to make full business decisions based on this data.
  - For business decisions, it is recommended to use current data (from 2022/23). 

* The data collected contains ride ids, rideable type, start/end timestamps, station names & ids, latitude & longitude, and usertype. Overall, 13 parameters.


## **Prep Work**
<hr>

<p align="left">
    <a href="#about-data-sources" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#prep-work-step-1">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-heading-button.png" align="right">
    </a>
</p>

The data is downloaded, skimmed, prepared, cleaned, and manipulated. This section deals with all the dirty work prior to the actual analysis and visualization. The prep-work lays the foundation of our data problem solving, and takes more than twice the time and effort as the analysis.

If you are more interested with the analysis, and results, you can jump ahead to [Data Summary](#data-summary) or if you want a brief peak at how the analysis is performed please check out [Performing Analysis](#prep-work-step-4).

## **Step 1: Collect Data** <a href="#prep-work-step-1" id="prep-work-step-1"></a>
<hr>

<p align="left">
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

* Download Divvy datasets containing all trip data occuring in 2020 (Jan-Dec).

* Uploaded Divvy datasets (csv files) individuall through browser in Google Cloud BigQuery (Sandbox).

* Files that were too large were uploaded via this python script ([shown here](python-code/upload_df_to_gbq_v5.py)).


## **Step 2: Wrangle Data and Combine into a Single Table** <a href="#prep-work-step-2" id="prep-work-step-2"></a>
<hr>

<p align="left">
    <a href="#prep-work-step-1" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#prep-work-step-1" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#preliminary-inspection" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

### **Preliminary Inspection**
<p align="left">
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#fixing-column-data-type" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Once data is uploaded, it is important to compare schemas (e.g. column names and data type) for each of the tables and inspect the tables through preview to look for incongruencies. Here are the results:

* Though column names matched, column types differed accross tables.

  - The reason being that I did not format the dataframe in python prior to uploading (useful for the future).

* From Jan 2020 to Nov 2020, station ids were purely numeric. On Dec 2020, alphanumeric station ids were added; however, on several occasions their previous numeric ids were also used.

  - It is necessary to change data type for station ids from INT64 to STRING.

  - There is also a need for new and unique ids for the stations.

### **Fixing Column Data Type**
<p align="left">
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#preliminary-inspection" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#combine-trip-data" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

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

### **Combine Trip Data**
<p align="left">
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#fixing-column-data-type" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#inspecting-combined-trip-data" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

The bike trip data is divided into 10 tables, however we interested in looking at all rides occuring during 2020. 

The following query is used to create a new table, called **divvy_trips_2020** for reference, containing all trip data occuring in 2020 is created.
* Additionally, this query makes use of naming conventions (specifically, *similar names*) to combine all data from 2020 into a single table.

```sql
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`
SELECT * FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020_*`;
```

### **Inspecting Combined Trip Data**
<p align="left">
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#combine-trip-data" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Briefly skiming the new table shows that:

- Column names and type look great (they match).

- Station names and ids need to be checked for duplicates (to remove them).

- There is no trip duration among the columns to compare casual riders with members (there is a need to create the field and scrutinized it for abnormal ride lengths).

- Check for distinct values across columns (all good here: 2 usertypes, 3 ridable types; station information needs to be verified seperatly, latitude and longitude values are not unique per station).

There is still a need to check for nulls or missing values.


## **Step 3: Clean Up and Add Data to Prepare for Analysis** <a href="prep-work-step-3" id="prep-work-step-3"></a>
<hr>

<p align="left">
    <a href="#prep-work-step-2" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#inspecting-combined-trip-data" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#key-problems-and-solutions" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

### **Key Problems and Solutions**
<p align="left">
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#checking-for-missing-data" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

The first part of tidying data is look for issues/concerns regarding the data. Here are some of them:

1. Some station names can have more than one id.
    * *Create* new unique station ids.
    
    * Prior to December ids were unique intergers, afterward alphanumeric ids were added but old ids were still being used.

    * The result, the station id is sometimes in accordance with the previous data, at times missing, and at others a combination of alphanumeric characters.

2. Some station names have duplicates that end with a word or symbol in parathesis.

    * *Establish* a single unique name per station.
  
    * There are two sources of duplicates: those that end with "(*)" and those that end with "(Temp)".

3. There are some station names that corresponds to quality checks or other.
    * *Filter* these stations when interest on insights only about customers

    * Relevant NEW IDS: 310, 311, 312, 631, 455, and 45

      - HQ QR (id=310)
      - Hubbard st bike checking (Lbs-wh-test) (id=311)
      - Hubbard_test_lws (id=312)
      - Watson Testing-divvy (id=633)
      - Base-2132 W Hubbard Warehouse (id=45)
      - Mt1-Eco5.1-01 (id=455)

4. The data can only be aggregated at the ride-level, which is too granular.
    * *Add additional columns* of data, such as the **weekday** & **month** when trips begin. This provide additional opportunities to aggregate the data.

5. There is no field measuring *trip duration*.
    * *Create* a new column indicating **ride_length** and *Scrutinize* ride duration.
  
    * This presents more opportunities to compare user behavior between casual and member riders.

6. Additionally, there are some rides were trip durations are negative.
    * *Remove* bad data.
    
    * This includes several hundred rides where Divvy took bikes out of circulation for Quality Control reasons.

    * This may also correspond to early cancellation times of rides by users.
  
7. Some crucial data is missing in columns with Null values.
    * These instances are represented by Null values and it is important to be aware of them for data cleaning.

### **Checking For Missing Data**
<p align="left">
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#key-problems-and-solutions" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#checking-for-duplicate-data" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

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


### **Checking For Duplicate Data** 
<p align="left">
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#checking-for-missing-data" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#creating-table-about-stations" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

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
* A quick and top-close inspection confirms the source of duplicate data: "(*)" and "(Temp)". 

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


### **Creating Table About Stations**
<p align="left">
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#checking-for-duplicate-data" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#cleaning-operations" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Due to the present duplicate data occuring in start & end stations, there is a need to fix the problem to not have excess information and be concise. A way to address these stations is by creating a new table as a list of station information. The desired parameters will be **station_name**, **station_id**, **lat**, **lng**, and later down the line we will add the number of users per *member_casual* as **member_riders** and **casual_riders** (to display overall station activity for marketing purposes).

A summary of the steps taken to create a new table showcasing the station info is presented below (meanwhile, the full query will be available [here](sql-queries/step-2_9-create-divvy_station_2020.sql)):


1. The new table will be called *divvy_stations_2020*.

2. We begin by identifying unique station names from start & end station names, fixing duplicates to only present unique station names.

3. Then, we create unique station ids that correspond to only one station.

4. Finally, we average the latitude and longitude values of all ride trips corresponding to the stations to determine the **lat** and **lng** geo-location of each station.

    * Now that we have the most basic station information, we need consider the trip data from 2020 where we notice that the geo-location can be different for the same station.

    * Latitude / Longitude values for the stations are included in the same row as each ride’s information. Since each bike has its own GPS device, there is slight variance in the lat/long values of every station per ride. However, each station can only have one unique geo-location, so we take mean value for all respective lat/long values of a station.
  
    * These values are then used to replaced the start and end station lat/long values for each ride.

**Results**

The full table is available here: [cleaned](tables/divvy_stations_2020_cleaned.csv) and [uncleaned](tables/divvy_stations_2020_uncleaned.csv). Below are the first 5 results.

| station_name               | station_id | lat                | lng                 |
| -------------------------- | ---------- | ------------------ | ------------------- |
| 2112 W Peterson Ave        | 1          | 41.991161729691882 | -87.683592172455633 |
| 63rd St Beach              | 2          | 41.781052497804261 | -87.57612809187053  |
| 900 W Harrison St          | 3          | 41.8747676018918   | -87.649804773961    |
| Aberdeen St & Jackson Blvd | 4          | 41.877720779404484 | -87.654792138860145 |
| Aberdeen St & Monroe St    | 5          | 41.880414761538468 | -87.655516799346827 |
| Aberdeen St & Randolph St  | 6          | 41.884114663376479 | -87.654270784691533 |


### **Cleaning Operations**
<p align="left">
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#creating-table-about-stations" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#manipulating-data" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Now that we have established a solid foundation of information about each station, we will use this data (station_name, station_id, lat, lng) to replace the trips corresponding information about start & end stations. The full query is available [here](sql-queries/step-3-cleaning-and-adding-data.sql) and the verification of the results is available [here](sql-queries/step-3_5-verifying-clean-data.sql), however below I will discussion a brief overview of the steps taken.

1. The goal of this new query is to create a new version of *divvy_trip_data* (*v2*), where certain cases are excluded, to make analysis of the trip data easier.

2. Rides are removed when:
    - Station names are missing (meaning they are NULL) from *start* or *end station names* because **these rides cannot be tracked**.
        * The new station ids will be assigned based on their station names. 
  
    - Trip durations that are less than 60 seconds because **these *ride lengths* are similar to a false start**.
        * Moreover, the first minute of all rides are charged a fix fee (even if rides are less than a minute).
  
    - Trip durations are greater than 24 hours because **Cyclistic bikes are expected to be returned to an appropriate station once they are no longer being used**.
        * Keeping a bike longer than a day is synonymous to stealing it and such cases result in an additional fee.

3. Station names are altered to prevent duplicate names.
    - Duplicates end with a word or symbol in parathesis.
  
    - This makes implementing new station ids smoother.
  
4. Using **divvy_stations_2020**, station information is updated for both *start & end stations*.
    - Specifically, the following parameters are updated (8 parameters total):
      
        * Station name
        * Station id
        * Starting latitude
        * Startting longitude

5. Additional data is added to aggregate trip info more easily during analysis
    - The following fields of data are implemented:
      
        * Starting month number (1-12) as **month_num**
        * Starting month name as **starting_month**
        * Starting day of the week (number) as **weekday_num** [1-7]
        * Starting day of the week as **weekday** [Sun-Sat]
        * Trip duration as **ride_length** measured in seconds

**Results**

| ride_id          | rideable_type | started_at                     | ended_at                       | start_station_name           | start_station_id | end_station_name           | end_station_id | start_lat          | start_lng           | end_lat            | end_lng             | member_casuaL | month_num | starting_month | weekday_num | weekday | ride_length |
| ---------------- | ------------- | ------------------------------ | ------------------------------ | ---------------------------- | ---------------- | -------------------------- | -------------- | ------------------ | ------------------- | ------------------ | ------------------- | ------------- | --------- | -------------- | ----------- | ------- | ----------- |
| 99C72397983C1DF5 | docked_bike   | 2020-08-10 23:49:04.000000 UTC | 2020-08-11 12:49:16.000000 UTC | Lake Park Ave & 35th St      | 351              | Lake Park Ave & 35th St    | 351            | 41.831275652901688 | -87.6087894057451   | 41.831275652901688 | -87.6087894057451   | casual        | 8         | Aug            | 2           | Mon     | 46812       |
| 08306A0B4F8B9C44 | docked_bike   | 2020-08-10 23:49:04.000000 UTC | 2020-08-11 00:56:14.000000 UTC | Lake Park Ave & 35th St      | 351              | Lake Park Ave & 35th St    | 351            | 41.831275652901688 | -87.6087894057451   | 41.831275652901688 | -87.6087894057451   | casual        | 8         | Aug            | 2           | Mon     | 4030        |
| 7A3E9EC138E2D0AD | docked_bike   | 2020-08-10 23:49:17.000000 UTC | 2020-08-11 00:18:37.000000 UTC | Stockton Dr & Wrightwood Ave | 586              | Kedzie Ave & Milwaukee Ave | 333            | 41.931312260664328 | -87.638733542147918 | 41.929576232244784 | -87.707870112443771 | casual        | 8         | Aug            | 2           | Mon     | 1760        |
| 5858B7C1FC4A89A2 | docked_bike   | 2020-08-10 23:49:28.000000 UTC | 2020-08-11 00:57:04.000000 UTC | Lake Park Ave & 35th St      | 351              | Lake Park Ave & 35th St    | 351            | 41.831275652901688 | -87.6087894057451   | 41.831275652901688 | -87.6087894057451   | casual        | 8         | Aug            | 2           | Mon     | 4056        |
| CDF2EA7B3F5ED5FF | docked_bike   | 2020-08-10 23:49:48.000000 UTC | 2020-08-11 00:39:13.000000 UTC | Halsted St & 59th St         | 286              | Halsted St & 59th St       | 286            | 41.787533838414639 | -87.644880773373984 | 41.787533838414639 | -87.644880773373984 | casual        | 8         | Aug            | 2           | Mon     | 2965        |


**Verified**

Number of quality check uses in cleaned trip data

| member_casual | quality_check_users |
| ------------- | ------------------- |
| casual        | 71                  |
| member        | 197                 |

From the following stations:

| station_name                           | station_id |
| -------------------------------------- | ---------- |
| Base - 2132 W Hubbard Warehouse        | 45         |
| HQ QR                                  | 310        |
| Hubbard St Bike Checking (Lbs-Wh-Test) | 311        |
| Hubbard_Test_Lws                       | 312        |
| Mtl-Eco5.1-01                          | 455        |
| Watson Testing - Divvy                 | 633        |


### **Manipulating Data**
<p align="left">
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#cleaning-operations" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

After the cleaning operation, our data is nearly ready for analysis. But before that, we manipulate it to ease our analysis.
* The total number of members and casual riders visiting any station holds potential in identifying key differences among Cyclistic users. We can figure out the total rides from starting and ending stations by grouping data and counting the rows like this [query](sql-queries/step-3_9-manipulating-data.sql).

**Results: Top 5 Starting Stations**

| station_name             | station_id | lat                | lng                 | total_rides_from | total_rides_to | members_from_st | casuals_from_st | members_to_st | casuals_to_st |
| ------------------------ | ---------- | ------------------ | ------------------- | ---------------- | -------------- | --------------- | --------------- | ------------- | ------------- |
| Clark St & Elm St        | 135        | 41.902963895113132 | -87.631312305029311 | 31012            | 31180          | 19886           | 11126           | 20565         | 10615         |
| Kingsbury St & Kinzie St | 345        | 41.889192992430722 | -87.638501411531365 | 21882            | 21337          | 16260           | 5622            | 16454         | 4883          |
| St. Clair St & Erie St   | 564        | 41.894421578032492 | -87.622700546409931 | 21188            | 23853          | 15559           | 5629            | 17410         | 6443          |
| Dearborn St & Erie St    | 208        | 41.894004025551475 | -87.629318830077878 | 23559            | 24134          | 15453           | 8106            | 16039         | 8095          |
| Broadway & Barry Ave     | 56         | 41.937610986894825 | -87.644098303068489 | 23167            | 24057          | 15372           | 7795            | 15787         | 8270          |



## **Step 4: Perform Analysis** <a href="#prep-work-step-4" id="prep-work-step-4"></a>
<hr>

<p align="left">
    <a href="#prep-work-step-3" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#manipulating-data" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#cyclistic-weekly-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Now that the preliminary work is done we can begin conducting a detailed analysis on the data. But first we need to recall the goal: *to discover **how do annual members and casual riders use Cyclistic bikes differently***. The full query used for performing analysis is provided [here](sql-queries/step-4-conduct-analysis).

Specifically, we are interested in analyzing user behavior in the following ways:

1. Weekly

2. Monthly

3. Time of day

4. Type of rideable

5. And geographically

### **Cyclistic Weekly Analysis**
<p align="left">
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#cyclistic-monthly-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Riders behave very different based on weekly trips. During the weekly analysis, we scrutinize the following parameters:

* Usertype (member / casual)

* Weekday (number [1-7] & day [Sun-Sat])

* Average ride length (in secs & time duration)

* Max ride length

* Minimum ride length

* Number of rides

* And part of total rides 

**Resulting Table**

This table is available for [download here](tables/analysis_of/ride_data_by_weekday.csv).

| member_casual | weekday_num | weekday | avg_ride_len_secs | avg_ride_len | max_ride_len | min_ride_len | num_rides | part_of_tot_rides    |
| ------------- | ----------- | ------- | ----------------- | ------------ | ------------ | ------------ | --------- | -------------------- |
| casual        | 1           | Sun     | 2520              | 00:42:00     | 23:55:54     | 00:01:01     | 242713    | 0.072880308537139046 |
| casual        | 2           | Mon     | 2239              | 00:37:19     | 23:59:49     | 00:01:01     | 131039    | 0.039347553490740761 |
| casual        | 3           | Tue     | 2101              | 00:35:01     | 23:54:26     | 00:01:01     | 127485    | 0.038280381083243054 |
| casual        | 4           | Wed     | 2061              | 00:34:21     | 23:57:59     | 00:01:01     | 141395    | 0.04245718698878418  |
| casual        | 5           | Thu     | 2073              | 00:34:33     | 23:48:04     | 00:01:01     | 150913    | 0.045315191202223465 |
| casual        | 6           | Fri     | 2183              | 00:36:23     | 23:58:33     | 00:01:01     | 188455    | 0.056588063043044826 |
| casual        | 7           | Sat     | 2427              | 00:40:27     | 23:59:54     | 00:01:01     | 296754    | 0.089107394658012387 |
| member        | 1           | Sun     | 1044              | 00:17:24     | 23:29:04     | 00:01:01     | 254494    | 0.076417831928453209 |
| member        | 2           | Mon     | 857               | 00:14:17     | 23:17:37     | 00:01:01     | 276207    | 0.082937672807462157 |
| member        | 3           | Tue     | 855               | 00:14:15     | 23:56:39     | 00:01:01     | 298331    | 0.089580926139898681 |
| member        | 4           | Wed     | 861               | 00:14:21     | 23:39:52     | 00:01:01     | 311855    | 0.093641826432245057 |
| member        | 5           | Thu     | 870               | 00:14:30     | 23:46:15     | 00:01:01     | 310516    | 0.093239760069375219 |
| member        | 6           | Fri     | 901               | 00:15:01     | 23:52:08     | 00:01:01     | 307400    | 0.092304107502756513 |
| member        | 7           | Sat     | 1036              | 00:17:16     | 23:59:43     | 00:01:01     | 292739    | 0.087901796116621467 |


### **Cyclistic Monthly Analysis**
<p align="left">
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#cyclistic-weekly-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#cyclistic-time-of-day-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Riders also behave very differently based on monthly trips. During the monthly analysis, we scrutinize the following parameters:

* Usertype (member / casual)

* Month (number [1-12] & day [Jan-Dec])

* Average ride length (in secs & time duration)

* Max ride length

* Minimum ride length

* Number of rides

* And part of total rides 

**Resulting Table**


This table is available for [download here](tables/analysis_of/ride_data_by_month.csv).

| member_casual | month_num | starting_month | avg_ride_len_secs | avg_ride_len | max_ride_len | min_ride_len | num_rides | part_of_tot_rides     |
| ------------- | --------- | -------------- | ----------------- | ------------ | ------------ | ------------ | --------- | --------------------- |
| casual        | 1         | Jan            | 2273              | 00:37:53     | 23:48:04     | 00:01:05     | 7678      | 0.002305500772303723  |
| casual        | 2         | Feb            | 2364              | 00:39:24     | 23:55:55     | 00:01:06     | 12206     | 0.0036651396752721077 |
| casual        | 3         | Mar            | 2474              | 00:41:14     | 23:53:10     | 00:01:01     | 24418     | 0.0073320809922000924 |
| casual        | 4         | Apr            | 2372              | 00:39:32     | 23:58:33     | 00:01:01     | 23331     | 0.0070056835788770725 |
| casual        | 5         | May            | 2678              | 00:44:38     | 23:53:20     | 00:01:01     | 85914     | 0.0257977068705004    |
| casual        | 6         | Jun            | 2554              | 00:42:34     | 23:55:42     | 00:01:01     | 152794    | 0.045880005861340854  |
| casual        | 7         | Jul            | 2686              | 00:44:46     | 23:58:54     | 00:01:01     | 265559    | 0.079740359415499409  |
| casual        | 8         | Aug            | 2273              | 00:37:53     | 23:59:49     | 00:01:01     | 277794    | 0.083414207025441583  |
| casual        | 9         | Sep            | 1961              | 00:32:41     | 23:59:33     | 00:01:01     | 212041    | 0.063670316392296658  |
| casual        | 10        | Oct            | 1692              | 00:28:12     | 23:59:54     | 00:01:01     | 120624    | 0.03622020384974789   |
| casual        | 11        | Nov            | 1763              | 00:29:23     | 23:55:03     | 00:01:01     | 72106     | 0.021651528873109178  |
| casual        | 12        | Dec            | 1436              | 00:23:56     | 23:41:27     | 00:01:01     | 24289     | 0.0072933456965987411 |
| member        | 1         | Jan            | 652               | 00:10:52     | 23:20:02     | 00:01:01     | 134865    | 0.040496400319971558  |
| member        | 2         | Feb            | 666               | 00:11:06     | 23:52:08     | 00:01:01     | 125383    | 0.037649205956467535  |
| member        | 3         | Mar            | 784               | 00:13:04     | 23:41:42     | 00:01:01     | 114351    | 0.034336587498528658  |
| member        | 4         | Apr            | 1094              | 00:18:14     | 23:56:39     | 00:01:01     | 60215     | 0.018080975384770603  |
| member        | 5         | May            | 1172              | 00:19:32     | 23:29:04     | 00:01:01     | 111415    | 0.03345498418158626   |
| member        | 6         | Jun            | 1107              | 00:18:27     | 23:46:15     | 00:01:01     | 184961    | 0.055538907052105881  |
| member        | 7         | Jul            | 1050              | 00:17:30     | 23:52:12     | 00:01:01     | 276113    | 0.082909447088186761  |
| member        | 8         | Aug            | 980               | 00:16:20     | 22:05:05     | 00:01:01     | 318269    | 0.0955677813623774    |
| member        | 9         | Sep            | 901               | 00:15:01     | 22:59:48     | 00:01:01     | 279042    | 0.083788948489863971  |
| member        | 10        | Oct            | 830               | 00:13:50     | 23:59:43     | 00:01:01     | 211750    | 0.063582936771986634  |
| member        | 11        | Nov            | 811               | 00:13:31     | 23:36:24     | 00:01:01     | 147124    | 0.044177454496537247  |
| member        | 12        | Dec            | 748               | 00:12:28     | 22:49:28     | 00:01:01     | 88054     | 0.026440292394429805  |


### **Cyclistic Time of Day Analysis**
<p align="left">
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#cyclistic-monthly-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#cyclistic-rideable-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Riders appear to follow notable trends based on the start of their trips. During the monthly analysis, we scrutinize the following parameters:

* Usertype (member / casual)

* Weekday (number [1-7] & day [Sun-Sat])

* Time of day (in hours)

* Number of rides

* And part of total rides 

**Resulting Table**

This table is available for [download here](tables/analysis_of/ride_data_by_weekday_and_time_of_day.csv).

| member_casual | weekday_num | weekday | time_of_day | num_rides | part_of_tot_rides      |
| ------------- | ----------- | ------- | ----------- | --------- | ---------------------- |
| casual        | 1           | Sun     | 0           | 5504      | 0.0016527059456576832  |
| casual        | 1           | Sun     | 1           | 3812      | 0.0011446429987004157  |
| casual        | 1           | Sun     | 2           | 2264      | 0.00067981945148419239 |
| casual        | 1           | Sun     | 3           | 1176      | 0.00035312176455185967 |
| casual        | 1           | Sun     | 4           | 714       | 0.00021439535704934336 |
| casual        | 1           | Sun     | 5           | 591       | 0.00017746170310386825 |
| casual        | 1           | Sun     | 6           | 1128      | 0.000338708631304845   |
| casual        | 1           | Sun     | 7           | 1912      | 0.0005741231410060848  |
| casual        | 1           | Sun     | 8           | 3546      | 0.0010647702186232094  |
| casual        | 1           | Sun     | 9           | 6924      | 0.0020790944708818674  |
| casual        | 1           | Sun     | 10          | 11461     | 0.0034414358363340676  |
| casual        | 1           | Sun     | 11          | 17117     | 0.0051397833706072977  |
| casual        | 1           | Sun     | 12          | 20244     | 0.0060787389469284412  |
| casual        | 1           | Sun     | 13          | 23164     | 0.0069555378861218342  |
| casual        | 1           | Sun     | 14          | 24292     | 0.0072942465174266795  |
| casual        | 1           | Sun     | 15          | 24548     | 0.0073711165614107578  |
| casual        | 1           | Sun     | 16          | 22629     | 0.0067948915051394831  |
| casual        | 1           | Sun     | 17          | 19534     | 0.0058655446843163487  |
| casual        | 1           | Sun     | 18          | 16201     | 0.0048647327444767676  |
| casual        | 1           | Sun     | 19          | 12597     | 0.0037825466565134152  |
| casual        | 1           | Sun     | 20          | 9089      | 0.0027291868350440922  |
| casual        | 1           | Sun     | 21          | 5993      | 0.0017995397406116453  |
| casual        | 1           | Sun     | 22          | 4722      | 0.001417891983175069   |
| casual        | 1           | Sun     | 23          | 3551      | 0.0010662715866697735  |
| casual        | 2           | Mon     | 0           | 2210      | 0.0006636046765813009  |
| ...        | ...           | ...     | ...           | ...       | ... |



### **Cyclistic Rideable Analysis**
<p align="left">
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#cyclistic-time-of-day-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#cyclistic-geographic-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Riders have a higher tendency to use certain rideable types than others. This analysis aims to ascertain which rideables are more favored. During the analysis we look out for the following parameters:

* Rideable Type (classic / docked / electric bikes)

* Usertype (member / casual)

* Number of rides

* And part of total rides

**Resulting Table**

This table is available for [download here](tables/analysis_of/ride_data_by_rideable.csv)

| rideable_type | member_casual | num_rides | part_of_tot_rides     |
| ------------- | ------------- | --------- | --------------------- |
| classic_bike  | casual        | 11158     | 0.0033504529327122875 |
| classic_bike  | member        | 58496     | 0.017564805050361891  |
| docked_bike   | casual        | 1125692   | 0.33801559981455104   |
| docked_bike   | member        | 1784073   | 0.53571003898752545   |
| electric_bike | casual        | 141904    | 0.042610026255924395  |
| electric_bike | member        | 208973    | 0.062749076958924968  |




### **Cyclistic Geographic Analysis**
<p align="left">
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#cyclistic-geographic-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

Members and casual riders concentrate their trips on different destinations. Members spreadout throughout Chicago, meanwhile casual users are more focus near the pier.  Moreover, when looking at the starting stations, riders follow a notable trend based on their start

Riders appear to follow notable trends based on the start of their trips. During the monthly analysis, we scrutinize the following parameters:

* Station Name

* Station Id

* Latitude & longitude

* Total Trips From Station

* Trips By Annual Members

* Trips By Casual Users

* Fraction of Members From Daily Trips At Station (normalized to 1)

* Fraction of Casual Riders From Daily Trips At Station (normalized to 1)

**Resulting Table**

This table is available for [download here](tables/analysis_of/analysis_by_stations.csv).


## **Data Summary**
<hr>

<p align="left">
    <a href="#prep-work-step-4" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#cyclistic-geographic-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="#prep-work" style="text-decoration: none">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p>

The data can be summarized as below:

* Total number of stations is **683**.

* Out 3.54 million rows of trip data, **3.3 million rides** remain.
    - Trips without a *start* or *end station name* are removed because without station names we can't track the trips. Additionally, this information is used to assign new station ids.

    - Trips less than a min are also removed because they can be considered a false start of sorts. Moreover, the price is set for all rides within a minute.

    - Trips more than a day are removed because all rideables must be returned after they are used. Rides longer than a day can be considered stolen and users are even charged an additional fee for such cases.

* Out of the 3.54 million rides, **61.6%** were taken by subscribers and **38.4%** were taken by casual customers

* Average ride duration for a casual biker is **46 minutes** long, meanwhile the average ride length for a member is **12 minutes** long.

**Table: Summary of Trips**

| summary_of | started_with | ended_with | eliminated | retained (%) |
| ---------- | ------------ | ---------- | ---------- | ------------ |
| rides      | 3,541,683    | 3,330,296  | 211,387    | 94.031 |
| stations   | 696          | 683        | 13         | 98.132 |


**Table: Summary of Riders**

| member_casual | num_riders   | percent  | avg_ride  |
| ------------- | ----------   | -------  | --------  |
| casual        | 1,278,754    | 38.40    | 37:55     |
| member        | 2,051,542    | 61.60    | 15:15     |



## **Data Story: Cyclistic Bikeshare Analysis of 2020** <a href="#data-story" id="data-story"></a>
<hr>

<p align="left">
    <a href="#data-summary" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#customer-usage" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


For the full interactive Tableau Story please [visit here!](https://public.tableau.com/views/CyclisticAnalysis2020/Story2?:language=en-US&:display_count=n&:origin=viz_share_link "Cyclistic Bikeshare Analysis of 2020").

Below you will find key insights pertaining to each dashboard within the story, you are more than welcome to have a look.

### **Customer Usage**
<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#monthly-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


Seasonal trends played a major role in the number of rides Cyclistic experienced. *During the year 2020, **casual riders accounted for 38.4% of total rides** while **member riders made up** a whopping **61.6% of total trips***. Summer time brought a huge increase in the number of casual riders, in addition to overall ridership. Meanwhile, during winter time, by far the least popular season, there is a major drop-off in rides. This makes sense because bike riding is more suited for warm weather, however it important to plan out events, activities, or promotional content during Cyclistic's most popular time: summer. 

**By taking advantage of the seasonal trend, and the fact that casual riders are already familiar with the Cyclistic program and using Cyclistic bikes, this can be a good opportunity to convert them to annual members.**

It is also important to note user preference when it comes to which rideable popularity. **Docked bikes are by far the most popular** but *electric bikes also receive their fair share of attention*. Moving forward, focusing on these bikes will continue to yield more customers.

<img src="images/story/story-p1-customer-usage.png">


### **Monthly Analysis**
<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#customer-usage" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#weekly-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


Taking a deeper dive into how customers use Cyclistic bikes throughout the year, we consider the number of trips taken & their average ride length on a month-to-month basis.

**Seasonal Trend**

We confirm once more *the favorite season for riders is summer*. Moreover, *a rising trend is seen during early spring*, when the number of rides begin increasing around May. Peak usage occurs during August, then we see a falling trend up during fall, ending with *the least favorite cycling period: winter*.

**Best Time For Marketting Campaign**

Since we know that riders prefer biking during summer time and we see a large influx of trips taken during late Spring, this means a sufficient number of users are aware and have experience Cyclistics bikeshare services. Thus, ***early May is the optimal time to begin advertising***.

<img src="images/story/story-p2-monthly-trends.png">


### **Weekly Analysis**
<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#monthly-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#daily-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


**Number of Rides**

When looking at the number of rides, casual riders show a dramatic predisposition to favor weekend for biking. Meanwhile, annual members are overall consitent in how many rides they take throughout the week; their highest usage day occurs midweek.

**Ride Length**

Saturday and Sunday are favored by both groups for longer rides, revealing a U-shape pattern when ride duration decreases during the week. Moreover, just like during the *monthly analysis*, casual riders have nearly double the ride time of members.

**Insight**

Despite their high inclination towards riding during week, casual riders still take plentiful bike trips during week. This shows promise when attempting to convert to members. Of course, usage time plays a role in their conversion rate. Shorter trips indicate a purposeful usage (of knowing where you are going), while longer trips can be associete with exploring or touring. But with so many riders, Cyclistic is bound gain notably more members by targetting those key individuals. 

**Targetting Group**

Casual Riders with ride times whose average ride duration nears that of members (~15mins) and uses the Cyclistic bikeshare program consistently.

**Potential Secondary Marketting Campaign**

Due to casual riders being more prominent during the weekend, a potential way to increase the number Cyclistic users is by inviting even more casual riders. Specific bonus packages can be tailure for leasure riders, such a Museum pass, beach activities, coastal group rides, discounts using Cyclistic for certain activities, and more!

<img src="images/story/story-p3-weekly-trends.png">


### **Daily Analysis**
<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#weekly-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#geographical-analysis" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


Knowing when riders take trips is important in determining Cyclistic use cases, so we take a deeper dive into how often riders take trips throughout the week, except we consider their experience on an hour-to-hour basis.

**Popular Times**

During the week, Cyclistic experiences peak usage times at *8AM & 5PM*, hours associated with commuting to-and-from work. During the weekend, popular times occur from *11AM* to *5PM* suggesting that rides are taken for leasure. 

**Insights**

Members most likely use Cyclistic bikes to comute, and while casual riders favor weekends, there are plenty of users who take trips during similar periods as members. These casual riders are already using Cyclistic services similar to members, and thus have a higher chance of being converted.


<img src="images/story/story-p4-daily-trends.png">

### **Geographical Analysis**
<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#daily-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#conclusion" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


Majority of trips are taken downtown Chicago, regardless of user type. However, stations with more activy from casual users are near the pier or spreadout across stations. Popular stations not near the pier and near the downtown area are dominated by annual members.

This means that near the pier, there are a lot of riders leasurely spending their time. Still, plenty of casual riders exist along the cost line and within stations with numerious trips (downtown) which holds promise in conversion. 

**Insights**
The prior two targetting groups still hold promise in increasing the number users. Moreover, if Cyclistic invents a *leasure member* group we can convert casual riders who enjoy weekend rides into members. This is of couse in addition to casual riders who share the use cases with current annual members (of 2020).

<img src="images/story/story-p5-geo-trends.png">


### **Conclusion**
<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#geographical-analysis" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


<img src="images/story/story-p6-conclusion.png">


## **Recommendations**
<hr>

<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#conclusion" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#final-thoughts" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#final-thoughts" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


By focusing on seasonality, usage time, and usage case, we can formulate successful marketting strategies to convert casual riders to members.


**Seasonality**

In Spring the demand by casual riders increases, peaking during the summer. This is an opportune time to host a targeted advertising campaign and promotional activities.

> **Launch the marketing campaign in early Spring to draw-in incoming casual riders and run through the summer to convert them into annual members.**

Schedule different promotions and offers to highlight the value of becoming an annual member instead of remaining a casual rider. Discounts for signing up now, raise awareness that summer will soon arrive and be ready.


**Usage Time**

Daily usage revealed that both groups peak during the evening (*~5PM*), however in the morning only members showed high activity. This could mean that most casual riders are not aware of the potential benefits of using Cyclistic rides for commuting early in the morning.

> **Use digital media to raise awareness about the benefits of using Cyclistic bikeshare for morning and evening comutes.**

The goal is to get casual riders to spend more time on Cyclistic bikes, increasing the odds of upgrading their membership status.


**Usage Case**

Many casual riders share the pattern of enjoying leasure rides during the weekends. Proof is their drastic change in number of rides when compared to weekdays. So why not tap into that potential?

>**Create a new package deal for annual members, catoring to customers who want to spend leasure time riding Cyclistic Bikes.**

Adding these new benefits, for members and incoming casual riders, specifically tailored to entertainment and joyful activites will improve conversion rate and member retention in the longer.

Use digital channels to market and promote these new benefits. Possibly hosting summer events to guide casual riders into how they can enjoy leasure rides with others.

-------


## **Final Thoughts**
<hr>

<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#recommendations" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#thank-you" style="text-decoration: none">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="#thank-you" style="text-decoration: none">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


From the Cyclistic case study, the analysis results showed that casual riders could be categorized into two groups: those that shared similarities with members and those that used Cyclistic bikes for leasure or entertainment. 

The marketting campaign holds promise in converting casual users to annual members. Though not easy, with targetted advertising via email and social media, Cyclistic can improve the conversion rate by raising awareness of their benefits and tailuring new benefits to bring more riders
<br>

### **Thank you for taking the time to read this case study** <a href="#thank-you" id="thank-you"></a>
<p align="left">
    <a href="#data-story" style="text-decoration: none">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="#final-thoughts" style="text-decoration: none">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="#top" style="text-decoration: none">
        <img src="images/buttons/top-button.png" align="right">
    </a>
</p>


Working on the capstone project was a good opportunity to learn about the real-world data analysis process. I learned a ton about data preparation and cleaning by actually working on those processes. Checking for data integrity and reliability is crucial before anything. 

It's been fun finding out how data analysis can inform business decisions and lead to effect actions. Until next time, have fun analyzing!

<br><br><br>


<!---- [Testing Inline Img Buttons] ---->

<!-- [![Back Back Button]]()
[![Back Button]]()
[![Next Button]]()
[![Next Next Button]]()
[![Previous Heading Button]]()
[![Top Button]]()
[![Next Heading Button]]() -->

<!-- <p align="left">
    <a href="">
        <img src="images/buttons/back-back-button.png">
    </a>
    <a href="">
        <img src="images/buttons/back-button.png">
    </a>
    <a href="">
        <img src="images/buttons/next-button.png">
    </a>
    <a href="">
        <img src="images/buttons/next-next-button.png">
    </a>
    <a href="">
        <img src="images/buttons/next-heading-button.png" align="right">
    </a>
    <a href="">
        <img src="images/buttons/top-button.png" align="right">
    </a>
    <a href="">
        <img src="images/buttons/previous-heading-button.png" align="right">
    </a>
</p> -->


<!---- [Buttons] ---->
[Back Back Button]: images/buttons/back-back-button.png
[Back Button]: images/buttons/back-button.png
[Next Button]: images/buttons/next-button.png
[Next Next Button]: images/buttons/next-next-button.png
[Top Button]: images/buttons/top-button.png
[Previous Heading Button]: images/buttons/previous-heading-button.png
[Next Heading Button]: images/buttons/next-heading-button.png

