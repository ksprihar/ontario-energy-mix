-- Calculates the 12-month rolling average of total demand (GWh) from the
-- demand_complete_months view (which excludes the current incomplete month).
--
-- The first 11 months cannot form a complete 12-month window, so rolling_avg_demand_12m
-- is set to NULL for those rows rather than being filtered out — this preserves a
-- continuous date range for charting while being honest about the partial windows.

WITH rolling_averages AS (
    SELECT
        month,
        total_demand_gwh,
        AVG(total_demand_gwh) OVER(ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS raw_rolling_avg,
        ROW_NUMBER() OVER(ORDER BY month ASC) AS month_rank
    FROM demand_complete_months
)
SELECT
    month,
    total_demand_gwh,
    CASE
        WHEN month_rank >= 12 THEN raw_rolling_avg
        ELSE NULL         -- Incomplete window: fewer than 12 months of history available
    END AS rolling_avg_demand_12m
FROM rolling_averages
ORDER BY month ASC
;