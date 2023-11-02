-- Question 2 - How many liters of milk and kilograms of bread can be bought for the first and last recorded period of available prices and wages
    --Listing purchasable amount of each produce category for corresponding year (using inner join to ensure corresponding years) (including first_year, last_year for filtering)
    CREATE OR REPLACE TABLE engeto.q2_answer_bread_milk_first_last_year(
    SELECT 
        category,
        ROUND(AVG(wage), 3),
        price_per_unit,
        ROUND(AVG(wage), 3)/price_per_unit AS Purchasable_amount,
        unit,
        payroll_year,
        price_year,
        first_year,
        last_year
    FROM engeto.wage_per_branch_year
    JOIN engeto.price_per_category_year ppcy ON payroll_year = ppcy.price_year
    WHERE (category LIKE '%chléb%' OR category LIKE '%mléko%') AND (first_year=1 OR last_year=1)
    GROUP BY
        category,
        payroll_year
    ORDER BY
        payroll_year
    )
    ;
-- Answer 2 - In the first period, 1287kg of bread or 1437l of milk can be bought. In the last period, 1342kf of bread or 1641l of milk can be bought.
