-- Calculates each fuel type's share of total annual generation (%) for every year
-- in the dataset. Used to track how Ontario's generation mix has shifted over time.

WITH yearly_data AS (
    SELECT
        YEAR(month) AS year,
        fuel,
        SUM(output_gwh) AS fuel_output,
        -- SUM(SUM(...)) OVER(PARTITION BY year) is a window-of-aggregate pattern:
        -- the inner SUM aggregates rows into per-fuel annual totals (via GROUP BY),
        -- then the outer SUM window adds those totals back up across all fuels within
        -- the same year — giving the yearly total without a separate subquery
        SUM(SUM(output_gwh)) OVER(PARTITION BY YEAR(month)) AS yearly_output
    FROM generation
    GROUP BY YEAR(month), fuel
)
SELECT
    year,
    fuel,
    fuel_output,
    yearly_output,
    ROUND(fuel_output * 100.0 / yearly_output, 2) AS percentage_of_total_generation
FROM yearly_data
ORDER BY
    year,
    -- Custom sort keeps fuels in a consistent narrative order (Gas first as the
    -- focus of the analysis) rather than defaulting to alphabetical
    CASE
        WHEN fuel = 'GAS' THEN 1
        WHEN fuel = 'NUCLEAR' THEN 2
        WHEN fuel = 'HYDRO' THEN 3
        WHEN fuel = 'WIND' THEN 4
        WHEN fuel = 'BIOFUEL' THEN 5
        WHEN fuel = 'SOLAR' THEN 6
        ELSE 0
    END ASC
;
