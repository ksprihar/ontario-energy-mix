-- This SQL script identifies the top 10 months with the highest peak demand in Ontario.
-- Used as a building block by top_10_months_data.sql to compare Gas's share in high-demand
-- months vs. the rest.

WITH month_ranks AS (
    SELECT
        month,
        -- DENSE_RANK rather than RANK so tied peak-demand months are both included
        -- (e.g. two months with identical peak_demand_gw both receive rank 10)
        DENSE_RANK() OVER(ORDER BY peak_demand_gw DESC) AS rnk
    FROM demand_matching_generation_range
)
SELECT
    month as top_months
FROM month_ranks
WHERE rnk <= 10
ORDER BY rnk ASC
;