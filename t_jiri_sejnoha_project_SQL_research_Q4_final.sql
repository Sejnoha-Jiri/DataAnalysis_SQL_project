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
    CREATE OR REPLACE TABLE engeto.q4_overall_wage_increase_per_year (
    SELECT
        payroll_year,
        ROUND(AVG(wage_increase), 3) AS overall_wage_increase
    FROM engeto.wage_per_branch_year
    WHERE payroll_year > 2006
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