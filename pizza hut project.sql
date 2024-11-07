select * from pizza_types
select * from order_details;
select * from pizzas
select * from orders;


-- 1.Retrieve the total number of orders placed.

select count(order_id ) as total_order_placed
from orders 
  
--2.Calculate the total revenue generated from pizza sales.

select  sum(pizzas.price *order_details.quantity) as total_revenue
from pizzas
join order_details
on pizzas.pizza_id = order_details.pizza_id;
 

-- 3.Identify the highest-priced pizza.
 
 select pizza_types.name , pizzas.price
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

--4.Identify the most common pizza size ordered.


select count (order_details.order_id) as ordered, pizzas.size
from order_details
join pizzas
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by  ordered desc;

--5.List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name ,
sum(order_details.quantity) as total_quantity
from  Pizza_types
join pizzas
on  pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by total_quantity desc
limit 5;


--6.Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.catogory ,sum(order_details.quantity) as quantity
from pizza_types
join  pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join  order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.catogory
order by quantity desc;

--7.Determine the distribution of orders by hour of the day.


select extract(hour from orders.time)  as order_time, count(order_id) as order_per_day
from orders
group  by order_time
order by order_time ;

 
--8.Join relevant tables to find the category-wise distribution of pizzas.
 
select catogory , count(name) 
from pizza_types
group by catogory;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(per_day_order),2)from 
(select orders.date , sum(order_details.quantity) as per_day_order
from orders 
join order_details
on orders.order_id = order_details.order_id
group by orders.date) as a 

--10.Determine the top 3 most ordered pizza types based on revenue.



select pizza_types.name,round( sum(order_details.quantity * pizzas.price),2) as pizza_revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by pizza_revenue desc
limit 3;

--11.Calculate the percentage contribution of each pizza type to total revenue.


 
select pizza_types.catogory,
      round(sum(order_details.quantity * pizzas.price) / 
           (select  round(sum(order_details.quantity * pizzas.price),2) as total_revenue
            from order_details join pizzas
            on order_details.pizza_id = pizzas.pizza_id)*100,2) as revenue
from pizza_types 
join pizzas
  on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
 on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.catogory
order by revenue desc;

-- 12.Analyze the cumulative revenue generated over time.



select order_date ,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.date as order_date ,
sum(order_details.quantity  * pizzas.price ) as revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders 
on orders.order_id = order_details.order_id
group by orders.date) as sales;



 -- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category

select name ,catogory ,revenue from 
(select catogory,name ,revenue,
rank() over (partition by catogory order by revenue desc) as rn
from
   (select pizza_types.catogory ,
  pizza_types.name,
  sum((order_details.quantity)* pizzas.price) as revenue
  from pizza_types 
  join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.catogory ,pizza_types.name) as a)as b
where rn <= 3;



