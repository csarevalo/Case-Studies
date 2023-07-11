
## PROPER Case EX: "I wANt Bananas from 23RD ST!" ---> "I Want Bananas From 23rd St!"
CREATE TEMP FUNCTION PROPER(str STRING) AS (( #edited from stackoverflow in <https://stackoverflow.com/questions/51351948/proper-case-in-big-query>
  SELECT STRING_AGG(CONCAT(UPPER(SUBSTR(w,1,1)), LOWER(SUBSTR(w,2))), '' ORDER BY pos) 
  FROM UNNEST(REGEXP_EXTRACT_ALL(str,  r'[[:^alnum:]]|[[:alnum:]]*')) w WITH OFFSET pos #uppercase alphanumeric substrings 
)); 

###############################################################################################################################################

#======================================================
# STEP 3: CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS
#======================================================

-- CREATE OR REPLACE TABLE `divvy_trips_2020_data.divvy_trips_2020_v2`
CREATE TABLE IF NOT EXISTS `divvy_trips_2020_data.divvy_trips_2020_v2`
OPTIONS(
  description = "Removed cases where station names are missing (null), removed duplicates of station name, removed cases where trip duration is less than or equal to a min (60 secs), and also removed cases where trip duration is more a 24 hours...CAN cast station ids to INT64 but will leave as STRING."
) AS 

##### SUBQUERIES USED TO CREATE TABLE #####

WITH 
  ### Use combined datasets of all 2020 trip data
  ## Filter out when trip duration is less than or equal to zero(0) (~10k rows)
  divvy_trips_2020 AS (
    SELECT* FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020`
    WHERE (TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 60) #60secs
    AND (TIMESTAMP_DIFF(ended_at, started_at, SECOND) < 60*60*24) #1day
  ),

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

  ## Get distinct station names in LOWER case ("i want banana!")
  unique_station_names AS (
    SELECT DISTINCT station_name as unique_station_name
    FROM (
      (SELECT DISTINCT LOWER(new_start_station_name) as station_name FROM station_names)
      UNION ALL
      (SELECT DISTINCT LOWER(new_end_station_name) as station_name FROM station_names)
    )
  ),

  ## Create new station ids for distinct, non-duplicate stations and make station names PROPER case ("I Want Banana!")
  divvy_stations_2020 AS (
    SELECT
      IF(st_name='HQ QR', 'HQ QR', PROPER(st_name)) AS new_station_name,
      ROW_NUMBER() OVER(ORDER BY st_name) as new_station_id 
    FROM (SELECT DISTINCT unique_station_name as st_name FROM unique_station_names)
    ORDER BY new_station_id
  ),

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

### END SUBQUERIES USED TO CREATE TABLE ###

######## CREATE TABLE STATEMENT ########
SELECT*
FROM divvy_trips_2020_v2
ORDER BY started_at;
########################################

