SELECT
	zip
FROM
	weather
ORDER BY maxtemperaturef
LIMIT 1



SELECT
	start_station,
	COUNT(*) trip_count
FROM
	trips
GROUP by start_station
ORDER by start_station ASC



SELECT
	*
FROM
	trips
ORDER by duration ASC
LIMIT 1



SELECT
	end_station,
	AVG(duration) avg_duration
FROM
	trips
GROUP by end_station
ORDER BY end_station ASC