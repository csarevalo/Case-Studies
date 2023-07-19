

#===========================================
# STEP 1: Collect Data
#===========================================

#- Uploaded from csv files
#- Or via python scipt (not shown here)

#===========================================
# STEP 2.0: Wrangle Data Before Combining It
#===========================================

## Fix Schema For Tables With Trip Data

CREATE OR REPLACE TABLE `project.dataset.table` AS (
  SELECT * REPLACE (
    CAST(started_at AS TIMESTAMP) AS started_at, 	
    CAST(ended_at AS TIMESTAMP) AS ended_at, 
    CAST(start_station_id AS STRING) AS  start_station_id, 
    CAST(end_station_id AS STRING) AS end_station_id 
    )
FROM `project.dataset.table`);

#========================================================
# STEP 2.1: Combine Data Into A Single Table
#========================================================

CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020` 
OPTIONS (
  description= "This tables contains all trip data occuring in 2020."
) AS

WITH divvy_trips_2020_temp AS (SELECT* FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020_*`)

######## CREATE TABLE STATEMENT ########
SELECT*
FROM divvy_trips_2020_temp
ORDER BY started_at;
########################################

################# Random Notes #####################
## Seems I am stuck with the "L" haha
#- Unable to remove the capitalized 'L' at the end of 'member_casuaL'
#- Query error: Column already exists: member_casual at [47:34] 

ALTER TABLE `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`
  RENAME COLUMN member_casuaL TO member_casual;
####################################################


#=============================================
# STEP 2.2: Looking for crucial missing data
#=============================================

SELECT column_name, COUNT(1) AS nulls_count
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020`  as table1, 
UNNEST(REGEXP_EXTRACT_ALL(TO_JSON_STRING(table1), r'"(\w+)":null')) column_name
GROUP BY column_name
ORDER BY nulls_count DESC
