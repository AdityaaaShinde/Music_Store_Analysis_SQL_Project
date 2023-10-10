-- EASY QUESTIONS

/* 1. Who is the senior most employee based on job title? */

SELECT * 
FROM employee
ORDER BY levels DESC
LIMIT 1

/* 2. Which countries have the most Invoices? */

SELECT COUNT (*) AS total_inv , billing_country
FROM invoice
GROUP BY billing_country
ORDER BY total_inv DESC

/* 3. What are top 3 values of total invoice? */

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

/* 4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

SELECT SUM (total) as total_inv , billing_city 
FROM invoice
GROUP BY billing_city
ORDER BY total_inv DESC
LIMIT 1

/* 5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */

SELECT c.customer_id, c.first_name, c.last_name, SUM (i.total) AS total_money_spent
FROM invoice AS i
JOIN customer  AS c
ON i.customer_id = c.customer_id
GROUP BY 1, 2, 3
ORDER BY total_money_spent DESC
LIMIT 1


-- MODERATE QUESTIONS

/* 1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

SELECT DISTINCT c.email, c.first_name , c.last_name, g.name as genre_name
FROM customer as c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id 
JOIN track AS t ON il.track_id = t.track_id
JOIN genre AS g ON t.genre_id = g.genre_id 

WHERE g.name LIKE 'Rock'
ORDER BY email ASC

/* 2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

SELECT a.name AS artist_name, COUNT (t.track_id) as track_count  
FROM artist AS a
JOIN album AS ab ON ab.artist_id = a.artist_id
JOIN track AS t ON t.album_id = ab.album_id
JOIN genre AS g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.name
ORDER BY track_count DESC
LIMIT 10

/* 3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */

SELECT name AS track_name , milliseconds
FROM track
WHERE milliseconds > (SELECT AVG (milliseconds) FROM track)
ORDER BY milliseconds DESC


-- ADVANCE QUESTIONS

/* 1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

SELECT CONCAT (c.first_name, c.last_name) AS customer_name,
       a.name AS artist_name ,
	   SUM (il.unit_price * il.quantity) AS total_spent
FROM customer AS c	 
JOIN invoice AS i ON i.customer_id = c.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS t ON t.track_id = il.track_id
JOIN album AS ab ON t.album_id = ab.album_id
JOIN artist AS a ON a.artist_id = ab.artist_id
GROUP BY 1, 2
ORDER BY total_spent DESC   

--My code

/* 2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


/* 3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */

WITH max_amount_spent AS 
(SELECT c.first_name , c.last_name, i.billing_country, SUM (i.total) AS amount_spent,
       ROW_NUMBER () OVER (PARTITION BY i.billing_country ORDER BY SUM (i.total) DESC) AS row_no
FROM customer AS c
JOIN invoice AS i ON i.customer_id = c.customer_id 
GROUP BY 1, 2, 3
ORDER BY 3 ASC, 4 DESC) 

SELECT * 
FROM max_amount_spent
WHERE row_no = 1






