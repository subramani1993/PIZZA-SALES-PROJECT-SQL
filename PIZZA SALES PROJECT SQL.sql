--1.Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;



--2. Calculate the total revenue generated from pizza sales.


select sum(pizzas.price) as total_sales
from pizzas;


--3. Identify the highest-priced pizza.


select pizza_types.name,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc;


--4.Join the necessary tables to find the total quantity of each pizza category ordered.


select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by quantity desc;


--5.Determine the distribution of orders by hour of the day

select count(order_id) as order_count
from orders;
 
 

--6.Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) 
from pizza_types
group by category;



--7.Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc;




--8.Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
round(sum(order_details.quantity*pizzas.price) / (select round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id)*100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category 
order by revenue desc;


--9.Analyze the cumulative revenue generated over time

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;



--10.Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category,pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b 
where rn <=3;



--11.Identify the most common pizza size ordered

select pizzas.size
from (select pizzas.size_,count(*) as size_count
from orders
group by pizzas.size 
order by size_count desc)
where rownum = 1;

--12.List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by quantity desc 
where rownum<=5;

--13.Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0)
from 
(select orders.order_date,sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id =  order_details.order_id
group by orders.order_date) as order_quantity;