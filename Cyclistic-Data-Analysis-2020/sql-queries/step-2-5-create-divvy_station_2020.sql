
#===========================================
# STEP 2.5.0: List of Functions
#===========================================

### This function is used to correct the grammar of station names

## PROPER Case EX: "I wANt Bananas from 23RD ST!" ---> "I Want Bananas From 23rd St!"
CREATE TEMP FUNCTION PROPER(str STRING) AS (( #edited from stackoverflow in <https://stackoverflow.com/questions/51351948/proper-case-in-big-query>
  SELECT STRING_AGG(CONCAT(UPPER(SUBSTR(w,1,1)), LOWER(SUBSTR(w,2))), '' ORDER BY pos) 
  FROM UNNEST(REGEXP_EXTRACT_ALL(str,  r'[[:^alnum:]]|[[:alnum:]]*')) w WITH OFFSET pos #uppercase alphanumeric substrings 
)); 

#==================================================
# STEP 2.5: Create A New Table About Station Info
#==================================================

##
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020` 
-- CREATE OR REPLACE TABLE `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020`
OPTIONS (
  description= "This table includes all unique station names and their new unique ids with their corresponding latitude and longetitude (acquired by averaging all lat/lng values from users arriving or leaving said station)"
) AS

##### SUBQUERIES USED TO CREATE TABLE #####

WITH 
  ## Use combined datasets of all 2020 trip data
  divvy_trips_2020 AS (SELECT* FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`),

  ## Filter non-distinct duplicates and nulls from station names
  station_names AS (SELECT ride_id, --new: start/end station name
      CASE
        WHEN ENDS_WITH(TRIM(start_station_name), "(*)") THEN TRIM(start_station_name, " (*)") # removes leading & trailing chars
        # Select everything but "(temp)" from string
        WHEN ENDS_WITH(TRIM(LOWER(start_station_name)), "(temp)") THEN TRIM( LEFT( TRIM(start_station_name), LENGTH(TRIM(start_station_name))-6 ) )
        ELSE TRIM(start_station_name, " *") #removes leading & trailing chars
      END AS new_start_station_name, #--
      
      CASE 
        WHEN ENDS_WITH(TRIM(end_station_name), "(*)") THEN TRIM(end_station_name, " (*)") # removes leading & trailing chars
        # Select everything but "(temp)" from string
        WHEN ENDS_WITH(TRIM(LOWER(end_station_name)), "(temp)") THEN TRIM( LEFT( TRIM(end_station_name), LENGTH(TRIM(end_station_name))-6 ) )
        ELSE TRIM(end_station_name, " *") 
      END AS new_end_station_name #--
    
    FROM divvy_trips_2020 
    WHERE start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL
  ),

  ## Get distinct station names in LOWER case ("i want banana!")
  unique_station_names AS (
    SELECT DISTINCT station_name as unique_station_name
    FROM ( (SELECT DISTINCT LOWER(new_start_station_name) as station_name FROM station_names)
      UNION ALL (SELECT DISTINCT LOWER(new_end_station_name) as station_name FROM station_names)
    )
  ),

  ## Create new station ids for distinct, non-duplicate stations and make station names PROPER case ("I Want Banana!")
  divvy_stations_2020_temp AS (
    SELECT
      IF(st_name='hq qr', 'HQ QR', PROPER(st_name)) AS new_station_name,
      ROW_NUMBER() OVER(ORDER BY st_name) as new_station_id 
    FROM (SELECT DISTINCT unique_station_name as st_name FROM unique_station_names)
    ORDER BY new_station_id
  )
### END SUBQUERIES USED TO CREATE TABLE ###

######## CREATE TABLE STATEMENT ########
## Finally, average lat and lng to make it consistent accross stations
SELECT
  new_station_name AS station_name, 
  new_station_id AS station_id
FROM divvy_stations_2020_temp
GROUP BY station_name, station_id
ORDER BY station_id
;
########################################


################# NOTES ################
#- This query does not yet include the latitude and longitude of stations
#- That will be added in the following query
########################################


#==================================================================
# STEP 2.6: Update Table Containing Station Info (Add Geo-location)
#==================================================================

-- CREATE OR REPLACE TABLE `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020`
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020`
OPTIONS (
  description= "This table includes all unique station names and their new unique ids with their corresponding latitude and longetitude (acquired by averaging all lat/lng values from users arriving or leaving said station)"
) AS

WITH 
  divvy_stations_2020 AS (SELECT * FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020`),

  ## Filter non-distinct duplicates and nulls from station names
  trips AS (
    SELECT * EXCEPT(rideable_type, started_at, ended_at, member_casual)
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
    FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`
    WHERE start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL
  ),

  ## Set new ids for both start & end stations
  trips2 AS (
    SELECT trips.* 
    REPLACE ( #update station names and ids
      st1.station_name AS start_station_name, st1.station_id AS start_station_id, 
      st2.station_name AS end_station_name, st2.station_id AS end_station_id)
    FROM trips 
    INNER JOIN divvy_stations_2020 AS st1
    ON LOWER(trips.start_station_name) = LOWER(st1.station_name)
    INNER JOIN divvy_stations_2020 AS st2
    ON LOWER(trips.end_station_name) = LOWER(st2.station_name)
  ),

  ## Then, combine start/end stations columns
  station_info AS (
    SELECT
      station_name, station_id, lat, lng
    FROM ( (SELECT start_station_name as station_name, start_station_id as station_id, start_lat as lat, start_lng as lng FROM trips2) 
      UNION ALL (SELECT end_station_name as station_name, end_station_id as station_id, end_lat as lat, end_lng as lng FROM trips2)
    )
  )

######## CREATE TABLE STATEMENT ########
## Finally, average lat and lng to make it consistent accross stations
SELECT
  station_name, station_id,
  AVG(lat) as lat,
  AVG(lng) as lng
FROM station_info
GROUP BY station_name, station_id
ORDER BY station_id
;
#######################################

########## Verifying No Data Was Lost ############
# This is run using only the WITH statement (meaning you exclude the CREATE TABLE statement)
-- SELECT COUNT(*), (SELECT COUNT(*) FROM trips)
-- FROM trips2
-- LIMIT 100;
##################################################



#==================================================================
# STEP 2.9: Combine Two Queries Into One
#==================================================================
#- I named this as v2 to compare if the outcome is the same when combined the two prior queries
  
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020_v2`
-- CREATE OR REPLACE TABLE `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020_v2`
OPTIONS (
  description= "This table includes all unique station names and their new unique ids with their corresponding latitude and longetitude (acquired by averaging all lat/lng values from users arriving or leaving said station)"
) AS

WITH 

  ## Get Relevant Trip Information
  divvy_trips_2020 AS (
    SELECT * EXCEPT(rideable_type, started_at, ended_at, member_casual)
    FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`),

  ## Filter non-distinct duplicates and nulls from station names
  trips AS (SELECT *
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
    FROM divvy_trips_2020
    WHERE start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL
  ),

  ## Get distinct station names in LOWER case ("i want banana!")
  unique_station_names AS (
    SELECT DISTINCT station_name as unique_station_name
    FROM ( (SELECT DISTINCT LOWER(start_station_name) as station_name FROM trips)
      UNION ALL (SELECT DISTINCT LOWER(end_station_name) as station_name FROM trips)
    )
  ),

  ## Create new station ids for distinct, non-duplicate stations and make station names PROPER case ("I Want Banana!")
  station_info AS (
    SELECT
      IF(st_name='hq qr', 'HQ QR', PROPER(st_name)) AS new_station_name,
      ROW_NUMBER() OVER(ORDER BY st_name) as new_station_id 
    FROM (SELECT DISTINCT unique_station_name as st_name FROM unique_station_names)
    ORDER BY new_station_id
  ),

  ## Set new ids for both start & end stations
  trips2 AS (
    SELECT trips.* 
    REPLACE ( #update station names and ids
      st1.new_station_name AS start_station_name, st1.new_station_id AS start_station_id, 
      st2.new_station_name AS end_station_name, st2.new_station_id AS end_station_id)
    FROM trips 
    INNER JOIN station_info AS st1
    ON LOWER(trips.start_station_name) = LOWER(st1.new_station_name)
    INNER JOIN station_info AS st2
    ON LOWER(trips.end_station_name) = LOWER(st2.new_station_name)
  ),

  ## Then, combine start/end stations columns
  divvy_stations_2020_temp AS (
    SELECT
      station_name, station_id, lat, lng
    FROM ( (SELECT start_station_name as station_name, start_station_id as station_id, start_lat as lat, start_lng as lng FROM trips2) 
      UNION ALL (SELECT end_station_name as station_name, end_station_id as station_id, end_lat as lat, end_lng as lng FROM trips2)
    )
  )
### END SUBQUERIES USED TO CREATE TABLE ###


######## CREATE TABLE STATEMENT ########
## Finally, average lat and lng to make it consistent accross stations
SELECT
  station_name, station_id,
  AVG(lat) as lat,
  AVG(lng) as lng
FROM divvy_stations_2020_temp
GROUP BY station_name, station_id
ORDER BY station_id
;
#######################################



