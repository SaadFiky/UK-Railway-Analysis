-- Use the previously created database
USE UK_Railways;

-- Load data from Station.csv file into the Station table.
BULK INSERT Station
FROM "D:\DEPI Data Analysis\Projects\UK Train Rides\Data-csv\Station.csv"
WITH (
	FIELDTERMINATOR =',',	-- CSV field delimiter
	ROWTERMINATOR = '\n',	-- Row delimiter
	FIRSTROW = 2            -- Skip header row
	);

-- SELECT * FROM Station

-- Load data from Routes.csv file into the Routes table.
BULK INSERT Routes
FROM "D:\DEPI Data Analysis\Projects\UK Train Rides\Data-csv\Routes.csv"
WITH (
	FIELDTERMINATOR =',',	-- CSV field delimiter
	ROWTERMINATOR = '\n',	-- Row delimiter
	FIRSTROW = 2            -- Skip header row
	);

-- SELECT * FROM Routes

-- Load data from Journeys.csv file into the Journeys table.
BULK INSERT Journeys
FROM "D:\DEPI Data Analysis\Projects\UK Train Rides\Data-csv\Journeys.csv"
WITH (
	FIELDTERMINATOR =',',	-- CSV field delimiter
	ROWTERMINATOR = '\n',	-- Row delimiter
	FIRSTROW = 2            -- Skip header row
	);

-- SELECT * FROM Journeys

-- Load data from Transactions.csv file into the Transactions table.
BULK INSERT Transactions
FROM "D:\DEPI Data Analysis\Projects\UK Train Rides\Data-csv\Transactions.csv"
WITH (
	FIELDTERMINATOR =',',	-- CSV field delimiter
	ROWTERMINATOR = '\n',	-- Row delimiter
	FIRSTROW = 2            -- Skip header row
	);

-- SELECT * FROM Transactions

-- Load data from Calendar.csv file into the Calendar table.
BULK INSERT Calendar
FROM "D:\DEPI Data Analysis\Projects\UK Train Rides\Data-csv\Calendar.csv"
WITH (
	FIELDTERMINATOR =',',	-- CSV field delimiter
	ROWTERMINATOR = '\n',	-- Row delimiter
	FIRSTROW = 2            -- Skip header row
	);

-- SELECT * FROM Calendar
