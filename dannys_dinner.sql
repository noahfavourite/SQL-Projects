/* The goal of the project is to use SQL to answer questions that will help Danny get deeper insights about is customers visiting patterns, 
how much money they’ve spent and also which menu items are their favourite. 
Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. */

-- Creating database and tables --
CREATE DATABASE dannys_diner;

USE dannys_diner;

CREATE TABLE sales
(customer_id    VARCHAR(50),
order_date      DATE,
product_id      INT);

INSERT INTO sales 
(customer_id, order_date, product_id)
VALUES
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3')
;

USE dannys_diner;
CREATE TABLE menu
(product_id     INT,
product_name    VARCHAR(50),
price           INT);

INSERT INTO menu
(product_id, product_name, price)
VALUES
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');

USE dannys_diner;
CREATE TABLE members
(customer_id     VARCHAR(50),
 join_date       DATE);

INSERT INTO members
(customer_id, join_date)
VALUES 
('A', '2021-01-07'),
('B', '2021-01-09');

 -- dataset overview --
SELECT * FROM dannys_diner.sales;
SELECT * FROM dannys_diner.members;
SELECT * FROM dannys_diner.menu;

-- Showing total amount spent by each customer --
SELECT customer_id, SUM(price)
FROM dannys_diner.sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id;

-- Showing number of days each customer visisted the resturant --
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
FROM dannys_diner.sales
GROUP BY customer_id;

-- Showing first item purchased by each customer --
WITH t2 AS
(SELECT customer_id, s.product_id, order_date, product_name,
RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranked_number
FROM dannys_diner.sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id)
SELECT customer_id, product_name
FROM t2
WHERE ranked_number = '1'
GROUP BY customer_id, product_name;

-- Showing most purchased item and how many times it was purchased --
WITH t3 AS (SELECT product_name, COUNT(product_name) AS total_purchase
FROM dannys_diner.sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY total_purchase DESC)
SELECT product_name, total_purchase
FROM t3
WHERE total_purchase = '8';

-- Showing most popular item for each customer --
WITH t4 AS 
(SELECT customer_id, product_name, COUNT(s.product_id) AS orders_count,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(customer_id) DESC) AS rnk
FROM dannys_diner.sales AS s
JOIN menu AS m
ON s.product_id =m.product_id
GROUP BY customer_id, product_name)
SELECT customer_id, product_name AS popular_item, orders_count
FROM t4
WHERE rnk = '1';

-- Showing first purchased item by customers after becoming a member --
WITH t5 AS
(SELECT s.customer_id, order_date, join_date, s.product_id, product_name,
DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS purchase_rank
FROM dannys_diner.sales AS s
JOIN members AS mb
ON s.customer_id = mb.customer_id
JOIN menu AS m
ON s.product_id = m.product_id
WHERE order_date >= '2021-01-07'
ORDER BY customer_id)
SELECT customer_id, order_date,join_date, product_name AS first_purchased_item
FROM t5
WHERE purchase_rank = '1';

-- Showing item purchased just before customer became a memeber --
SELECT s.customer_id, order_date, join_date, product_name
FROM dannys_diner.sales AS s
JOIN members AS mb
ON s.customer_id = mb.customer_id
JOIN menu AS m
ON s.product_id = m.product_id
WHERE order_date < '2021_01-07'
GROUP BY s.customer_id, order_date, join_date, product_name 
ORDER BY customer_id;

-- Total items and amount spent by each customer before they became a member --
SELECT s.customer_id, COUNT(DISTINCT product_name) AS total_items, SUM(price) AS total_amount
FROM dannys_diner.sales AS s
JOIN members AS mb
ON s.customer_id = mb.customer_id
JOIN menu AS m
ON s.product_id = m.product_id
WHERE order_date < '2021-01-07'
GROUP BY customer_id
ORDER BY total_amount DESC;

-- Showing points for each customer if each $1 spent equates to 10 points and sushi has a 2x points multiplier --
WITH t5 AS 
(SELECT customer_id, product_name, price,
CASE 
WHEN product_name = 'sushi' THEN price * '20'
ELSE price * 10
END AS points
FROM dannys_diner.sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id)
SELECT customer_id, SUM(points) AS customer_points
FROM t5
GROUP BY customer_id;

-- Showing how many points customer A and B have at the end of january after earning 2x points on all items in the first week of joining the program --
WITH t6 AS 
(SELECT s.customer_id, order_date, price, join_date, product_name,
CASE 
WHEN order_date BETWEEN '2021-01-07' AND '2021-01-13' THEN price * '20'
ELSE price * '1'
END AS points
FROM dannys_diner.sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
JOIN members AS mb
ON s.customer_id = mb.customer_id
ORDER BY join_date)
SELECT customer_id, SUM(points) AS january_points
FROM t6 
WHERE order_date <='2021-01-31'
GROUP BY customer_id
ORDER BY customer_id;












