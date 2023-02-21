-- 1. What is the total amount each customer spent at the restaurant?
  select customer_id,sum(price) from sales s join menu m on s.product_id=m.product_id 
  group by customer_id;
 -- Customer A spent 76$
 -- Customer b spent 74$
 -- Customer C spent 36$

-- 2. How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date) from sales group by customer_id; 
-- Customer A visited 4 times
-- Customer B visited 6 times
-- Customer C visited 2 times

-- 3. What was the first item from the menu purchased by each customer?
WITH CTE1 AS(
SELECT CUSTOMER_ID,PRODUCT_NAME,DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE) AS RNK FROM
SALES S JOIN MENU M ON S.PRODUCT_ID=M.PRODUCT_ID )
SELECT CUSTOMER_ID,PRODUCT_NAME FROM CTE1 WHERE RNK=1 GROUP BY CUSTOMER_ID,PRODUCT_NAME;
 
 -- Customer A’s first order are curry and sushi.
-- Customer B’s first order is curry.
-- Customer C’s first order is ramen.

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT PRODUCT_NAME,COUNT(S.PRODUCT_ID) AS CNT FROM SALES S JOIN MENU M ON S.PRODUCT_ID=M.PRODUCT_ID 
GROUP BY PRODUCT_NAME ORDER BY CNT DESC LIMIT 1;

-- Ramen is the most purchased item on the menu and purchased 8 times.

-- 5. Which item was the most popular for each customer?
with cte2 as(
select customer_id,s.product_id,product_name,count(s.product_id),dense_rank() 
over( partition by customer_id order by count(customer_id) desc)
as RNK from sales s join menu m on s.product_id=m.product_id group by customer_id,s.product_id,product_name )
select customer_id,product_name from cte2 where rnk=1 ;
-- Customer A and C’s favourite item is ramen.
-- Customer B enjoys all items in the menu.

-- 6 Which item was purchased first by the customer after they became a member?
with cte1 as(
select m.customer_id,product_name,dense_rank() over(partition by customer_id order by order_date) as rnk
from members m join sales s on m.customer_id = s.customer_id
join menu mn on s.product_id = mn.product_id
where order_date >= join_date) 
select customer_id,product_name from cte1 where rnk = 1;
-- After Customer A became a member, his/her first order is curry, whereas it’s sushi for Customer B.

-- 7 Which item was purchased just before the customer became a member?
with cte1 as(
select m.customer_id,product_name,dense_rank() over(partition by customer_id order by order_date desc) as rnk
from members m join sales s on m.customer_id = s.customer_id
join menu mn on s.product_id = mn.product_id
where order_date < join_date) 
select customer_id,product_name from cte1 where rnk = 1;
-- Customer A’s order before he/she became member is sushi and curry Both and Customer B’s order is sushi.

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id,count(Distinct s.product_id) as products,sum(price) 
from sales s join members m on s.customer_id = m.customer_id
join menu mn on s.product_id = mn.product_id where order_date < join_date group by s.customer_id ;
-- Customer A spent $ 25 on 2 items.
-- Customer B spent $40 on 2 items.

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
	-- how many points would each customer have?
with cte1 as(
select *,case when product_id = 1 then price * 20 else price * 10 end as points from 
menu)
select customer_id,sum(points) from cte1 ct join sales s on ct.product_id = s.product_id
group by customer_id;
-- Total points for Customer A, B and C are 860, 940 and 360.

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on 
	-- all items, not just sushi - how many points do customer A and B have at the end of January?
with cte2 as(
SELECT *, 
 DATE_ADD(JOIN_DATE,INTERVAL 6 DAY) AS WEEK_DATE , 
  LAST_DAY('2021-01-31') AS last_date
 FROM members AS m)
 SELECT CT.customer_id, s.order_date, CT.join_date, 
 CT.WEEK_date, CT.last_date, m.product_name, m.price,
 SUM(CASE WHEN M.product_name = 'sushi' THEN 2 * 10 * m.price
  WHEN s.order_date BETWEEN CT.join_date AND CT.WEEK_date THEN 2 * 10 * m.price
  ELSE 10 * m.price END) AS points
FROM CTE2 AS CT JOIN sales AS s
 ON CT.customer_id = s.customer_id
JOIN menu AS m
 ON s.product_id = m.product_id
WHERE s.order_date < CT.last_date
GROUP BY CT.customer_id, s.order_date, CT.join_date, CT.WEEK_date, CT.last_date, m.product_name, m.price
ORDER BY CT.CUSTOMER_ID;
-- Customer A has 1370points.
-- Customer B has 820 points.

 
 
 
 
 
 




 




























  
  