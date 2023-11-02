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