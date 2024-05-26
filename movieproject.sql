/* Analysis 1000 movies from IMDB */


-- Selecting all data from the table

SELECT *
FROM movieproject.imdb_top_1000;


-- Selecting initial data to start analysis

SELECT series_title, released_year, runtime, genre, imdb_rating
FROM imdb_top_1000
WHERE released_year IS NOT NULL
ORDER BY 5 DESC, 2;


-- Looking for movies released after 2000

SELECT series_title, released_year, runtime, genre, imdb_rating
FROM imdb_top_1000
WHERE released_year > 2000
ORDER BY 5 DESC, 2;


-- Looking for movies directed by Peter Jackson

SELECT *
FROM imdb_top_1000
WHERE director = 'Peter Jackson'
ORDER BY IMDB_Rating;


-- Counting movies per decade

SELECT 
    FLOOR(released_year/10) * 10 AS decade,
    COUNT(*) AS movie_count
FROM imdb_top_1000
WHERE released_year IS NOT NULL
GROUP BY decade
ORDER BY decade DESC;


-- Average IMDb rating by decade

SELECT 
    FLOOR(released_year/10) * 10 AS decade,
    ROUND(AVG(imdb_rating), 2) AS average_rating
FROM imdb_top_1000
WHERE released_year IS NOT NULL
GROUP BY decade
ORDER BY decade DESC;


-- Top 10 directors with most movies

SELECT 
    director, 
    COUNT(series_title) AS count_movies
FROM imdb_top_1000
GROUP BY director
ORDER BY count_movies DESC
LIMIT 10;


-- Distribution of movie runtimes

SELECT 
    CASE 
        WHEN runtime <= 90 THEN 'Short (<90 min)'
        WHEN runtime BETWEEN 91 AND 120 THEN 'Medium (91-120 min)'
        WHEN runtime BETWEEN 121 AND 150 THEN 'Long (121-150 min)'
        ELSE 'Very Long (>151 min)'
    END AS runtime_category,
    COUNT(Series_Title) AS movies_count  
FROM imdb_top_1000
GROUP BY runtime_category;


-- Actors who have acted in the most films

SELECT star1 AS actor, COUNT(*) AS movie_count
FROM imdb_top_1000
GROUP BY star1
UNION ALL
SELECT star2 AS actor, COUNT(*) AS movie_count
FROM imdb_top_1000
GROUP BY star2
UNION ALL
SELECT star3 AS actor, COUNT(*) AS movie_count
FROM imdb_top_1000
GROUP BY star3
UNION ALL
SELECT star4 AS actor, COUNT(*) AS movie_count
FROM imdb_top_1000
GROUP BY star4
ORDER BY movie_count DESC;


-- The highest grossing movies

SELECT series_title, gross
FROM imdb_top_1000
WHERE gross IS NOT NULL
ORDER BY CAST(REPLACE(gross, ',', '') AS UNSIGNED) DESC
LIMIT 10;


-- Using CTE to find movies with the highest and lowest IMDb ratings per year

WITH MaxRatings AS (
    SELECT 
        released_year, 
        series_title AS max_series_title, 
        imdb_rating AS max_imdb_rating
    FROM imdb_top_1000
    WHERE 
        (released_year, imdb_rating) IN (
            SELECT 
                released_year, 
                MAX(imdb_rating)
            FROM imdb_top_1000
            GROUP BY released_year
        )
),
MinRatings AS (
    SELECT 
        released_year, 
        series_title AS min_series_title, 
        imdb_rating AS min_imdb_rating
    FROM imdb_top_1000
    WHERE 
        (released_year, imdb_rating) IN (
            SELECT released_year, MIN(imdb_rating)
            FROM imdb_top_1000
            GROUP BY released_year
        )
)
SELECT max.released_year, max.max_series_title, max.max_imdb_rating, min.min_series_title, min.min_imdb_rating
FROM MaxRatings max
JOIN MinRatings min ON max.released_year = min.released_year
ORDER BY max.released_year;


-- Creating a temporary table for the top 10 movies by Metascore

CREATE TEMPORARY TABLE Top10MetaScore AS
SELECT series_title, released_year, imdb_rating, meta_score, genre
FROM imdb_top_1000
ORDER BY meta_score DESC
LIMIT 10;


-- Using the temporary table to find the top movies by IMDb rating

SELECT series_title, released_year, imdb_rating, meta_score, genre
FROM Top10MetaScore
ORDER BY imdb_rating DESC
LIMIT 10;


-- Using window function to rank movies by IMDb rating within each year

SELECT 
    series_title, 
    released_year, 
    imdb_rating, 
    RANK() OVER (PARTITION BY released_year ORDER BY imdb_rating DESC) AS rank_per_year
FROM imdb_top_1000
ORDER BY released_year, rank_per_year;


-- Creating a view for the top 10 movies by IMDb rating

CREATE OR REPLACE VIEW Top10IMDBRating AS
SELECT 
    series_title, 
    released_year, 
    imdb_rating, 
    genre
FROM 
    imdb_top_1000
ORDER BY 
    imdb_rating DESC
LIMIT 10;


-- Using the view to select top 10 movies

SELECT * FROM Top10IMDBRating;