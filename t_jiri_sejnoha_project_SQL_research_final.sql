-- Question 1 - Have wages grown in all industry branches over the years, or do some of them decrease?
    -- Assigning uniform value to the wages differential calcutation
    CREATE OR REPLACE TABLE engeto.q1_decrease_value_unification(
    SELECT
        industry_branch,
        payroll_year,
        wage,
        wage_increase,
    CASE
        WHEN wage_increase < 0 THEN 1
        ELSE 0
    END AS increase_or_decrease
    FROM engeto.wage_per_branch_year
    )

    -- Listing all branches, counting in how many years the wage decreaseped and listing mentioned years
    CREATE OR REPLACE TABLE engeto.q1_answer_decrease_count_per_branch(
    SELECT
        industry_branch,
        COUNT( CASE WHEN increase_or_decrease = 1 THEN increase_or_decrease END) AS decrease_count,
        GROUP_CONCAT( CASE WHEN increase_or_decrease = 1 THEN payroll_year END) AS years_when_decrease_occured
    FROM engeto.q1_decrease_value_unification
    GROUP BY
        industry_branch
    )
-- Answer 1 - The wage decreased in almost every industry in the recorded years, except "Transportation and Warehousing", "Other Activities", "Healthcare and Social Care" and "Manufacturing Industry".
-- Question 2 - How many liters of milk and kilograms of bread can be bought for the first and last recorded period of available prices and wages
    --Listing purchasable amount of each produce category per industry branch for corresponding year (using inner join to ensure corresponding years) (including first_year, last_year for filtering)
    CREATE OR REPLACE TABLE engeto.q2_purchasable_amount_per_branch_category_year(
    SELECT industry_branch,
        category,
        wage,
        price_per_unit,
        wage/price_per_unit AS Purchasable_amount,
        unit,
        payroll_year,
        price_year,
        first_year,
        last_year
    FROM engeto.wage_per_branch_year
    JOIN engeto.price_per_category_year ppcy ON payroll_year = ppcy.price_year
    GROUP BY
        industry_branch,
        payroll_year,
        category
    ORDER BY
        industry_branch,
        payroll_year
    )

    --Filtering out any records with categories containing milk or bread recorded AS first or last years
    CREATE OR REPLACE TABLE engeto.q2_answer_bread_milk_first_last_year(
    SELECT
        industry_branch,
        category,
        price_year,
	    Purchasable_amount,
        unit
    FROM engeto.q2_purchasable_amount_per_branch_category_year qpapbcy
    WHERE (category LIKE '%chléb%' OR category LIKE '%mléko%') AND (first_year=1 OR last_year=1)
    )
-- Answer 2 - Answer depends ON the industry branch (listed in engeto.q2_answer_average_bread_milk_first_last_year).
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
-- Question 4 - Has a year, where the price increase was at least 10% higher than wage increase, been recorded?
    -- Creating table for overall price increase per year
    CREATE OR REPLACE TABLE engeto.q4_overall_price_increase_per_year (
    SELECT
        price_year,
        AVG(price_increase) AS overall_price_increase
    FROM engeto.price_per_category_year
    GROUP BY
        price_year 
    )

    -- Creating table for overall wage increase per year
    CREATE OR REPLACE TEMPORARY TABLE engeto.q4_overall_wage_increase_per_year (
    SELECT
        payroll_year,
        ROUND(AVG(wage_increase), 3) AS overall_wage_increase
    FROM engeto.wage_per_branch_year
    GROUP BY
        payroll_year
    )

    -- Comparing the increases and ordering for readablity
    CREATE OR REPLACE TABLE engeto.q4_answer_price_wage_increase_comparison(
    SELECT
        overall_price_increase,
        overall_wage_increase,
        ABS(overall_price_increase - overall_wage_increase) as price_wage_absolute_difference,
        price_year,
        payroll_year
    FROM engeto.q4_overall_price_increase_per_year qopipy
    JOIN engeto.q4_overall_wage_increase_per_year qowipy ON qopipy.price_year = qowipy.payroll_year
    ORDER BY
        price_wage_absolute_difference DESC
    )

-- Answer 4 - There wasn't any year that had 10% difference between the increase of wages and prices, the highest difference occured in year 2009, the difference was 8.49%.
-- Question 5 - Does the GDP's value affect wage and food prices? If GDP rises significantly in one year, will it be reflected in food prices or wage in the same or subsequent year with a more significant increase?

    --joining relevant data from GDP to price and wage increase records
    CREATE OR REPLACE TEMPORARY TABLE engeto.q5_overall_relevant_data (
    SELECT
        `year`,
        COALESCE ((GDP / LAG(GDP,1) OVER (ORDER BY year)-1) * 100,0) AS GDP_increase,
        overall_price_increase,
        overall_wage_increase
    FROM engeto.t_jiri_sejnoha_project_SQL_secondary_final
    JOIN engeto.q4_answer_price_wage_increase_comparison qapwic ON `year` = qapwic.price_year
    )

    --Comparing the increases
    CREATE OR REPLACE TABLE engeto.q5_answer_increase_comparisons (
    SELECT
        `year`,
        GDP_increase - overall_price_increase AS same_year_GDP_price_comparison,
        GDP_increase - overall_wage_increase AS same_year_GDP_wage_comparison,
        COALESCE (GDP_increase - LAG(overall_price_increase,-1) OVER(ORDER BY `year`),0) AS subsequent_year_GDP_price_comparison,
        COALESCE (GDP_increase - LAG(overall_wage_increase,-1) OVER(ORDER BY `year`),0) AS subsequent_year_GDP_wage_comparison
    FROM engeto.q5_overall_relevant_data qord
    )
-- Answer 5 - Upon closer inspection, the values do not show any direct causal relationship.