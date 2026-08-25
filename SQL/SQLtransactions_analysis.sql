CREATE DATABASE upi_transaction_analytics;

USE upi_transaction_analytics;

select * from upi_transactions_cleaned

select count(*) from upi_transactions_cleaned

--unique transactions types--

select distinct transaction_type 
from upi_transactions_cleaned


--merchant category--

select distinct merchant_category
from upi_transactions_cleaned



--sender bank--

SELECT DISTINCT sender_bank
FROM upi_transactions_cleaned

--total transaction amount--

select sum(amount_inr) as total_transaction_amount
from upi_transactions_cleaned;

--average amount--

select round(avg(amount_inr),2)  average_amount
from upi_transactions_cleaned


--maximum amount--

select max(amount_inr) max_amount
from upi_transactions_cleaned


--minimum amount--

select min(amount_inr) min_amount
from upi_transactions_cleaned

--total transaction--

select count(*) total_transactions
from upi_transactions_cleaned


--transaction status--


select transaction_status, count(*) total
from upi_transactions_cleaned
group by transaction_status



--success rate--


select 
round(count(case 
when transaction_status = 'success' then 1
 end)*100/count(*),2) as succes_rate
from upi_transactions_cleaned


--fraud transaction--

select fraud_flag,count(*) fraud_transaction
from upi_transactions_cleaned
group by fraud_flag


--transaction type--


select transaction_type,count(*)
from upi_transactions_cleaned
group by transaction_type


--top merchant category--


select merchant_category, count(*)
from upi_transactions_cleaned
group by merchant_category
order by count(*) desc

--top state--

select sender_state,sum(amount_inr) as revenue
from upi_transactions_cleaned
group by sender_state
order by revenue desc

--top sender bank--

select sender_bank , sum(amount_inr) as amount
from upi_transactions_cleaned
group by sender_bank
order by amount desc


--total transaction by state--


select sender_state, count(*) as total_transaction
from upi_transactions_cleaned
group by sender_state
order by total_transaction desc;

--total amount by state--


select sender_state, sum(amount_inr) total_amount
from upi_transactions_cleaned
group by sender_state
order by total_amount desc


--average trasaction amount by state--


select sender_state,round(avg(amount_inr),2) avg_amount
from upi_transactions_cleaned
group by sender_state
order by avg_amount desc


--top banks by trasaction count--

select sender_bank,count(*) total_transaction_sb 
from upi_transactions_cleaned
group by sender_bank
order by total_transaction_sb desc;

--top banks by trasaction amount--

select sender_bank,round(sum(amount_inr),2) total_amount
from upi_transactions_cleaned
group by sender_bank
order by total_amount desc;

--merchant category analysis--

select merchant_category , count(*) total_trasaction ,round(sum(amount_inr),2) as total_amount
from upi_transactions_cleaned
group by merchant_category
order by total_amount desc


--state with more than 10000 transactions--

select sender_state , count(*) total_transaction 
from upi_transactions_cleaned
group by sender_state
having count(*) >10000
order by total_transaction

--bank revenue above 5 crore

select sender_bank,sum(amount_inr) total_amount
from upi_transactions_cleaned
group by sender_bank
having sum(amount_inr) >50000000
order by total_amount desc;

--merchant categories with average amount > 5000 rs

select merchant_category,round(avg(amount_inr),2) avg_amount
from upi_transactions_cleaned
group by merchant_category
having round(avg(amount_inr),2) >5000
order by avg_amount desc

--state having fraud --

select sender_state,count(*) fraud_transaction
from upi_transactions_cleaned
where fraud_flag = 1
group by sender_state
having count(*) >0
order by fraud_transaction desc



--transaction amount category--

select transaction_id,amount_inr,
case 
when amount_inr < 500
then 'Low'
when amount_inr between 500 and 5000 
then 'medium'
when amount_inr between 5001 and 20000 
then 'High'
else 'Very High'
end amount_category

from upi_transactions_cleaned


--fraud risk satus --
select transaction_id,fraud_flag,
case 
when fraud_flag = 1 then 'fraud'
else 'safe'
end fraud_status
from upi_transactions_cleaned



--week type--

SELECT
    transaction_id,
    is_weekend,
    CASE
        WHEN is_weekend = 1 THEN 'Weekend'
        ELSE 'Weekday'
    END AS week_type
FROM upi_transactions_cleaned;




--time slot--

SELECT
    transaction_id,
    hour_of_day,
    CASE
        WHEN hour_of_day BETWEEN 0 AND 5 THEN 'Night'
        WHEN hour_of_day BETWEEN 6 AND 11 THEN 'Morning'
        WHEN hour_of_day BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_slot
FROM upi_transactions_cleaned;




--success/failed transactions--

SELECT
    transaction_status,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM upi_transactions_cleaned),
        2
    ) AS percentage
FROM upi_transactions_cleaned
GROUP BY transaction_status;


--merchant category performance--

SELECT
    merchant_category,
    ROUND(SUM(amount_inr),2) AS total_amount,
    CASE
        WHEN SUM(amount_inr) >= 100000000 THEN 'Excellent'
        WHEN SUM(amount_inr) >= 50000000 THEN 'Good'
        ELSE 'Average'
    END AS performance
FROM upi_transactions_cleaned
GROUP BY merchant_category
ORDER BY total_amount DESC;

--bank performance --

SELECT
    sender_bank,
    COUNT(*) AS total_transactions,
    CASE
        WHEN COUNT(*) > 20000 THEN 'High Volume'
        WHEN COUNT(*) > 10000 THEN 'Medium Volume'
        ELSE 'Low Volume'
    END AS volume_category
FROM upi_transactions_cleaned
GROUP BY sender_bank
ORDER BY total_transactions DESC;



--age group spending--

SELECT
    sender_age_group,
    ROUND(AVG(amount_inr),2) AS average_amount,
    CASE
        WHEN AVG(amount_inr) >= 10000 THEN 'High Spending'
        ELSE 'Normal Spending'
    END AS spending_category
FROM upi_transactions_cleaned
GROUP BY sender_age_group
ORDER BY average_amount DESC;

--row_number() transaction ranking--

select  transaction_id,amount_inr,
row_number() over(order by amount_inr desc) as transaction_rank
from upi_transactions_cleaned

--rank() highest transaction--

select transaction_id,amount_inr,
rank()over(order by amount_inr desc) as amount_rank
from upi_transactions_cleaned


-- rank banks by trsansaction amount--

select
sender_bank,total_amount,rank() over(
order by total_amount desc) as bank_rank
from(
select sender_bank,sum(amount_inr) as total_amount
from upi_transactions_cleaned
group by sender_bank)as bank_summary





--total transaction amount--

WITH transaction_summary AS (
    SELECT
        COUNT(*) AS total_transactions,
        SUM(amount_inr) AS total_amount,
        AVG(amount_inr) AS average_amount
    FROM upi_transactions_cleaned
)
SELECT *
FROM transaction_summary;


--sates with above - average transaction amount--

WITH state_summary AS (
    SELECT
        sender_state,
        AVG(amount_inr) AS avg_amount
    FROM upi_transactions_cleaned
    GROUP BY sender_state
)

SELECT
    sender_state,
    ROUND(avg_amount, 2) AS avg_amount
FROM state_summary
WHERE avg_amount > (
    SELECT AVG(amount_inr)
    FROM upi_transactions_cleaned
)
ORDER BY avg_amount DESC;




--bank performance--

WITH bank_summary AS (
    SELECT
        sender_bank,
        COUNT(*) AS total_transactions,
        SUM(amount_inr) AS total_amount,
        AVG(amount_inr) AS average_amount
    FROM upi_transactions_cleaned
    GROUP BY sender_bank
)

SELECT
    sender_bank,
    total_transactions,
    ROUND(total_amount, 2) AS total_amount,
    ROUND(average_amount, 2) AS average_amount
FROM bank_summary
ORDER BY total_amount DESC;




--bank performance view--

CREATE VIEW vw_bank_performance AS
SELECT
    sender_bank,
    COUNT(*) AS total_transactions,
    SUM(amount_inr) AS total_amount,
    ROUND(AVG(amount_inr), 2) AS average_amount,
    SUM(CASE
        WHEN transaction_status = 'Success' THEN 1
        ELSE 0
    END) AS successful_transactions
FROM upi_transactions_cleaned
GROUP BY sender_bank;


SELECT *
FROM vw_bank_performance;

--fraud analysis view--


CREATE VIEW vw_fraud_analysis AS
SELECT
    sender_bank,
    COUNT(*) AS total_transactions,
    SUM(CASE
        WHEN fraud_flag = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions,
    ROUND(
        SUM(CASE
            WHEN fraud_flag = 1 THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS fraud_rate
FROM upi_transactions_cleaned
GROUP BY sender_bank;

select * from vw_fraud_analysis

--state performance view--

CREATE VIEW vw_state_performance AS
SELECT
    sender_state,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_inr), 2) AS total_amount,
    ROUND(AVG(amount_inr), 2) AS average_amount
FROM upi_transactions_cleaned
GROUP BY sender_state;

select * from vw_state_performance



--Monthly Transaction Growth--


WITH monthly_data AS (
    SELECT
        FORMAT([timestamp], 'yyyy-MM') AS month,
        SUM(amount_inr) AS total_amount
    FROM upi_transactions_cleaned
    GROUP BY FORMAT([timestamp], 'yyyy-MM')
),

growth_data AS (
    SELECT
        month,
        total_amount,
        LAG(total_amount) OVER (
            ORDER BY month
        ) AS previous_month_amount
    FROM monthly_data
)

SELECT
    month,
    ROUND(total_amount, 2) AS total_amount,
    ROUND(previous_month_amount, 2) AS previous_month_amount,
    ROUND(
        (total_amount - previous_month_amount)
        * 100.0 / NULLIF(previous_month_amount, 0),
        2
    ) AS growth_percentage
FROM growth_data
ORDER BY month;


--Top Merchant Categories by Transaction Value--

SELECT
    merchant_category,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_inr), 2) AS total_transaction_value,
    ROUND(AVG(amount_inr), 2) AS average_transaction_value
FROM upi_transactions_cleaned
GROUP BY merchant_category
ORDER BY total_transaction_value DESC;


--Bank Performance: Volume + Success Rate--


SELECT
    sender_bank,
    COUNT(*) AS total_transactions,

    ROUND(SUM(amount_inr), 2) AS total_transaction_value,

    ROUND(AVG(amount_inr), 2) AS average_transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_status = 'Success' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS success_rate

FROM upi_transactions_cleaned

GROUP BY sender_bank

ORDER BY success_rate DESC;




--Fraud Analysis by Bank--


SELECT
    sender_bank,
    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN fraud_flag = 1 THEN 1
            ELSE 0
        END
    ) AS fraud_transactions,

    ROUND(
        SUM(
            CASE
                WHEN fraud_flag = 1 THEN amount_inr
                ELSE 0
            END
        ), 2
    ) AS fraud_transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN fraud_flag = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS fraud_rate

FROM upi_transactions_cleaned

GROUP BY sender_bank

ORDER BY fraud_rate DESC;



--State-wise UPI Performance--


SELECT
    sender_state,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount_inr), 2) AS total_transaction_value,
    ROUND(AVG(amount_inr), 2) AS average_transaction_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_status = 'Success' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS success_rate

FROM upi_transactions_cleaned

GROUP BY sender_state

ORDER BY total_transaction_value DESC;


