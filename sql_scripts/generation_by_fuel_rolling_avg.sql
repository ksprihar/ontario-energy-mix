-- Calculates the 12-month rolling average of generation output (GWh) for each fuel type.
--
-- PARTITION BY fuel means the rolling window resets independently for each fuel —
-- Gas's 12-month average is never mixed with Nuclear's, Hydro's, etc.
--
-- As with demand_rolling_avg.sql, the first 11 months per fuel are set to NULL rather
-- than filtered out, so the full date range is preserved for charting.

WITH rolling_averages AS (
    SELECT
        month,
        fuel,
        output_gwh,
        -- Window resets per fuel type due to PARTITION BY fuel
        AVG(output_gwh) OVER(PARTITION BY fuel ORDER BY month ASC ROWS BETWEEN 11 PRECEDING AND CURRENT ROW) AS raw_rolling_avg,
        ROW_NUMBER() OVER(PARTITION BY fuel ORDER BY month ASC) AS month_rank
    FROM generation
)
SELECT
    month,
    fuel,
    output_gwh,
    CASE
        WHEN month_rank >= 12 THEN raw_rolling_avg
        ELSE NULL         -- Incomplete window: fewer than 12 months of history for this fuel
    END AS rolling_avg_fuel_12m
FROM rolling_averages
ORDER BY month ASC, fuel ASC
;