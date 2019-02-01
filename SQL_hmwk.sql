-- 1a. Display the first and last names of all actors from the table `actor`.
Use sakila;
SELECT * FROM actor;
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT CONCAT(first_name," ", last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:

SELECT * FROM actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country WHERE country_id IN (1, 12, 23);

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(last_name) AS count_alias FROM actor GROUP BY  last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, count(last_name) AS count_alias FROM actor GROUP BY last_name HAVING count_alias = 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor SET first_name = 'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
-- SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT staff.first_name, staff.last_name, address.address, address.district
FROM staff
JOIN address
USING (address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT SUM(payment.amount) AS payment_alias, payment.payment_date, staff.first_name, staff.last_name
FROM payment
JOIN staff
USING (staff_id) WHERE payment.payment_date LIKE '%2005-08-01%' GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT count(film_actor.actor_id) AS actors_count, film.title AS film
FROM film_actor
INNER JOIN film ON
film.film_id=film_actor.film_id GROUP BY film.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT count(film_id) AS Total_Hunchback_Impossible FROM inventory WHERE film_id = 439;

-- another method using join

SELECT count(inventory.film_id) AS Total_Hunchback_Impossible, film.title
FROM inventory
INNER JOIN film ON
inventory.film_id=film.film_id WHERE film.title LIKE '%Hunchback Impossible%';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'Total Amount Paid'
FROM customer
LEFT JOIN payment ON customer.customer_id = payment.customer_id GROUP BY customer.last_name  ORDER BY customer.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title, language_id FROM film WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id IN
(SELECT language_id FROM language WHERE name LIKE 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id IN (SELECT film_id FROM film WHERE title = 'ALONE TRIP')); 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email, d.country
FROM customer AS c
INNER JOIN address AS a ON c.address_id=a.address_id
INNER JOIN city AS b ON a.city_id=b.city_id
INNER JOIN country AS d ON b.country_id = d.country_id
WHERE d.country='Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN
(
SELECT film_id
FROM film_category
WHERE category_id IN
(
SELECT category_id
FROM category
WHERE name ='family'));

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, count(inventory.film_id) AS frequency
FROM film
JOIN inventory ON film.film_id=inventory.film_id
JOIN rental ON inventory.inventory_id=rental.inventory_id
GROUP BY inventory.film_id
ORDER BY frequency DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff_id AS store,concat('$', format(sum(amount),2)) as total_amount FROM payment GROUP BY staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, b.city, d.country
FROM store AS s
INNER JOIN address AS a ON s.address_id=a.address_id
INNER JOIN city AS b ON a.city_id=b.city_id
INNER JOIN country AS d ON b.country_id = d.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (*Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT main.name, main.revenue FROM
(
SELECT a.name, sum(p.amount) AS revenue
FROM payment AS p
JOIN rental AS d ON p.rental_id=d.rental_id
JOIN inventory AS c ON d.inventory_id=c.inventory_id
JOIN film_category AS b ON c.film_id=b.film_id
JOIN category AS a ON b.category_id=a.category_id
GROUP BY name
)AS main
WHERE main.revenue > 4300 ORDER BY main.revenue DESC LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW GENRE AS SELECT main.name, main.revenue FROM
(
SELECT a.name, sum(p.amount) AS revenue
FROM payment AS p
JOIN rental AS d ON p.rental_id=d.rental_id
JOIN inventory AS c ON d.inventory_id=c.inventory_id
JOIN film_category AS b ON c.film_id=b.film_id
JOIN category AS a ON b.category_id=a.category_id
GROUP BY name
)AS main
WHERE main.revenue > 4300 ORDER BY main.revenue DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM GENRE;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW GENRE;