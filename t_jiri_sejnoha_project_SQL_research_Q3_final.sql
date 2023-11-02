-- Question 3 - Which produce category is experiencing the slowest price increase? (Which has the slowest percentage increase per year)
    --Averaging calculated value and ordering for readability of results
    CREATE OR REPLACE TABLE engeto.q3_answer_average_price_per_category_per_year(
    SELECT
        category,
        unit,
	AVG(price_increase) AS average_price_increase
    FROM engeto.price_per_category_year
    GROUP BY
        category
    ORDER BY
        average_price_increase
    )


-- Answer 3 - The slowest increase has been recorded for granulated sugar at average 1.77% decrease.