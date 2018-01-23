-- I selected Oakland for this project, and used Python to clean the data before importing it into my SQLite database.
-- Script: https://github.com/evehunt/Thinkful/blob/master/Airbnb%20Data%20Cleaning.ipynb



-- What's the most expensive listing? What else can you tell me about the listing?

--The most expensive listing is ID 95615, at an average cost of $2,848/night. 
-- It’s a 5bed/4bath villa located in Panoramic Hill, and is made available for 
-- rental most (99.7%) of the year .

WITH
	avg_prices
AS (
	SELECT
		listing_id,
		AVG(price) avg_price,
		SUM(available)/COUNT(available) percent_available
	FROM
		calendar
	WHERE
		price > 0
	GROUP BY
		listing_id
	ORDER BY
		avg_price desc
	LIMIT 1
	)

SELECT
	a.listing_id id,
	l.price_cost listed_price,
	a.avg_price avg_price,
	a.percent_available percent_available,
	l.neighbourhood_cleansed neighborhood,
	l.property_type property_type,
	l.room_type room_type,
	l.accommodates accommodates,
	l.bedrooms bedrooms,
	l.bathrooms bathrooms,
	l.amenities amenities,
	l.review_scores_value review_scores,
	l.host_total_listings_count host_total_listings
FROM
	avg_prices a
JOIN
	listings l
ON
	a.listing_id = l.id

	

-- What neighborhoods seem to be the most popular?

-- After weighing average reviews per month by number of units available 
-- for rent, Bushrod, Longfellow, and Temescal are the most popular neighborhoods. 
-- On average, units in these neighborhoods are available for rent for less of the year
-- than most other neighborhoods – respectively, they’re at the 32nd, 29th, and 18th 
-- percentiles for availability.

WITH
	neighborhood_calendar
AS (
	SELECT
		calendar.listing_id,
		listings.neighbourhood_cleansed neighborhood,
		calendar.available available
	FROM
		calendar
	JOIN
		listings
	ON
		listings.id = calendar.listing_id
	),
	
	neighborhood_availability
AS (
	SELECT
		neighborhood,
		SUM(n.available)/COUNT(n.available) percent_available
	FROM
		neighborhood_calendar n
	GROUP BY
		neighborhood
	),
	
	neighborhood_reviews
AS (
	SELECT
		neighbourhood_cleansed AS neighborhood,
		avg(reviews_per_month) reviews_per_month,
		count(*) number_of_listings
	FROM listings 
	GROUP BY neighborhood
	)

SELECT
	r.neighborhood,
	r.reviews_per_month*r.number_of_listings weighted_reviews,
	r.reviews_per_month avg_monthly_reviews,
	r.number_of_listings,
	a.percent_available
FROM
	neighborhood_reviews r
JOIN
	neighborhood_availability a
ON
	r.neighborhood = a.neighborhood
ORDER BY weighted_reviews



-- What time of year is the cheapest time to go to your city? What about the busiest?

-- June, August, and November are the cheapest months to stay at an Airbnb in Oakland. 
-- July, February, and January are the busiest months.

WITH
	monthly_reviews
AS (
	SELECT 
		strftime('%m',date) month,
		COUNT(*) number_of_reviews
	FROM
		reviews
	GROUP BY
		month
	),
	monthly_price
AS (
	SELECT
		strftime('%m',date) month,
		SUM(available)/COUNT(available) percent_available,
		avg(price) avg_price
	FROM
		calendar
	GROUP BY
		month
		)
		
SELECT
	r.month,
	r.number_of_reviews,
	p.avg_price,
	p.percent_available
FROM
	monthly_reviews r
JOIN
	monthly_price p
ON
	r.month = p.month