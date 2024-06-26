/*1.Fetch all the paintings which are not displayed on any museums? */
SELECT * FROM work
WHERE museum_id IS NULL;

/*2.Are there museums without any paintings?
We perform a left outer join with tables museum and work
We are looking for museums_id from the museum table that are not included
in the work table*/
SELECT * FROM museum m
WHERE NOT EXISTS 
(SELECT FROM work w
WHERE w.museum_id = m.museum_id);
/*Solution from document*/
SELECT * FROM museum m
LEFT OUTER JOIN work w
ON m.museum_id = w.museum_id
WHERE w.museum_id IS NULL;

/*3.How many paintings have an asking price of more than their regular price?*/
SELECT COUNT(*) as total_count FROM product_size
WHERE sale_price > regular_price;

/*4.Identify the paintings whose asking price is less than 50% of its regular price*/
SELECT w.name, ps.sale_price, ps.regular_price, w.museum_id
FROM product_size ps
INNER JOIN work w
ON ps.work_id = w.work_id
WHERE sale_price < (regular_price*0.5);

/*5.Which canva size costs the most?*/
SELECT c.size_ide, ps.sale_price, c.label
FROM canvas_size c
FULL OUTER JOIN product_size ps
ON c.size_ide = ps.size_id
WHERE ps.sale_price IS NOT NULL
ORDER BY ps.sale_price DESC
LIMIT 1;
/*Another solution could be use the RANK() function.
We can not use aliases in a WHERE clause in this case 
we cannot do a RANK() and call the alias of the colum on
the WHERE clause. We have to create a subquery and then 
we can call the alias.*/
SELECT ps.size_id,label, sale_price,
RANK() OVER(order by sale_price DESC) as price_rnk
FROM product_size ps
JOIN canvas_size cs
ON ps.size_id = cs.size_ide
WHERE price_rnk=1;

SELECT ps.size_id, label, sale_price
FROM (SELECT *, RANK()OVER(order by sale_price DESC) as price_rnk
	 FROM product_size) as ps
JOIN canvas_size cs
ON ps.size_id = cs.size_ide
WHERE price_rnk=1;

/*Solution from Document*/
select cs.label as canva, ps.sale_price, cs.size_ide
from (select *, rank() over(order by sale_price desc) as rnk 
from product_size) ps
join canvas_size cs on cs.size_ide=ps.size_id
where ps.rnk=1;	

/*6.Delete duplicate records from work, product_size, subject and image_link tables*/
/*We can use the ctid which is an identifies of each row. Grouping by work_id
and then deleting the lowest ctid allows*/
/*Solution from document*/
DELETE FROM work 
WHERE ctid NOT IN 
(SELECT MIN(ctid)
FROM work
GROUP BY work_id );

DELETE FROM product_size 
WHERE ctid NOT IN 
(SELECT MIN(ctid)
FROM product_size
GROUP BY work_id );

DELETE FROM subject 
WHERE ctid NOT IN 
(SELECT MIN(ctid)
FROM subject
GROUP BY work_id );

DELETE FROM image_link 
WHERE ctid NOT IN 
(SELECT MIN(ctid)
FROM image_link
GROUP BY work_id );

/*7)Identify the museums with invalid city information in the given dataset*/
/*Using Regular Expressions operators*/
SELECT museum_id,name,city FROM museum
WHERE city ~'^\d.*$';
/*Solution from document*/
select museum_id,name,city from museum 
where city ~ '^[0-9].*$';


/*8)Museum_Hours table has 1 invalid entry. Identify it and remove it.*/

/*Check for museum_id
All 57 museum_id where correct
*/
SELECT mh.museum_id 
FROM museum_hours AS mh
LEFT OUTER JOIN museum AS m
ON mh.museum_id = m.museum_id
WHERE m.museum_id IS NULL
ORDER BY mh.museum_id;

/*Check for day of the week to be correct*/
/*One of the days is Thusday, we can delete it*/
SELECT DISTINCT day FROM museum_hours
ORDER BY day;
/*Deleting the day with typo*/
DELETE FROM museum_hours
WHERE day='Thusday';

/*9)Fetch the top 10 most famous painting subject*/
/*One way to do it, without ranking but couting the number of
times a subject appears in the table. Ordering by the count and 
limiting the result table to show only 10*/
SELECT subject, COUNT(subject) AS subject_count 
FROM subject
GROUP BY subject
ORDER BY subject_count DESC
LIMIT 10;
/*Second way of doing it. Using Rank(), but because we cannot use
the alias in the WHERE clause, we have to use a subquery in which
we calculate the rank of each subject based on their appeareance count.
Then we can call on the Ranking and limit the table to the first 10.*/
SELECT * FROM
(SELECT subject, COUNT(subject) as subject_count,
RANK() OVER(ORDER BY COUNT(subject) DESC) as ranking
FROM subject
GROUP BY subject) x
WHERE ranking <= 10;

/*Solution from the document. 
He uses a join between the work and subject tables to check the count.*/
select * 
	from (
		select s.subject,count(*) as no_of_paintings
		,rank() over(order by count(*) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10;

/*10) Identify the museums which are open on both Sunday and Monday. 
Display museum name, city.*/

SELECT DISTINCT sample.museum_id,m.name,m.city
FROM
	(SELECT day, museum_id,
	ROW_NUMBER() OVER(PARTITION BY museum_id) appearances
	FROM museum_hours
	WHERE day='Sunday' or day='Monday'
	ORDER BY museum_id) sample
JOIN museum m
ON sample.museum_id = m.museum_id
WHERE appearances =2;

/*11)How many museums are open every single day?*/

SELECT COUNT(x.museum_id)
FROM (
	SELECT day, museum_id,
	ROW_NUMBER() OVER(PARTITION BY museum_id) appearances
	FROM museum_hours
	ORDER BY museum_id) x
JOIN museum m
ON x.museum_id = m.museum_id
WHERE appearances = 7;

SELECT COUNT(*) 
FROM (
	SELECT museum_id, COUNT(*) appearances
	FROM museum_hours
	GROUP BY museum_id
	ORDER BY COUNT(*) DESC) x
WHERE appearances = 7;

/*12) Which are the top 5 most popular museum? 
(Popularity is defined based on most no of paintings in a museum)*/

SELECT museum_id, COUNT(work_id)
FROM work
WHERE museum_id NOTNULL
GROUP BY museum_id
ORDER BY COUNT(work_id) DESC
LIMIT 5;

/*We have to include the GROUP BY function since we have are counting 
the number of appearances in the table. We have to give something to divide
the table by, otherwise it will be one per row.*/
SELECT x.museum_id,m.name as name, x.count_paint
FROM
	(SELECT museum_id,COUNT(work_id) count_paint,
	RANK() OVER(ORDER BY COUNT(work_id) DESC) as ranking
	FROM work
	WHERE museum_id NOTNULL
	GROUP BY museum_id) x
JOIN museum m
ON x.museum_id = m.museum_id
WHERE x.ranking <= 5
ORDER BY x.count_paint DESC;

/*13) Who are the top 5 most popular artist? 
(Popularity is defined based on most no of paintings done by an artist)*/

SELECT x.artist_id,a.full_name,a.style,x.count_artist
FROM
	(SELECT artist_id, COUNT(artist_id) count_artist,
	RANK() OVER(ORDER BY COUNT(artist_id) DESC) as ranking
	FROM work
	WHERE artist_id NOTNULL
	GROUP BY artist_id) x
JOIN artist a
ON x.artist_id = a.artist_id
WHERE ranking <= 5
ORDER BY x.count_artist DESC;

/*14)Display the 3 least popular canva sizes*/
/*We have to check that the label is present in the work and canvas size tables.
That way we check that the labels are actually being used.*/

SELECT x.size_id, x.label, x.ranking
FROM
	(SELECT ps.size_id,cs.label, COUNT(ps.work_id),
	DENSE_RANK()OVER(ORDER BY COUNT(ps.work_id)) as ranking
	FROM product_size ps
	JOIN canvas_size cs ON ps.size_id = cs.size_ide
	JOIN work w ON w.work_id = ps.work_id
	GROUP BY ps.size_id, cs.label
	ORDER BY COUNT(ps.work_id)) x
WHERE x.ranking <= 3;


/*15) Which museum is open for the longest during a day. 
Dispay museum name, state and hours open and which day?*/

/*We have to convert the open and closing times to timestamp format.
With that we can calculate the difference of closing and opening times and 
have the duration for each day and each museum.
Then we perform a ranking and we get the top1*/
SELECT *
FROM
	(SELECT m.name,day,open,close,
	to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') as duration,
	RANK() OVER(ORDER BY to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') DESC) as ranking
	FROM museum_hours mh
	JOIN museum m
	ON mh.museum_id = m.museum_id) x
WHERE x.ranking = 1;

/*We can modify the query to get the museum that opens the longest for each
day of the week by doing a partition by day in the rank function*/
SELECT *
FROM
	(SELECT m.name,day,open,close,
	to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') as duration,
	RANK() OVER( PARTITION BY day ORDER BY to_timestamp(close,'HH:MI PM') - to_timestamp(open,'HH:MI AM') DESC) as ranking
	FROM museum_hours mh
	JOIN museum m
	ON mh.museum_id = m.museum_id) x
WHERE x.ranking = 1
ORDER BY x.duration desc;

/*16)Which museum has the most no of most popular painting style?*/
/*Create two CTE. First one will be pop_style.Here we will find the most popular
painting style.We do a count and a ranking to find this out.
Second cte will use the first one as it will need to know which style to use to filter.
Here we will use the tables work and museum as well to match the name, id and style per museum.
With the resulting table we will count the amount of painting per museum_id, name and style.
With this count we will make a ranking. This ranking will be general as it takes into account
every museum and style.
After doing the proper joins we will filter the tables, excluding the null values for museum_id
and only selecting the rows which correspond to the rank=1 of the pop_style table.
Using the last cte, we will select the columns name, style and no_of_paintings to show
the first rank museum of the table.*/
WITH pop_style as(
	SELECT style,COUNT(style),
	RANK()OVER(ORDER BY COUNT(style) DESC) rnk
	FROM work
	GROUP BY style),
	cte as(
		SELECT w.museum_id, m.name as museum_name, ps.style, COUNT(*)as no_of_paintings,
		RANK() OVER(ORDER BY COUNT(*)DESC)as rnk
		FROM work w
		JOIN museum m on m.museum_id = w.museum_id
		JOIN pop_style ps on ps.style = w.style
		WHERE w.museum_id IS NOT NULL and ps.rnk=1
		GROUP BY w.museum_id,m.name,ps.style)
SELECT museum_name, style, no_of_paintings
FROM cte
WHERE rnk = 1;

/*17)Identify the artists whose paintings are displayed in multiple countries*/

SELECT x.artist_id,x.full_name,COUNT(x.country) as count_countries
from (
	SELECT w.artist_id,art.full_name, m.country
	FROM work w
	JOIN artist art ON art.artist_id = w.artist_id
	JOIN museum m ON m.museum_id = w.museum_id
	GROUP BY w.artist_id,art.full_name, m.country
	ORDER BY w.artist_id) x
GROUP BY x.artist_id, x.full_name
HAVING COUNT(x.country) > 1
ORDER BY 3 DESC;

/*18) Display the country and the city with most no of museums. 
Output 2 seperate columns to mention the city and country. 
If there are multiple value, seperate them with comma.*/

/*First we create a CTE with a ranking of the countries with most museums.
We create the second CTE with a ranking of the cities with the most museums.
Then we can use both CTE. We create two colums 'Countries' and 'Cities'.
In each column use string_agg to concatenate each country or city.
We perform a Cross Join between both tables, this will result in a table with 
with a row for each country and city. But we can filter the results to those who
where rank as 1 in the previous cte's.With this we have the column with the countries ranked 1
in the country cte and another column with the cities ranked 1 in the city cte.*/
with cte_country as(
		SELECT country, COUNT(name) count_country,
		RANK() OVER(ORDER BY COUNT(name) DESC) as rnk
		FROM museum
		GROUP BY country
		ORDER BY COUNT(name) DESC),
	cte_city as (
		SELECT city, count(name) count_city,
		rank()over(order by count(name) desc) as rnk
		from museum
		group by city
		order by count(name) desc)
SELECT string_agg(DISTINCT country.country, ', ') as countries, string_agg(city.city,', ') as cities
FROM cte_country country
CROSS JOIN cte_city city
WHERE country.rnk = 1 and city.rnk=1

/*19)Identify the artist and the museum where the most expensive and least expensive painting 
is placed. Display the artist name, sale_price, painting name, museum name, museum city and 
canvas label*/
with cte as (
		select *,
		rank()over(order by sale_price desc) as rnk_desc,
		rank()over(order by sale_price) as rnk_asc
		from product_size)
select art.full_name artist_name, cte.sale_price, w.name painting_name, m.name museum_name,
	m.city museum_city,cs.label 
   	from work w
	join museum m on w.museum_id = m.museum_id
	join cte on cte.work_id = w.work_id
	join artist art on art.artist_id = w.artist_id
	join canvas_size cs on cs.size_ide = cte.size_id
where rnk_desc = 1 or rnk_asc = 1


/*20) Which country has the 5th highest no of paintings?*/

select * from
	(select m.country, count(w.work_id) count_paintings,
	rank() over(order by count(w.work_id)desc) as rnk
	from work w
	join museum m on m.museum_id = w.museum_id
	group by m.country) x
where x.rnk = 5

with cte as (
	select m.country, count(w.work_id) count_paintings,
	rank() over(order by count(w.work_id)desc) as rnk
	from work w
	join museum m on m.museum_id = w.museum_id
	group by m.country)
select * from cte
where cte.rnk = 5;


/*21)Which are the 3 most popular and 3 least popular painting styles?*/
/*if we want to have only two columns with the results without showing the 
rankings we can use a CASE clause and set a string for the cases in which
the rank are lower than 3. */

select style, case
	when rnk_desc <= 3 then 'Most popular'
	when rnk_asc <=3 then 'Least popular'
	end remarks
	from 
		(select style,count(style),
		rank() over(order by count(style) desc) rnk_desc,
		rank() over(order by count(style)) rnk_asc
		from work
		where style notnull
		group by style) x
where rnk_desc <= 3 or rnk_asc <= 3
order by remarks desc;


/*22) Which artist has the most no of Portraits paintings outside USA?. 
Display artist name, no of paintings and the artist nationality.*/

select name, no_paints, nationality from
	(select art.full_name name, count(w.work_id) no_paints, art.nationality nationality,
		rank() over(order by count(w.work_id) desc) rnk
	from work w
	join artist art on art.artist_id = w.artist_id
	join museum m on m.museum_id = w.museum_id
	join subject s on s.work_id = w.work_id
	where s.subject = 'Portraits' and m.country<>'USA'
	group by art.full_name, art.nationality) x
where rnk = 1;