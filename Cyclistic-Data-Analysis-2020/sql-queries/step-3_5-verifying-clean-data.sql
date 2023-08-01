#=============================================================
## STEP 3.5: Verify Cleaned Data (After Creating Table)
#=============================================================

### Determine number of rows before and after cleaning data

####################### SUMMARY TABLE ########################
#| summary_of | started_with | ended_with | eliminated | retained (%) |
#| ---------- | ------------ | ---------- | ---------- | ------------ |
#| rides      | 3,541,683    | 3,330,296  | 211,387    | 94.031 |
#| stations   | 696          | 683        | 13         | 98.132 |

WITH 
  divvy_trips_2020 AS (SELECT* FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020`),
  divvy_trips_2020_v2 AS (SELECT* FROM `case-study1-bike-share.divvy_trips_2020_data.divvy_trips_2020_v2`),
  examine_rows AS ( SELECT
    'rides' AS summary_of,
    (SELECT COUNT(*) FROM divvy_trips_2020) AS started_with,
    (SELECT COUNT(*) FROM divvy_trips_2020_v2) AS ended_with
  ),
  examine_stations AS (SELECT
    'stations' AS summary_of,
    (SELECT COUNT(DISTINCT station_name) FROM (SELECT DISTINCT start_station_name as station_name FROM divvy_trips_2020 UNION ALL SELECT DISTINCT end_station_name AS station_name FROM divvy_trips_2020)) AS started_with,
    (SELECT COUNT(DISTINCT station_name) FROM (SELECT DISTINCT start_station_name as station_name FROM divvy_trips_2020_v2 UNION ALL SELECT DISTINCT end_station_name AS station_name FROM divvy_trips_2020_v2)) AS ended_with
  )
SELECT
## Confirm how many rows we retained & eliminated
  summary_of,
  started_with, ## (~3.54M rides) & (696 stations)
  ended_with,   ## (~3.33M rides) & (683 stations)
  started_with - ended_with AS eliminated,    ## Eliminated (211,387 rides) & (13 stations)
  (ended_with/started_with*100) AS retained,  ## Retained (~94.03% of rides) & (~98.13% of stations)
FROM (SELECT * FROM examine_rows UNION ALL SELECT * FROM examine_stations)
LIMIT 100;


#=============================================================
## STEP 3.5.2: Verify Cleaned Data (Checking For Nulls)
#=============================================================


SELECT column_name, COUNT(1) AS nulls_count
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`  as table1, 
UNNEST(REGEXP_EXTRACT_ALL(TO_JSON_STRING(table1), r'"(\w+)":null')) column_name
GROUP BY column_name
ORDER BY nulls_count DESC;


#=============================================================
## STEP 3.5.3: Check Number Of Member_Casuals
#=============================================================

## Verify Corresponding Station Ids For Quality Checks
SELECT station_name, station_id
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020_v2`
WHERE station_id=310
  OR station_id=311
  OR station_id=312
  OR station_id=45
  OR station_id=455
  OR station_id=633
ORDER BY station_id
;

## Check the overall number of member/casual riders
SELECT member_casual, COUNT(ride_id) AS  quality_check_users
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
WHERE start_station_id=310 OR end_station_id=310
  OR start_station_id=311  OR end_station_id=311
  OR start_station_id=312  OR end_station_id=312
  OR start_station_id=45   OR end_station_id=45
  OR start_station_id=455  OR end_station_id=455
  OR start_station_id=633  OR end_station_id=633
GROUP BY member_casual
;
