/* 1a. List of all actors with first and last name*/
SELECT first_name, last_name FROM actor;
/* 1b. Display a column called actor name that displays
their first and last name in a single column*/
SELECT CONCAT(first_name, ' ', last_name) 
AS 'Actor Name' FROM actor;
/* 2a. Find the ID number, first name and last name of an
actor, of whom you know only the first name 'Joe'*/
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';
/* 2b. Find all actors whose last name contains the letters
GEN*/
SELECT first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';
/* 2c. Find all actors whose last name contain the letters LI.
Order the rows by last name and then first name*/
SELECT last_name, first_name FROM actor
WHERE last_name LIKE '%LI%';
/* 2d. Using IN, display the country_id and country columns
of the following countries: Afghanistan, Bangladesh, China*/
SELECT country_id, country FROM country
WHERE country IN('Afghanistan', 'Bangladesh', 'China');
/* 3a. Add middle_name column to the table actor. Position
it between first_name and last_name*/
ALTER TABLE actor ADD COLUMN middle_name VARCHAR(50);
SELECT * FROM actor;
/* 3b. Change the data type of the middle_name columns to
blobs*/
ALTER TABLE actor 
CHANGE COLUMN middle_name middle_name BLOB;
/* 3c. Now delete the middle_name column*/
ALTER TABLE actor DROP COLUMN middle_name;
/* 4a. List the last name of actors as well as how many
actors have that last name*/
SELECT last_name, COUNT(*) last_name_count
FROM actor GROUP BY last_name HAVING COUNT(*) > 0
ORDER BY COUNT(*) DESC;
/* 4b. List last names of actors and the number of actors
who have the last name, but only for the names that are 
shared by at least two actors*/
SELECT last_name, COUNT(*) last_name_count
FROM actor GROUP BY last_name HAVING COUNT(*) >= 2
ORDER BY COUNT(*) DESC;
/* 4c. Change Groucho Williams to Harpo Williams*/
UPDATE actor SET first_name = 'HARPO'
WHERE actor_id = 172;
/* 4d. Change Harpo Williams back to Groucho Williams*/
UPDATE actor SET first_name = 'GROUCHO'
WHERE actor_id = 172;
/* 5a. Can't locate the schema of the address table. Which 
query would you use to re-create it?*/
SHOW CREATE TABLE address;
/* 6a. Use join to display the first and last names as well
as address of each staff member. Use the table staff and
address*/
SELECT staff.first_name, staff.last_name, address.address 
FROM staff JOIN address 
ON staff.address_id = address.address_id;
/* 6b. Use join to display the total amount rung up by
each staff member in August 2005. Use staff and payment tables*/
SELECT staff.first_name, staff.last_name, SUM(payment.amount) 
AS august_2005_total
FROM staff JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY staff.staff_id;
/* 6c. List each film and the number of actors who are listed
in that film. Use tables film_actor and film. Use inner join*/
SELECT film.title, COUNT(film_actor.actor_id)
AS actor_count
FROM film JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.film_id;
/* 6d. How many copies of the film Hunchback Impossible
exist in the inventory system?*/
SELECT COUNT(*) FROM inventory WHERE film_id IN (
	SELECT film_id FROM film 
	WHERE title = 'Hunchback Impossible'); 
/* 6e. Using the tables payment and customer, use join to list
the total paid by each customer. List the customer alphabetically
by last name*/
SELECT customer.first_name, customer.last_name, SUM(payment.amount)
AS total_amount_paid
FROM customer JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;
/* 7a. Use subqueries to display the titles of movies starting
with the letter K and Q whose language is English*/
SELECT title FROM film WHERE language_id IN (
	SELECT language_id FROM language 
    WHERE name = 'English')
AND (title LIKE 'K%') OR (title LIKE 'Q%');

/* 7b. Use subqueries to display all actors who appear in
the film Alone Trip*/
SELECT first_name, last_name FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
	WHERE film_id IN ( 
		SELECT film_id FROM film
		WHERE title = 'Alone Trip'));
/* 7c. Find names and email addresses for all Canadian
customers. Use joins to retrieve this information*/
SELECT customer.first_name, customer.last_name, customer.email
FROM customer JOIN address
ON customer.address_id = address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id
WHERE country = 'Canada';
/* 7d. Identify all movies categorized as family films*/
SELECT * FROM film_list
WHERE category = 'Family';
/* 7e. Display the most frequently rented movies in
descending order*/
SELECT film.title, COUNT(rental.inventory_id) AS rental_frequency
FROM film JOIN inventory
ON film.film_id = inventory.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
GROUP BY film.title
ORDER BY rental_frequency DESC;
/* 7f. Write a query to display how much business in dollars
each store brought in*/
SELECT store.store_id, SUM(amount) AS gross
FROM payment JOIN rental
ON payment.rental_id = rental.rental_id
JOIN inventory 
ON inventory.inventory_id = rental.inventory_id
JOIN store
ON store.store_id = inventory.store_id
GROUP BY store.store_id;
/* 7g. Write a query to display for each store its store
ID, city, and country*/
SELECT store.store_id, city.city, country.country
FROM store JOIN address
ON store.address_id = address.address_id
JOIN city 
ON city.city_id = address.city_id
JOIN country
ON country.country_id = city.country_id;
/* 7h. List the top 5 genres in gross revenue in descending
order (Hint: you may need to use the following tables:
category, film_category, inventory, payment, and rental)*/
SELECT category.name, SUM(payment.amount) AS gross_revenue
FROM category JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON inventory.film_id = film_category.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY gross_revenue DESC
LIMIT 5;
/* 8a. You need to have an easy way of viewing the top 5
genres by gross revenue. Use the solution from the problem
above to create a view. If you haven't solved 7h, you can 
substitue another query to create a view*/
CREATE VIEW top_five_genres AS
SELECT category.name, SUM(payment.amount) AS gross_revenue
FROM category JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON inventory.film_id = film_category.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY gross_revenue DESC
LIMIT 5;
/* 8b. How would you display the view that you created
in 8a?*/
SELECT * FROM top_five_genres;
/* 8c. You find that you no longer need the view top_five_genres.
Write a query to delete it*/
DROP VIEW top_five_genres;