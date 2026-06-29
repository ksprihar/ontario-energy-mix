-- Generation data in the IESO database lags and does not match with Demand data
-- The latest month in the Demand data is the ongoing month and should be removed from the analysis as it is not complete

-- Creating a demand view for standalone analysis of demand data which only contains completed months of demand data
DROP VIEW IF EXISTS demand_complete_months;
GO

CREATE VIEW demand_complete_months
AS
    SELECT *
    FROM demand
    WHERE month < (SELECT MAX(month) FROM demand)
;
GO

-- Creating a demand view for analysis of demand data along with generation data which only contains months of demand data that are also present in the generation table
DROP VIEW IF EXISTS demand_matching_generation_range;
GO

CREATE VIEW demand_matching_generation_range
AS
    SELECT *
    FROM demand
    WHERE month <= (SELECT MAX(month) FROM generation)
;
GO
