-- I'm a restaurant owner, create 5 tables
-- 1 fact, 4 dimension
-- Search google, how to add foreign key
-- Write SQL 3-5 queries to analyze data
-- Subquery or WITH
-- sqlite command, edit view
.mode column
.header on

-- dim_product_type (1)
CREATE TABLE dim_product_types(
  product_type_id int Primary Key,
  product_type text
);
INSERT INTO dim_product_types VALUES
  (1, 'Side dish'),
  (2, 'Main dish'),
  (3, 'Dessert'),
  (4, 'Beverage');
-- dim_server (2)
CREATE TABLE dim_servers(
  server_id int Primary Key,
  firstname text,
  lastname text,
  gender text,
  age int
);
INSERT INTO dim_servers VALUES
  (1, "Somchai", "Mairoo", "Male", 24),
  (2, "Somsri", "Kreemen", "Female", 28),
  (3, "Sommai", "Haipainai", "Male", 32);
-- dim_segment (3)
CREATE TABLE dim_segment(
  segment_id int Primary Key,
  segment text
);
INSERT INTO dim_segment VALUES 
  (1, 'Teenagers'),
  (2, 'Family'),
  (3, 'Office workers'),
  (4, 'Others');

-- dim_payment (4)
CREATE TABLE dim_payment(
  payment_id int Primary Key,
  payment_type text
);
INSERT INTO dim_payment VALUES
  (1, 'CASH'),
  (2, 'Credit card');

-- fact_table
CREATE TABLE fact_orders(
  order_id int PRIMARY KEY,
  datetime_start text,
  datetime_end text,
  n_customer int,
  server_id int,
  segment_id int,
  payment_id int,
  is_smoke TEXT,
  FOREIGN KEY(server_id) REFERENCES dim_servers(server_id),
  FOREIGN KEY(segment_id) REFERENCES dim_segment(segment_id),
  FOREIGN KEY(payment_id) REFERENCES dim_payment(payment_id)
);
INSERT INTO fact_orders VALUES
  (1,"2022-08-01 11:05:00", "2022-08-01 12:30:12", 1, 1, 1, 1, False),
  (2,"2022-08-01 12:10:53", "2022-08-01 12:50:12", 2, 2, 3, 1, False),
  (3,"2022-08-01 16:10:23", "2022-08-01 18:40:01", 3, 1, 2, 2, False),
  (4,"2022-08-02 13:47:47", "2022-08-02 15:03:20", 2, 2, 4, 1, True),
  (5,"2022-08-02 18:32:39", "2022-08-02 21:39:11", 3, 3, 2, 2, True);
 
-- dim_product (5)
CREATE TABLE dim_products(
  product_id int Primary Key,
  product_name text,
  product_type_id int,
  unit_price real,
  FOREIGN KEY(product_type_id) REFERENCES dim_product_types(product_type_id)
);
INSERT INTO dim_products VALUES
  (1, 'French Fries', 1, 80),
  (2, 'Pizza', 1, 250),
  (3, 'Ice cream', 2, 60),
  (4, 'Pepsi', 3, 20);
  
-- create bridge
CREATE TABLE bridge_order_product(
  order_id int,
  product_id int,
  quantity int,
  FOREIGN KEY(order_id) REFERENCES fact_orders(order_id),
  FOREIGN KEY(product_id) REFERENCES dim_products(product_id)
);
INSERT INTO bridge_order_product VALUES
  (1, 2, 1),
  (1, 3, 1),
  (1, 4, 2),
  (2, 3, 1),
  (2, 2, 2),
  (3, 4, 1),
  (3, 2, 2),
  (4, 2, 1),
  (4, 1, 3),
  (4, 3, 1),
  (5, 3, 2),
  (5, 2, 1),
  (5, 4, 2),
  (5, 1, 2);

-- average duration stayed for each segment
SELECT 
  sub.Segment, 
  avg(sub.Durations) AS average_stay_time
FROM (
  SELECT
      seg.segment AS Segment, 
      Cast((JULIANDAY(datetime_end) - JULIANDAY(datetime_start)) * 24 * 60 AS int) AS Durations
  FROM fact_orders AS ord
  JOIN dim_segment AS seg ON ord.segment_id = seg.segment_id
  ) AS sub
GROUP BY 1
ORDER BY 2 DESC;
-- average spending for each segment
WITH joined_table AS (
  SELECT 
      seg.segment,
  	  brd.quantity,
  	  prod.unit_price
  FROM fact_orders as ord
  JOIN bridge_order_product AS brd on brd.order_id = ord.order_id
  JOIN dim_products as prod ON brd.product_id = prod.product_id
  join dim_segment as seg on seg.segment_id = ord.segment_id
)
SELECT
	segment,
  AVG(quantity * unit_price) AS avg_spending
FROM joined_table
GROUP BY 1
order BY 2 desc;
-- average spending between non-smoke vs smoker
SELECT
	ord.is_smoke,
	AVG(brd.quantity * prod.unit_price) AS avg_spending
FROM fact_orders AS ord
JOIN bridge_order_product AS brd ON brd.order_id = ord.order_id
JOIN dim_products AS prod ON prod.product_id = brd.product_id
GROUP BY is_smoke;
-- the best seller product
WITH ranking AS (
  SELECT 
    prod.product_name AS product_name,
    COUNT(*) AS n
  FROM bridge_order_product AS ord
  JOIN dim_products AS prod ON ord.product_id = prod.product_id
  GROUP BY prod.product_name)
SELECT 
	product_name AS best_seller_item
FROM ranking 
WHERE n = (SELECT max(n) FROM ranking);
-- AVG sales, group by gender of servers
WITH data As(
  SELECT
      ser.gender,
      brd.quantity,
      prod.unit_price
  FROM fact_orders as ord
  JOIN dim_servers AS ser ON ord.server_id = ser.server_id
  JOIN bridge_order_product AS brd on brd.order_id = ord.order_id
  JOIN dim_products AS prod ON prod.product_id = brd.product_id)
SELECT
	gender,
    AVG(quantity * unit_price) AS avg_sales
FROM data
GROUP BY 1;
