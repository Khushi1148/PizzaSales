create database pizzasales;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

-- QUERIES

-- Retrieve the total number of orders placed.

select count(*) from orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS TotalRevenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Identify the highest-priced pizza.

select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc limit 1;


-- Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as cnt from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by cnt desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(order_details.quantity) as quantityOrdered
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantityOrdered desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered
select pizza_types.category, sum(order_details.quantity) as QuantityOrdered
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY order_count DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(*)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day
select round(avg(quantity),0) from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date)  order_quantity_by_date;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, sum(pizzas.price*order_details.quantity) as Revenue
from pizzas
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by Revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
set @totalRevenue = (SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2) AS TotalRevenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id);
    
select pizza_types.category, round((sum(order_details.quantity*pizzas.price)/@totalRevenue)*100,2) as revenuePercent
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by revenuePercent desc;

-- Analyze the cumulative revenue generated over time.

select order_date, revenue, 
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, sum(order_details.quantity*pizzas.price) as revenue
from order_details 
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue
from
(
select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from 
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) t
) a
where rn<=3;







