-- A broader version of the top-10 analysis: splits all months at the median peak demand
-- into 'Top Months' (50th–100th percentile) and 'Bottom Months' (0–50th percentile),
-- then compares Gas's generation share between the two halves.
-- This provides a more robust signal than the top-10 cut alone.
--
-- Three CTEs mirror the structure of top_10_months_data.sql:
--   month_ranks     : scores every month with PERCENT_RANK by peak demand
--   month_categories: labels months as 'Top Months' or 'Bottom Months'
--   generation_total: aggregates generation by month_category × fuel_category

WITH month_ranks AS (
    -- ORDER BY ASC means PERCENT_RANK returns 0 for the lowest peak demand
    -- and ~1 for the highest, so percentile >= 0.5 correctly captures the top half
    SELECT
        month,
        PERCENT_RANK() OVER(ORDER BY peak_demand_gw ASC) AS percentile
    FROM demand_matching_generation_range
),
month_categories AS (
    -- Months at or above the median peak demand → 'Top Months'
    SELECT
        month,
        CASE
            WHEN percentile >= 0.5 THEN 'Top Months'
            ELSE 'Bottom Months'
        END AS month_category
    FROM month_ranks
),
generation_total AS (
    -- Same window-of-aggregate pattern as top_10_months_data.sql:
    -- SUM(SUM(...)) OVER(PARTITION BY month_category) gives the category grand total
    SELECT
        mc.month_category,
        CASE
            WHEN g.fuel = 'GAS' THEN 'Gas'
            ELSE 'Others'
        END AS fuel_category,
        SUM(g.output_gwh) AS fuel_category_output,
        SUM(SUM(g.output_gwh)) OVER(PARTITION BY mc.month_category) AS month_category_total
    FROM generation g
    JOIN month_categories mc
        ON g.month = mc.month
    GROUP BY
        mc.month_category,
        CASE
            WHEN g.fuel = 'GAS' THEN 'Gas'
            ELSE 'Others'
        END
)
SELECT
    *,
    ROUND(fuel_category_output * 100.0 / month_category_total, 2) AS percentage_of_total_generation
FROM generation_total
ORDER BY month_category DESC, fuel_category ASC
;