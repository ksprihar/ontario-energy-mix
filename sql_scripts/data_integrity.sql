-- Checking for NULL values in the generation table
SELECT
    COUNT(*) AS generation_null_records
FROM generation
WHERE month IS NULL
   OR fuel IS NULL
   OR output_gwh IS NULL
;
GO

-- Checking for NULL values in the demand table
SELECT
    COUNT(*) AS demand_null_records
FROM demand
WHERE month IS NULL
   OR total_demand_gwh IS NULL
   OR peak_demand_gw IS NULL
;
GO

-- Checking for duplicate records in the generation table
WITH generation_duplicates AS (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY month, fuel, output_gwh ORDER BY month) AS rn
    FROM generation
)
SELECT
    COUNT(*) AS duplicate_generation_records
FROM generation_duplicates
WHERE rn > 1
;
GO

-- Checking for duplicate records in the demand table
WITH demand_duplicates AS (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY month, total_demand_gwh, peak_demand_gw ORDER BY month) AS rn
    FROM demand
)
SELECT
    COUNT(*) AS duplicate_demand_records
FROM demand_duplicates
WHERE rn > 1
;
GO

-- Checking for continuity of months in the generation table
WITH month_sequence AS (
    SELECT
        month,
        LAG(month) OVER (ORDER BY month) AS prev_month
    FROM generation
    GROUP BY month
)
SELECT
    SUM(
        CASE
            WHEN prev_month IS NOT NULL THEN DATEDIFF(MONTH, prev_month, month) - 1
            ELSE 0
        END
    ) AS number_of_missing_generation_months
FROM month_sequence
;
GO

-- Checking for continuity of months in the demand table
WITH month_sequence AS (
    SELECT
        month,
        LAG(month) OVER(ORDER BY month ASC) AS prev_month
    FROM demand
)
SELECT
    SUM(
        CASE
            WHEN prev_month IS NOT NULL THEN DATEDIFF(MONTH, prev_month, month) - 1
            ELSE 0
        END
    ) AS number_of_missing_demand_months
FROM month_sequence
;
GO

-- Checking consistency of fuel types in the generation table
SELECT DISTINCT fuel AS distinct_fuel_types
FROM generation
ORDER BY fuel
;
GO

-- Checking for months in demand that are not in generation
SELECT month AS month_in_demand_not_in_generation
FROM demand
EXCEPT
SELECT month
FROM generation
;
GO

-- Checking for months in generation that are not in demand
SELECT month AS month_in_generation_not_in_demand
FROM generation
EXCEPT
SELECT month
FROM demand
;
GO
