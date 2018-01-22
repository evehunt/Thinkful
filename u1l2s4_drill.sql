-- 1. What are the three longest trips on rainy days?

WITH
	rain_days
AS (
		SELECT
			date,
			events
		FROM
			weather
		WHERE
			events = 'Rain'
		GROUP BY 1
		)
		
SELECT
	trip_id,
	date,
	duration,
	events
FROM
	trips
JOIN
	rain_days
ON
	rain_days.date = date(start_date)
ORDER BY duration DESC
LIMIT 3



-- 2. Which station is empty most often?

WITH empty_frequencies
AS (
	SELECT
		station_id,
		COUNT(bikes_available) empty_freq
	FROM
		status
	WHERE bikes_available = 0
	GROUP BY 1
	)

SELECT
	s.name,
	s.station_id,
	e.empty_freq empty_freq
FROM
	stations s
JOIN
	empty_frequencies e
ON
	s.station_id = e.station_id
ORDER BY empty_freq DESC
LIMIT 1



-- 3. Return a list of stations with a counter of number of trips starting at that station but ordered by dock count.

WITH trip_frequencies
AS (
	SELECT
		start_station,
		count(*) trip_freq
	FROM
		trips
	GROUP BY
		start_station
		)
		
SELECT
	t.start_station name,
	t.trip_freq,
	s.dockcount dock_count
FROM
	stations s
JOIN
	trip_frequencies t
ON
	t.start_station LIKE s.name
ORDER BY dock_count desc

-- QUESTION: 
-- There are discrepancies between the station names used in trips.start_station and stations.name – some of the names used in trips.start_station are redundant due to typos, and some are unique but absent in stations.name (see the table returned by the script below for reference).
-- Both my solution and the sample solution provided by Thinkful are flawed because they fail to account for these discrepancies. What is the simplest way to resolve them? My instinct is to export the result of the left outer join as a CSV and clean it up in Python, but that’s kind of slow – is there a way to just resolve it in the SQL query?

WITH trip_frequencies
AS (
	SELECT
		start_station,
		count(*) trip_freq
	FROM
		trips
	GROUP BY
		start_station
		)
		
SELECT
	t.start_station name,
	t.trip_freq,
	s.dockcount dock_count
FROM
	trip_frequencies t
LEFT OUTER JOIN
	stations s
ON
	t.start_station = s.name



-- 4. (Challenge) What’s the length of the longest trip for each day it rains anywhere?

WITH 
	rain_days 
	AS (
	SELECT
		date,
		events
	FROM
		weather
	WHERE
		events = 'Rain'
	GROUP BY 1
	),
	longest_trips
	AS (
	SELECT
		date(start_date) date,
		max(duration) duration
	FROM
		trips
	GROUP BY 1
	)
	
SELECT
	r.date,
	r.events,
	l.duration longest_trip
FROM
	rain_days r
JOIN
	longest_trips l
ON
	l.date = r.date
ORDER BY r.date