WITH customer_spending AS (
    
	SELECT
        customer_id,
        COUNT(*) AS transaction_count,
        SUM(transaction_amount) AS total_spent,
        ROUND(AVG(transaction_amount), 2) AS avg_transaction_value
    
	FROM bank_transactions
    GROUP BY customer_id
),

spending_tiers AS (
    
	SELECT
        customer_id,
        total_spent,
        transaction_count,
        avg_transaction_value,
        
	CASE
         WHEN total_spent < 1000 THEN '1. Low (Under £1k)'
         WHEN total_spent < 10000 THEN '2. Medium (£1k - £10k)'
         WHEN total_spent < 100000 THEN '3. High (£10k - £100k)'
         ELSE '4. Premium (Over £100k)'
	
	END AS customer_tier
	FROM customer_spending
)

SELECT
    customer_tier,
    COUNT(*) AS customer_count,
    
	CONCAT(ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2), '%') AS percent_of_customers,
    ROUND(AVG(avg_transaction_value), 2) AS avg_transaction_size,
    ROUND(SUM(total_spent), 0) AS total_tier_value,
    CONCAT(ROUND(100.0 * SUM(total_spent) / SUM(SUM(total_spent)) OVER (), 2), '%') AS percent_of_total_value

FROM spending_tiers
GROUP BY customer_tier
ORDER BY customer_tier;
