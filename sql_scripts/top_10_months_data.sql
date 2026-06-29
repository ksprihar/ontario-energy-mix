-- Compares Gas's share of total generation between the top 10 highest peak-demand months
-- and all other months, to test whether Gas usage is disproportionately higher when
-- demand peaks. Fuels are collapsed into two categories: Gas vs. everything else.
--
-- Three CTEs:
--   month_ranks     : ranks every month by peak demand (DESC)
--   peak_months     : labels each month as 'Top 10 Months' or 'Other Months'
--   generation_total: aggregates generation by month_category × fuel_category,
--                     and computes the within-category total using a window-of-aggregate

WITH month_ranks AS (
    -- DENSE_RANK so tied peak-demand months are both counted (same rationale as top_10_months.sql)
    SELECT
        month,
        DENSE_RANK() OVER(ORDER BY peak_demand_gw DESC) AS rnk
    FROM demand_matching_generation_range
),
peak_months AS (
    -- Assign each month to a category based on its rank
    SELECT
        month,
        CASE
            WHEN rnk <= 10 THEN 'Top 10 Months'
            ELSE 'Other Months'
        END AS month_category
    FROM month_ranks
),
generation_total AS (
    -- Collapse all non-Gas fuels into 'Others', then sum generation per category.
    -- SUM(SUM(...)) OVER(PARTITION BY month_category) is a window-of-aggregate:
    -- the inner SUM produces per-group row totals (via GROUP BY), the outer SUM
    -- window adds them up within each month_category to get the category grand total
    SELECT
        pm.month_category,
        CASE
            WHEN g.fuel = 'GAS' THEN 'Gas'
            ELSE 'Others'
        END AS fuel_category,
        SUM(g.output_gwh) AS fuel_category_output,
        SUM(SUM(g.output_gwh)) OVER(PARTITION BY pm.month_category) AS month_category_total
    FROM generation g
    JOIN peak_months pm
        ON g.month = pm.month
    GROUP BY
        pm.month_category,
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