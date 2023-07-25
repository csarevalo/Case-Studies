
## Quickly check the number of rides per "member_casual" by grouping the data, then counting the trips

WITH 
  divvy_stations_2020 AS (SELECT * FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`),

  trips_from_station AS (
    SELECT start_station_name, start_station_id, member_casual, COUNT(ride_id) AS num_rides
    FROM divvy_stations_2020
    GROUP BY start_station_name, start_station_id, member_casual
    ORDER BY start_station_name, start_station_id, member_casual
  ),

  test AS (
    SELECT *,
      CASE member_casual
        WHEN 'casual' THEN num_rides
        ELSE 0
      END AS casual_riders,
      CASE member_casual
        WHEN 'member' THEN num_rides
        ELSE 0
      END AS member_riders
    
    FROM trips_from_station AS from_st
    -- INNER JOIN divvy_stations_2020 AS sts
    -- ON sts.station_id = from_st.start_station_id
    ORDER BY start_station_id
  )

SELECT *
FROM test;



#########################################################################################################################################################

## Organize the number of rides per "member_casual", creating a new table to quickly access the data.
#- Note: nulls indicate that there were no rides found for selected trips from version2

-- CREATE OR REPLACE TABLE `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020_v2`
CREATE TABLE IF NOT EXISTS `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020_v2`
OPTIONS(
  description = "Table containing station information for each unique station, including how many users come and go from each station."
) AS 

##### SUBQUERIES USED TO CREATE TABLE #####

WITH 
  trips AS (SELECT * FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`),
  stations AS (SELECT * FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_stations_2020`),
  -- total_trips_per_station AS (
  --   SELECT start_station_id, end_station_id, 
  --     COUNT(ride_id)
  --   FROM trips
  -- ),
  trips_from_station AS (
    SELECT start_station_name, start_station_id, 
      COUNTIF(member_casual='member') AS member_riders,
      COUNTIF(member_casual='casual') AS casual_riders
    FROM trips
    GROUP BY start_station_name, start_station_id
    ORDER BY start_station_id
  ),
  trips_to_station AS (
    SELECT end_station_name, end_station_id, 
      COUNTIF(member_casual='member') AS member_riders,
      COUNTIF(member_casual='casual') AS casual_riders
    FROM trips
    GROUP BY end_station_name, end_station_id
    ORDER BY end_station_id
  ),
  divvy_trips_2020_v2_temp AS (
    SELECT sts.*,
      tot_trips_from.num_rides1 AS total_rides_from,
      tot_trips_to.num_rides2 AS total_rides_to,
      from_st.member_riders AS members_from_st,
      from_st.casual_riders AS casuals_from_st,
      to_st.member_riders AS members_to_st,
      to_st.casual_riders AS casuals_to_st
    FROM stations AS sts
    FULL JOIN trips_from_station AS from_st
    ON sts.station_id = from_st.start_station_id
    FULL JOIN trips_to_station AS to_st
    ON sts.station_id = to_st.end_station_id
    FULL JOIN (SELECT start_station_id, COUNT(ride_id) AS num_rides1 FROM trips GROUP BY start_station_id) AS tot_trips_from
    ON sts.station_id = tot_trips_from.start_station_id
    FULL JOIN (SELECT end_station_id, COUNT(ride_id) AS num_rides2 FROM trips GROUP BY end_station_id) AS tot_trips_to
    ON sts.station_id = tot_trips_to.end_station_id
  )

### END SUBQUERIES USED TO CREATE TABLE ###

############ CREATE TABLE STATEMENT ############

SELECT *
FROM divvy_trips_2020_v2_temp
-- ORDER BY total_trips_from, total_trips_to
ORDER BY members_from_st DESC, casuals_from_st DESC
;
################################################



#########################################################################################################################################################



## Verify number of starting stations
#- There are two cases with missing data (or NULLS). They pertain to a quality check (Hubbard_Test_Lws / station_id=312) and an unpopular station (N Carpenter St & W Lake St / station_id=457)

SELECT 
  COUNT(DISTINCT start_station_name) AS num_starting_stations,
  COUNT(DISTINCT end_station_name) AS num_ending_stations
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
;










