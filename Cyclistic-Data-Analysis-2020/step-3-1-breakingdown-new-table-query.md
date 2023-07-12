### Step 3.1: Breakdown of Creating a New Table with SQL
* Due to various nulls in station names & ids, and notes outlined in **Step 3**, there is a need to create a new table without any of the undesirable traits mentioned above.

* The whole query is available [here](https://github.com/csarevalo/Case-Studies/blob/d4eb3479ac0b2a925180045230226046771f0d9d/Cyclistic-Data-Analysis-2020/sql-queries/step3_create_table_w_clean_data.sql)

***Overall Goal: Create a new version of combined 2020 trip data where unnecessary or bias data is removed***.

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

| ride_id | rideable_type | started_at | ended_at | start_station_name | start_station_id | end_station_name | end_station_id | start_lat | start_lng | end_lat | end_lng | member_casual | month_num | starting_month | weekday_num | weekday | ride_length |
| ---------------- | ------------- | ------------------------------ | ------------------------------ | ------------------------------ | ---------------- | ------------------------------ | -------------- | --------- | --------- | ------- | -------- | ------------- | --------- | -------------- | ----------- | ------- | ----------- |
| 1068AB1B8F12FE23 | docked_bike   | 2020-01-01 00:04:44.000000 UTC | 2020-01-01 00:17:08.000000 UTC | Sheffield Ave & Wellington Ave | 532              | Ashland Ave & Belle Plaine Ave | 25             | 41.9363   | -87.6527  | 41.9561 | -87.6688 | casual        | 1         | Jan            | 4           | Wed     | 744         |
| 4DE50A4FC7687A0D | docked_bike   | 2020-01-01 00:11:14.000000 UTC | 2020-01-01 00:15:32.000000 UTC | Daley Center Plaza             | 182              | Dearborn St & Van Buren St     | 210            | 41.8842   | -87.6296  | 41.8763 | -87.6292 | member        | 1         | Jan            | 4           | Wed     | 258         |
| 1C78B5F337CBFC93 | docked_bike   | 2020-01-01 00:11:27.000000 UTC | 2020-01-01 00:13:15.000000 UTC | Sheridan Rd & Irving Park Rd   | 538              | Broadway & Sheridan Rd         | 62             | 41.9542   | -87.6544  | 41.9528 | -87.65   | member        | 1         | Jan            | 4           | Wed     | 108         |
| D231CE7990A3AA52 | docked_bike   | 2020-01-01 00:12:34.000000 UTC | 2020-01-01 00:14:29.000000 UTC | Delano Ct & Roosevelt Rd       | 211              | Wabash Ave & Roosevelt Rd      | 622            | 41.8675   | -87.6322  | 41.8672 | -87.626  | member        | 1         | Jan            | 4           | Wed     | 115         |
| 2295556346560999 | docked_bike   | 2020-01-01 00:19:12.000000 UTC | 2020-01-01 00:26:36.000000 UTC | Clark St & Leland Ave          | 141              | Southport Ave & Irving Park Rd | 556            | 41.9671   | -87.6674  | 41.9542 | -87.6644 | member        | 1         | Jan            | 4           | Wed     | 444         |

