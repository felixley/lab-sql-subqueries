-- How many copies of the film Hunchback Impossible exist in the inventory system?
select a.film_id, a.Copies, b.title from 
(select film_id, count(inventory_id) as Copies
from sakila.inventory
group by film_id) as a
join sakila.film as b
using(film_id)
where b.title = 'Hunchback Impossible';

-- List all films whose length is longer than the average of all the films.
select film_id, title, length 
from sakila.film 
where length > (select avg(length) from sakila.film)
order by length desc;


-- Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id, first_name, last_name
from sakila.actor
where actor_id in
(select actor_id
from sakila.film_actor
where film_id in
	(select film_id
	from sakila.film
	where title = 'Alone Trip'))
order by last_name, first_name;

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select film_id, title
from sakila.film
where film_id in 
(select film_id 
from sakila.film_category
where category_id in
	
    (select category_id
	from sakila.category
	where name regexp 'family'))
order by title;

-- Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys 
-- and foreign keys, that will help you get the relevant information.

-- ================= Using subqueries ==========================
select customer_id, first_name, last_name, email
from sakila.customer
where address_id in 
	(select address_id 
	from sakila.address
	where city_id in

		(select city_id
		from sakila.city
		where country_id in 
	
			(select country_id
			from sakila.country
			where country = 'canada')
		)
	)	
order by last_name, first_name;
-- ================ Using joins ====================================
select customer_id, first_name, last_name, email
from sakila.customer as a
join sakila.address as b
using(address_id)
join sakila.city as c
using(city_id)
join sakila.country as d
using (country_id)
where country = 'canada';
-- ===================================================================


-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor 
-- that has acted in the most number of films. First you will have to find the most prolific actor 
-- and then use that actor_id to find the different films that he/she starred.

select actor_id, count(film_id) as NoFilms
from sakila.film_actor
group by actor_id;

select actor_id
from (select actor_id, count(film_id) as NoFilms
	from sakila.film_actor
	group by actor_id
	order by NoFilms desc
	limit 1) sub1 ;

select film_id 
from sakila.film_actor
where actor_id in (
	select actor_id
		from (select actor_id, count(film_id) as NoFilms
		from sakila.film_actor
		group by actor_id
		order by NoFilms desc
		limit 1) sub1)
;

select title 
from sakila.film
where film_id in (
	select film_id 
	from sakila.film_actor
	where actor_id in (
		select actor_id
			from (select actor_id, count(film_id) as NoFilms
			from sakila.film_actor
			group by actor_id
			order by NoFilms desc
			limit 1) sub1)
);
            
-- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer 
-- ie the customer that has made the largest sum of payments
select title
from sakila.film
where film_id in (

	select film_id
	from sakila.inventory
	where inventory_id in (

		select inventory_id
		from sakila.rental
		where customer_id = (
	
			select customer_id
			from sakila.payment
			group by customer_id
			order by sum(amount) desc
			limit 1
)));




-- Customers who spent more than the average payments.
select customer_id, sum(amount) as Sum 
from sakila.payment
group by customer_id
having sum(amount) > (

	select round(avg(payments),2) as Average from (

		select sum(amount) as payments
		from sakila.payment
		group by customer_id
		order by payments desc
) 	sub1)
order by Sum desc;