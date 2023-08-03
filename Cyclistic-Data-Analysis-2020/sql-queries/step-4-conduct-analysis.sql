
###############################################################################################################################################

## Analyze ridership data by member_casual and weekday
SELECT
  member_casual,
  weekday_num,
  weekday,
  CAST(AVG(ride_length) AS INT64) AS avg_ride_len_secs,
  TIME_ADD(TIME(00,00,00), INTERVAL CAST(AVG(ride_length) AS INT64) SECOND) as avg_ride_len,
  TIME_ADD(TIME(00,00,00), INTERVAL CAST(MAX(ride_length) AS INT64) SECOND) as max_ride_len,
  TIME_ADD(TIME(00,00,00), INTERVAL CAST(MIN(ride_length) AS INT64) SECOND) as min_ride_len,
  count(*) as num_rides,
  (count(*)/(SELECT COUNT(*) FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`)) as part_of_tot_rides #normalized to 1
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
GROUP BY member_casual, weekday_num, weekday
ORDER BY member_casual, weekday_num
LIMIT 1000;

################################################################################################################################################

## Analyze ridership data by member_casual and month
SELECT
  member_casual,
  month_num,
  starting_month,
  CAST(AVG(ride_length) AS INT64) AS avg_ride_len_secs,
  TIME_ADD(TIME(00,00,00), INTERVAL CAST(AVG(ride_length) AS INT64) SECOND) as avg_ride_len,
  TIME_ADD(TIME(00,00,00), INTERVAL CAST(MAX(ride_length) AS INT64) SECOND) as max_ride_len,
  TIME_ADD(TIME(00,00,00), INTERVAL CAST(MIN(ride_length) AS INT64) SECOND) as min_ride_len,
  count(*) as num_rides,
  (count(*)/(SELECT COUNT(*) FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`)) as part_of_tot_rides #normalized to 1
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
GROUP BY member_casual, month_num, starting_month
ORDER BY member_casual, month_num
LIMIT 1000;

################################################################################################################################################

## Analyze ridership data by member_casual, weekday, and time of day
SELECT
  member_casual,
  weekday_num,
  weekday,
  EXTRACT(HOUR FROM started_at) as time_of_day,
  count(*) as num_rides,
  (count(*)/(SELECT COUNT(*) FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`)) as part_of_tot_rides #normalized to 1
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
GROUP BY member_casual, weekday_num, weekday, time_of_day
ORDER BY member_casual, weekday_num, time_of_day
LIMIT 1000;

################################################################################################################################################

## Analyze ridership data by rideable_type and member_casual
SELECT
  rideable_type,
  member_casual,
  count(*) as num_rides,
  (count(*)/(SELECT COUNT(*) FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`)) as part_of_tot_rides #normalized to 1
FROM `case-study1-bike-share.divvy_trips_2020_analysis.divvy_trips_2020_v2`
GROUP BY rideable_type, member_casual
ORDER BY rideable_type, member_casual
LIMIT 1000;







