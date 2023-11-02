-- Decoding original tables for readability and clarity
    --Payroll data
        CREATE OR REPLACE TEMPORARY TABLE engeto.czechia_payroll_decoded (
        SELECT
            id,
            value,
            cpvt.name AS value_type,
            cpu.name AS unit,
            cpc.name AS calculation,
            cpib.name AS industry_branch,
            cp.payroll_year,
            cp.payroll_quarter
        FROM engeto.czechia_payroll cp
        JOIN engeto.czechia_payroll_calculation cpc ON cpc.code = cp.calculation_code
        JOIN engeto.czechia_payroll_industry_branch cpib ON cpib.code = cp.industry_branch_code
        JOIN engeto.czechia_payroll_unit cpu ON cpu.code = cp.unit_code 
        JOIN engeto.czechia_payroll_value_type cpvt ON cpvt.code = cp.value_type_code
        )
        ;
    --Price data
        CREATE OR REPLACE TEMPORARY TABLE engeto.czechia_price_decoded (
        SELECT
            id,
            value,
            cpc.name AS category,
            cpc.price_value AS quantity,
            cpc.price_unit AS unit,
            cp.date_from, 
            cp.date_to,
            cr.name AS region
        FROM engeto.czechia_price cp
        JOIN engeto.czechia_price_category cpc ON cpc.code = cp.category_code
        JOIN engeto.czechia_region cr ON cr.code = cp.region_code 
        )
        ;
--Adjusting decoded tables for more specificity
    --Wages
        -- Creating value for difference between wages per industry branch per year
            CREATE OR REPLACE TEMPORARY TABLE engeto.mid_result_wage_per_branch_year (
            SELECT
                industry_branch,
                AVG(value) AS wage,
                payroll_year
            FROM engeto.czechia_payroll_decoded
            WHERE engeto.czechia_payroll_decoded.value_type = 'Průměrná hrubá mzda na zaměstnance' AND value IS NOT NULL
            GROUP BY
                industry_branch,
                payroll_year 
            ORDER BY
                industry_branch,
                payroll_year
            )
            ;
            -- Listing wages per industry branch per year
            CREATE OR REPLACE TEMPORARY TABLE engeto.wage_per_branch_year (
            SELECT
                industry_branch,
                wage,
                payroll_year,
                ROUND(COALESCE(((wage / NULLIF(LAG(wage, 1) OVER (PARTITION BY industry_branch ORDER BY payroll_year), 0)) - 1) * 100,0),3) AS wage_increase
            FROM engeto.mid_result_wage_per_branch_year
            )
            ;
    --Prices
        -- Listing numbers of rows to determine first and last recorded years
            CREATE OR REPLACE TEMPORARY TABLE engeto.mid_result_price_per_category_year(
            SELECT
                category,
                AVG(value/quantity) AS price_per_unit,
                unit,
                YEAR(date_from) AS price_year,
                row_number() OVER (PARTITION BY category ORDER BY price_year) AS first_year,
                row_number() OVER (PARTITION BY category ORDER BY price_year DESC) AS last_year
            FROM engeto.czechia_price_decoded cpd
            GROUP BY
                category,
                price_year
            )
            ;
        -- Listing prices per unit per category per year
            CREATE OR REPLACE TEMPORARY TABLE engeto.price_per_category_year(
            SELECT
                category,
                price_per_unit,
                unit,
                price_year,
                first_year,
                last_year,
                ROUND(COALESCE(((price_per_unit / NULLIF(LAG(price_per_unit, 1) OVER (PARTITION BY category ORDER BY price_year), 0)) - 1) * 100,0),3) AS price_increase
            FROM engeto.mid_result_price_per_category_year
            )
            ;
-- Uniting for final table, it will be possible to extract all data from this table, but I choose to work with them separately as it will be more readable in my opinion.
    CREATE OR REPLACE TABLE engeto.t_jiri_sejnoha_project_SQL_primary_final AS
    SELECT
        industry_branch,
        wage,
        payroll_year,
        wage_increase,
        NULL AS category,
        NULL AS price_per_unit,
        NULL AS unit,
        NULL AS price_year,
        NULL AS first_year,
        NULL AS last_year,
        NULL AS price_increase
    FROM engeto.wage_per_branch_year
    UNION ALL
    SELECT
        NULL AS industry_branch,
        NULL AS wage,
        NULL AS payroll_year,
        NULL AS wage_increase,
        category,
        price_per_unit,
        unit,
        price_year,
        first_year,
        last_year,
        price_increase
    FROM engeto.price_per_category_year;
    ;
-- Isolating relevant data from GDP
    CREATE OR REPLACE TABLE engeto.t_jiri_sejnoha_project_SQL_secondary_final (
    SELECT *
    FROM engeto.economies
    WHERE country LIKE '%Czech Republic%' AND `year` BETWEEN  2005 AND 2016
    )
    ;
