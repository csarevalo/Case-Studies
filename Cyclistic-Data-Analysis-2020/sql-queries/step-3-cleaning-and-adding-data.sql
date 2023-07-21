
#============================================
# STEP 3.0: Looking for crucial missing data
#============================================

## Throughout the following queries (including subqueries), I continously check for nulls (missing or lost info)
# Source is from stackoverflow <https://stackoverflow.com/questions/58716640/bigquery-check-entire-table-for-null-values>

SELECT column_name, COUNT(1) AS nulls_count
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`  as table1, 
UNNEST(REGEXP_EXTRACT_ALL(TO_JSON_STRING(table1), r'"(\w+)":null')) column_name
GROUP BY column_name
ORDER BY nulls_count DESC;


##################################################################################


#=======================================================
## STEP 3: Clean and Add Data to Prepare for Analaysis
#======================================================

-- CREATE OR REPLACE TABLE `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
OPTIONS(
  description = "Removed cases where station names are missing (null), removed duplicates of station name, removed cases where trip duration is less than or equal to a min (60 secs), and also removed cases where trip duration is more a 24 hours."
) AS 

##### SUBQUERIES USED TO CREATE TABLE #####

WITH 
  ### Use combined datasets of all 2020 trip data

  ## Filter out when trip duration is less than or equal to zero(0) (~10k rows)
  ## Also filter out cases when no station name is provided (Roughly 10k rows)
  ## Remove non-distinct duplicate station names by removing trailing & leading chars

  divvy_trips_2020 AS (
    SELECT * 
    REPLACE (
      CASE
        WHEN ENDS_WITH(TRIM(start_station_name), "(*)") THEN TRIM(start_station_name, " (*)") # removes leading & trailing chars
        # Select everything but "(temp)" from string
        WHEN ENDS_WITH(TRIM(LOWER(start_station_name)), "(temp)") THEN TRIM( LEFT( TRIM(start_station_name), LENGTH(TRIM(start_station_name))-6 ) )
        ELSE TRIM(start_station_name, " *") #removes leading & trailing chars
      END AS start_station_name, #--
      
      CASE 
        WHEN ENDS_WITH(TRIM(end_station_name), "(*)") THEN TRIM(end_station_name, " (*)") # removes leading & trailing chars
        # Select everything but "(temp)" from string
        WHEN ENDS_WITH(TRIM(LOWER(end_station_name)), "(temp)") THEN TRIM( LEFT( TRIM(end_station_name), LENGTH(TRIM(end_station_name))-6 ) )
        ELSE TRIM(end_station_name, " *") 
      END AS end_station_name #--
    )
    FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020`
    WHERE (TIMESTAMP_DIFF(ended_at, started_at, SECOND) > 60) #60secs
    AND (TIMESTAMP_DIFF(ended_at, started_at, SECOND) <= 60*60*24) #1day
    AND start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL
  ),

  ## Use available station info
  divvy_stations_2020 AS (SELECT * FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020`),

  ### Update start/end station name, id, lat, and lng from available station info

  ## This includes setting new ids for both start & end stations,
  ## Making station names proper case (e.g. "Highway St & 23rd St"),
  ## And updating geo-location (latitude & longitude)

  updated_trips AS (
    SELECT trips.* 
    REPLACE (
      st1.station_name AS start_station_name, st2.station_name as end_station_name,
      st1.station_id AS start_station_id, st1.lat AS start_lat, st1.lng AS start_lng,
      st2.station_id AS end_station_id, st2.lat AS end_lat, st2.lng AS end_lng
    )
    FROM divvy_trips_2020 AS trips 
    INNER JOIN divvy_stations_2020 AS st1
    ON LOWER(trips.start_station_name) = LOWER(st1.station_name)
    INNER JOIN divvy_stations_2020 AS st2
    ON LOWER(trips.end_station_name) = LOWER(st2.station_name)
  ),

  ## Create new version of 2020 divvy trip data because we are removing rows
  ## Add additional data to aggregate trip info more easily during analysis
  divvy_trips_2020_v2_temp AS (
    SELECT *, 
      EXTRACT(MONTH FROM started_at) as month_num, # [1-12] --> [Jan-Dec]
      FORMAT_TIMESTAMP('%b', started_at) as starting_month, # [Jan-Dec]
      EXTRACT(DAYOFWEEK FROM started_at) as weekday_num, # [1-7] -> [Sun-Sat]
      FORMAT_TIMESTAMP('%a', started_at) as weekday,# [Sun-Sat]
      TIMESTAMP_DIFF(ended_at, started_at, SECOND) as ride_length
    FROM updated_trips 
  )

### END SUBQUERIES USED TO CREATE TABLE ###

######## CREATE TABLE STATEMENT ########
SELECT*
FROM divvy_trips_2020_v2_temp
ORDER BY started_at;
########################################

