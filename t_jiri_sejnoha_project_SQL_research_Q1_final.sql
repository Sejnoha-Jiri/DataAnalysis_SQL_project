-- Question 1 - Have wages grown in all industry branches over the years, or do some of them decrease?
    -- Assigning uniform value to the wages differential calcutation
    CREATE OR REPLACE TEMPORARY TABLE engeto.q1_decrease_value_unification(
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
