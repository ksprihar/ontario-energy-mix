USE master;
GO

DROP DATABASE IF EXISTS ontario_energy;
GO

CREATE DATABASE ontario_energy;
GO

USE ontario_energy;
GO

-- Creating the Demand Table
DROP TABLE IF EXISTS demand;
GO

CREATE TABLE demand
(
    month DATE PRIMARY KEY,
    total_demand_gwh FLOAT NOT NULL,
    peak_demand_gw FLOAT NOT NULL
);
GO

-- Populating demand table with data from CSV file demand_data.csv
BULK INSERT demand
FROM '/csv_data/demand_data.csv' -- The file path for the demand CSV file
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FORMAT = 'CSV',
    TABLOCK
);
GO

-- Creating Generation Table
DROP TABLE IF EXISTS generation;
GO

CREATE TABLE generation
(
    month DATE NOT NULL,
    fuel VARCHAR(50) NOT NULL,
    output_gwh FLOAT NOT NULL,
    CONSTRAINT pk_generation PRIMARY KEY (month, fuel)
);
GO

-- Populating generation table with data from CSV file generation_data.csv
BULK INSERT generation
FROM '/csv_data/generation_data.csv'  -- The file path for the generation CSV file
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FORMAT = 'CSV',
    TABLOCK
);
GO