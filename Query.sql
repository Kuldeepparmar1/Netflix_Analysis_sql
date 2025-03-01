Drop table if exists netflix;
CREATE  TABLE netflix
(
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(210),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(150),
	description VARCHAR(250)
);
SELECT * FROM NETFLIX;

select 
    count(*) 
from netflix;

select distinct type from netflix;

-- 1. Count the number of Movies vs TV Shows

SELECT TYPE, COUNT(*) AS TOTAL_COUNT FROM NETFLIX GROUP BY TYPE

-- 2. Find the most common rating for movies and TV shows
SELECT TYPE,RATING FROM
(SELECT 
   type,
   RATING,
   COUNT(*),
   RANK() OVER(PARTITION BY type order by COUNT(*) DESC) AS ranking
FROM NETFLIX
group by 1,2) AS t1 where ranking =1


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT
   * 
FROM netflix 
WHERE 
    type='Movie'
	and
	release_year=2020

-- 4. Find the top 5 countries with the most content on Netflix

select unnest(STRING_TO_ARRAY(COUNTRY,',')) AS new_country ,count(show_id)
as total_count from  netflix group by 1 order by total_count desc limit 5


-- 5. Identify the longest movie

select * from 
 (select distinct title as movie,
  split_part(duration,' ',1):: numeric as duration 
  from netflix
  where type ='Movie') as subquery
where duration = (select max(split_part(duration,' ',1):: numeric ) from netflix)

-- 6. Find content added in the last 5 years

select * from netflix
 where 
      TO_DATE(date_added,'Month DD,YYYY')>= CURRENT_DATE-INTERVAL
	  '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT 
   TITLE,TYPE,director
   FROM netflix 
   WHERE director Ilike '%Rajiv Chilaka%'
   
-- 8. List all TV shows with more than 5 seasons

SELECT 
* 
FROM NETFLIX
WHERE  
    type ='TV Show'
	AND
	SPLIT_PART(duration,' ', 1) :: numeric >5


-- 9. Count the number of content items in each genre

SELECT
   UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
   count(show_id) as total_content
FROM netflix
GROUP BY 1

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

SELECT
 EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) as year,
 COUNT(*) AS yearly_content,
 ROUND(
 COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::NUMERIC * 100
 ,2) AS avg_content_per_year
FROM netflix
WHERE country= 'India'
GROUP BY 1

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in ILIKE '%DOCUMENTARIES%'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
* FROM netflix
WHERE 
  casts ILIKE '%Salman Khan%'
  AND
  release_year >= EXTRACT(YEAR FROM CURRENT_DATE)-10
  
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) AS total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

WITH new_table
AS
(
SELECT
*,
  CASE
  WHEN
      description ILIKE '%kill%' OR
	  description ILIKE '%voilence%' THEN 'Bad_content'
	  ELSE 'Good_content'
	  END category
FROM netflix
)
SELECT 
    category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1

