--- Data Validation Checks ---

--- 1. Distinct value checks for key columns in the railway table ---

-- 1. Ticket Class
SELECT DISTINCT Ticket_Class FROM railway;

-- 2. Purchase Type
SELECT DISTINCT Purchase_Type FROM railway;

-- 3. Payment Method
SELECT DISTINCT Payment_Method FROM railway;

-- 4. Railcard
SELECT DISTINCT Railcard FROM railway;

-- 5. Ticket Type
SELECT DISTINCT Ticket_Type FROM railway;

-- 6. Journey Status
SELECT DISTINCT Journey_Status FROM railway;

-- 7. Reason for Delay
SELECT DISTINCT Reason_for_Delay FROM railway;

-- 8. Refund Request
SELECT DISTINCT Refund_Request FROM railway;


--- 2. To describe data types ---

Select COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH AS [Maximum Length], IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'Railway'


--- 3. To Check for duplicates in data ---

Select *, Count(*) AS Duplicate_Count
from railway
Group by Transaction_ID,
Date_of_Purchase,
Time_of_Purchase,	
Purchase_Type,	
Payment_Method,	
Railcard,	
Ticket_Class,	
Ticket_Type,	
Price,	
Departure_Station,	
Arrival_Destination,	
Date_of_Journey,	
Departure_Time,	
Arrival_Time,	
Actual_Arrival_Time,	
Journey_Status,	
Reason_for_Delay,	
Refund_Request,
Departure_Station_Code,
Arrival_Destination_Code
Having Count(*) > 1;


--- 4. To Check for columns has null values ---

DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql = @sql + 
    'SELECT ''' + COLUMN_NAME + ''' AS column_name, COUNT(*) AS null_count ' +
    'FROM railway WHERE [' + COLUMN_NAME + '] IS NULL UNION ALL '
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'railway';

SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Remove last UNION ALL  
EXEC sp_executesql @sql;


--- 5. Check for Dates Outlier ---

SELECT *
FROM railway
WHERE Date_of_Journey < '1900-01-01' -- Unreasonably old date
   OR Date_of_Journey > GETDATE();  -- Future dates (if not expected)

--Check in the following Columns:
--Date_of_Purchase,
--Date_of_Journey,	


--- 6. Check for Price Outlier ---

WITH Quartiles AS (
    SELECT 
        Price,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) OVER () AS Q3
    FROM railway
),
OutlierDetection AS (
    SELECT *,
        (Q3 - Q1) * 1.5 AS IQR,
        Q1 - (Q3 - Q1) * 1.5 AS lower_bound,
        Q3 + (Q3 - Q1) * 1.5 AS upper_bound
    FROM Quartiles
)
SELECT r.*
FROM railway r
Cross JOIN OutlierDetection o
WHERE r.Price < o.lower_bound OR r.Price > o.upper_bound;

--- Cleaning Steps ---

-- 1 --

/*  This SQL script updates the 'Reason_for_Delay' column in the 'Railway' table by converting each word to title case.  
   It ensures consistency by capitalizing the first letter of each word while keeping the rest in lowercase.  
*/


UPDATE railway
SET Reason_for_Delay = (  
    SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')  
    FROM STRING_SPLIT(Reason_for_Delay, ' ')  
);


-- 2 --

/*  This SQL script standardizes common delay reasons by grouping similar terms under a single consistent label.  
   It ensures that multiple variations of the same reason are merged into one for better data analysis.  
*/

UPDATE railway
SET Reason_for_Delay = 'Staff Shortage'
WHERE Reason_for_Delay IN ('Staffing', 'staff shortage');

UPDATE railway
SET Reason_for_Delay = 'Weather Conditions'
WHERE Reason_for_Delay IN ('Weather', 'weather condition');


-- 3 --

/* This SQL script ensures consistency in the 'Railcard' column by replacing 'None' with 'No Railcard'.  
  This standardizes data entries and eliminates inconsistencies in railcard classifications.
*/



UPDATE railway
SET Railcard = replace(Railcard,'None','No Railcard');


-- 4 --

/*  This SQL script ensures consistency in station names by replacing variations with a standardized name.  
   It prevents duplicate records caused by different naming conventions for the same station.  
*/


UPDATE Railway
SET Departure_Station = 'Edinburgh Waverley'
WHERE Departure_Station IN ('Edinburgh', 'edinburgh waverley');

UPDATE Railway
SET Arrival_Destination = 'Edinburgh Waverley'
WHERE Arrival_Destination IN ('Edinburgh', 'edinburgh waverley');


-- 6 --

/* This SQL script adds two new columns, 'Departure_Station_Code' and 'Arrival_Destination_Code',  
   to store station codes alongside station names. This enhances efficiency and consistency in route mapping.  
*/


ALTER TABLE Railway  
ADD Departure_Station_Code NVARCHAR(3),  
    Arrival_Destination_Code NVARCHAR(3);


-- 7 --

/*  This SQL script populates the newly added 'Departure_Station_Code' and 'Arrival_Destination_Code' columns  
   based on corresponding station names. It ensures that each station is correctly associated with its unique code.  
*/


UPDATE Railway SET Departure_Station_Code = 'BHM' WHERE Departure_Station = 'Birmingham New Street';
UPDATE Railway SET Departure_Station_Code = 'BRI' WHERE Departure_Station = 'Bristol Temple Meads';
UPDATE Railway SET Departure_Station_Code = 'CDF' WHERE Departure_Station = 'Cardiff Central';
UPDATE Railway SET Departure_Station_Code = 'COV' WHERE Departure_Station = 'Coventry';
UPDATE Railway SET Departure_Station_Code = 'CRE' WHERE Departure_Station = 'Crewe';
UPDATE Railway SET Departure_Station_Code = 'DID' WHERE Departure_Station = 'Didcot';
UPDATE Railway SET Departure_Station_Code = 'DON' WHERE Departure_Station = 'Doncaster';
UPDATE Railway SET Departure_Station_Code = 'DUR' WHERE Departure_Station = 'Durham';
UPDATE Railway SET Departure_Station_Code = 'EDB' WHERE Departure_Station = 'Edinburgh Waverley';
UPDATE Railway SET Departure_Station_Code = 'LDS' WHERE Departure_Station = 'Leeds';
UPDATE Railway SET Departure_Station_Code = 'LEI' WHERE Departure_Station = 'Leicester';
UPDATE Railway SET Departure_Station_Code = 'LIV' WHERE Departure_Station = 'Liverpool Lime Street';
UPDATE Railway SET Departure_Station_Code = 'EUS' WHERE Departure_Station = 'London Euston';
UPDATE Railway SET Departure_Station_Code = 'KGX' WHERE Departure_Station = 'London Kings Cross';
UPDATE Railway SET Departure_Station_Code = 'PAD' WHERE Departure_Station = 'London Paddington';
UPDATE Railway SET Departure_Station_Code = 'STP' WHERE Departure_Station = 'London St Pancras';
UPDATE Railway SET Departure_Station_Code = 'WAT' WHERE Departure_Station = 'London Waterloo';
UPDATE Railway SET Departure_Station_Code = 'MAN' WHERE Departure_Station = 'Manchester Piccadilly';
UPDATE Railway SET Departure_Station_Code = 'NOT' WHERE Departure_Station = 'Nottingham';
UPDATE Railway SET Departure_Station_Code = 'NUN' WHERE Departure_Station = 'Nuneaton';
UPDATE Railway SET Departure_Station_Code = 'OXF' WHERE Departure_Station = 'Oxford';
UPDATE Railway SET Departure_Station_Code = 'PBO' WHERE Departure_Station = 'Peterborough';
UPDATE Railway SET Departure_Station_Code = 'RDG' WHERE Departure_Station = 'Reading';
UPDATE Railway SET Departure_Station_Code = 'SHF' WHERE Departure_Station = 'Sheffield';
UPDATE Railway SET Departure_Station_Code = 'STA' WHERE Departure_Station = 'Stafford';
UPDATE Railway SET Departure_Station_Code = 'SWI' WHERE Departure_Station = 'Swindon';
UPDATE Railway SET Departure_Station_Code = 'TAM' WHERE Departure_Station = 'Tamworth';
UPDATE Railway SET Departure_Station_Code = 'WKF' WHERE Departure_Station = 'Wakefield';
UPDATE Railway SET Departure_Station_Code = 'WAC' WHERE Departure_Station = 'Warrington';
UPDATE Railway SET Departure_Station_Code = 'WVH' WHERE Departure_Station = 'Wolverhampton';
UPDATE Railway SET Departure_Station_Code = 'YRK' WHERE Departure_Station = 'York';

UPDATE Railway SET Arrival_Destination_Code = 'BHM' WHERE Arrival_Destination = 'Birmingham New Street';
UPDATE Railway SET Arrival_Destination_Code = 'BRI' WHERE Arrival_Destination = 'Bristol Temple Meads';
UPDATE Railway SET Arrival_Destination_Code = 'CDF' WHERE Arrival_Destination = 'Cardiff Central';
UPDATE Railway SET Arrival_Destination_Code = 'COV' WHERE Arrival_Destination = 'Coventry';
UPDATE Railway SET Arrival_Destination_Code = 'CRE' WHERE Arrival_Destination = 'Crewe';
UPDATE Railway SET Arrival_Destination_Code = 'DID' WHERE Arrival_Destination = 'Didcot';
UPDATE Railway SET Arrival_Destination_Code = 'DON' WHERE Arrival_Destination = 'Doncaster';
UPDATE Railway SET Arrival_Destination_Code = 'DUR' WHERE Arrival_Destination = 'Durham';
UPDATE Railway SET Arrival_Destination_Code = 'EDB' WHERE Arrival_Destination = 'Edinburgh Waverley';
UPDATE Railway SET Arrival_Destination_Code = 'LDS' WHERE Arrival_Destination = 'Leeds';
UPDATE Railway SET Arrival_Destination_Code = 'LEI' WHERE Arrival_Destination = 'Leicester';
UPDATE Railway SET Arrival_Destination_Code = 'LIV' WHERE Arrival_Destination = 'Liverpool Lime Street';
UPDATE Railway SET Arrival_Destination_Code = 'EUS' WHERE Arrival_Destination = 'London Euston';
UPDATE Railway SET Arrival_Destination_Code = 'KGX' WHERE Arrival_Destination = 'London Kings Cross';
UPDATE Railway SET Arrival_Destination_Code = 'PAD' WHERE Arrival_Destination = 'London Paddington';
UPDATE Railway SET Arrival_Destination_Code = 'STP' WHERE Arrival_Destination = 'London St Pancras';
UPDATE Railway SET Arrival_Destination_Code = 'WAT' WHERE Arrival_Destination = 'London Waterloo';
UPDATE Railway SET Arrival_Destination_Code = 'MAN' WHERE Arrival_Destination = 'Manchester Piccadilly';
UPDATE Railway SET Arrival_Destination_Code = 'NOT' WHERE Arrival_Destination = 'Nottingham';
UPDATE Railway SET Arrival_Destination_Code = 'NUN' WHERE Arrival_Destination = 'Nuneaton';
UPDATE Railway SET Arrival_Destination_Code = 'OXF' WHERE Arrival_Destination = 'Oxford';
UPDATE Railway SET Arrival_Destination_Code = 'PBO' WHERE Arrival_Destination = 'Peterborough';
UPDATE Railway SET Arrival_Destination_Code = 'RDG' WHERE Arrival_Destination = 'Reading';
UPDATE Railway SET Arrival_Destination_Code = 'SHF' WHERE Arrival_Destination = 'Sheffield';
UPDATE Railway SET Arrival_Destination_Code = 'STA' WHERE Arrival_Destination = 'Stafford';
UPDATE Railway SET Arrival_Destination_Code = 'SWI' WHERE Arrival_Destination = 'Swindon';
UPDATE Railway SET Arrival_Destination_Code = 'TAM' WHERE Arrival_Destination = 'Tamworth';
UPDATE Railway SET Arrival_Destination_Code = 'WKF' WHERE Arrival_Destination = 'Wakefield';
UPDATE Railway SET Arrival_Destination_Code = 'WAC' WHERE Arrival_Destination = 'Warrington';
UPDATE Railway SET Arrival_Destination_Code = 'WVH' WHERE Arrival_Destination = 'Wolverhampton';
UPDATE Railway SET Arrival_Destination_Code = 'YRK' WHERE Arrival_Destination = 'York';

--- Modeling Steps ---

--- Create the Database ---

Create Database UK_Railway


---1---

/* This SQL script creates the 'Station' table to store unique railway station information.
It includes a 'Station_Code' column as the primary key to ensure uniqueness and a 'Station_Name' column to store station names. */


use UK_Railway

create table Station (

Station_Code nvarchar(3) not null,
Station_Name nvarchar(50) not null,


Constraint PK_Station_Code primary key (Station_Code));


---2---

/* This SQL script creates the 'Routes' table to store unique railway routes.
Each route is identified by a 'Route_Code' as the primary key, which is a combination of departure and arrival station codes.
Foreign key constraints ensure that both 'Departure_Station_Code' and 'Arrival_Destination_Code' reference valid station codes in the 'Station' table. */


use UK_Railway

create table Routes (

Route_Code nvarchar(7) not null,
Departure_Station_Code nvarchar(3) not null,
Arrival_Destination_Code nvarchar(3) not null,


Constraint PK_Route_Code primary key (Route_Code),
Constraint FK_Arrival_Destination_Code Foreign key (Arrival_Destination_Code) references Station (Station_Code),
Constraint FK_Departure_Station_Code Foreign key (Departure_Station_Code) references Station (Station_Code));

---3---

/* This SQL script creates the 'Calendar' table to store date-related information.
The primary key is the 'Date' column, ensuring each date is unique.
Additional columns provide details such as the month, day of the week, quarter, and week number.
It also includes 'Day_Type' to differentiate between weekdays and weekends, and 'Holiday_Name' to store holiday information if applicable. */


use UK_Railway

CREATE TABLE Calendar (

Date DATE NOT NULL,
Year INT,
Quarter INT NOT NULL,
Month INT NOT NULL,
Month_Name NVARCHAR(10) NOT NULL,
Week INT NOT NULL,
Day_Of_Week NVARCHAR(3) NOT NULL,
Day_Type NVARCHAR(10) NOT NULL,
Holiday_Name NVARCHAR(25) NULL,


Constraint PK_Date primary key (Date));


---4---

/* This SQL script creates the 'Journeys' table to store details of train journeys.
Each journey is uniquely identified by 'Journey_ID' as the primary key.
The 'Route_Code' column links to the 'Routes' table, and 'Date_of_Journey' references the 'Calendar' table to ensure valid dates.
It records scheduled and actual arrival times, journey status, and delay details, allowing for tracking and analysis of train performance. */


use UK_Railway

create table Journeys (

Journey_ID nvarchar(50) not null,
Route_Code nvarchar(7) not null,
Date_of_Journey Date not null,
Departure_Time Time(0) not null,
Arrival_Time Time(0) not null,
Actual_Arrival_Time Time(0) null,
Journey_Status nvarchar(50) not null,
Reason_for_Delay nvarchar(50) null,


Constraint PK_Journey_ID primary key (Journey_ID),
Constraint FK_Route_Code Foreign key (Route_Code) references Routes (Route_Code),
Constraint FK_Date_of_Journey Foreign key (Date_of_Journey) references Calendar (Date));	


---5---

/* This SQL script creates the 'Transactions' table to store ticket purchase details.
Each transaction is uniquely identified by 'Transaction_ID' as the primary key.
The 'Journey_ID' column links to the 'Journeys' table, and 'Date_of_Purchase' references the 'Calendar' table for tracking purchase dates.
Constraints ensure valid values for purchase type, payment method, railcard type, ticket class, and ticket type.
Additionally, a 'Refund_Request' column stores whether a refund was requested, using a BIT data type for binary values (0 or 1). */


use UK_Railway

create table Transactions (

Transaction_ID nvarchar(25) not null,
Journey_ID nvarchar(50) not null,
Date_of_Purchase Date not null,
Time_of_Purchase Time(0) not null,
Purchase_Type nvarchar(11) not null,
Payment_Method nvarchar(11) not null,
Railcard nvarchar(11) not null,
Ticket_Class nvarchar(11) not null,
Ticket_Type nvarchar(11) not null,
Price INT not null,
Refund_Request nvarchar(3) not null,

Constraint PK_Transaction_Code primary key(Transaction_ID),
Constraint FK_Journey_ID Foreign key (Journey_ID) references journeys (Journey_ID),
Constraint FK_Date_of_Purchase Foreign key (Date_of_Purchase) references Calendar (Date),
constraint check_Purchase_Type check (Purchase_Type = 'Station' OR Purchase_Type = 'Online'),
constraint check_Payment_Method check (Payment_Method = 'Credit Card' OR Payment_Method = 'Contactless' OR Payment_Method = 'Debit Card'),
constraint check_Railcard check (Railcard = 'No Railcard' OR Railcard = 'Adult' OR Railcard = 'Disabled' OR Railcard = 'Senior'),
constraint check_Ticket_Class check (Ticket_Class = 'Standard' OR Ticket_Class = 'First Class'),
constraint check_Ticket_Type check (Ticket_Type = 'Advance' OR Ticket_Type = 'Anytime' OR Ticket_Type = 'Off-Peak'));


---6---

/* This SQL script generates a date dimension table with key attributes 
such as month, day of the week, quarter, and year. 
It categorizes dates as workdays, weekends, or holidays and assigns holiday names to specific dates. */


DECLARE @StartDate DATE = '2023-12-01';
DECLARE @EndDate DATE = '2024-5-31';

WITH DateSeries AS (
    SELECT @StartDate AS Date
    UNION ALL
    SELECT DATEADD(DAY, 1, Date) FROM DateSeries WHERE Date < @EndDate
)
INSERT INTO Calendar (Date,Year, Quarter, Month, Month_Name,
					  Week, Day_Of_Week, Day_Type, Holiday_Name)
SELECT 
    Date,
	YEAR(Date) AS Year,
	DATEPART(QUARTER, Date) AS Quarter,
    MONTH(Date) AS Month,
    LEFT(DATENAME(MONTH, Date),3) AS Month_Name,
	DATEPART(WEEK, Date) AS Week,
    LEFT(DATENAME(WEEKDAY, Date), 3) AS Day_Of_Week,
    CASE 
        WHEN Date IN ('2024-01-01', '2024-03-29', '2024-04-01', '2024-05-06', '2024-05-27', '2023-12-25', '2023-12-26') THEN 'Holiday' 
		WHEN DATENAME(WEEKDAY, Date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Workday'
    END AS Day_Type,
    CASE 
        WHEN Date = '2024-01-01' THEN 'New Year’s Day'
        WHEN Date = '2024-03-29' THEN 'Good Friday'
        WHEN Date = '2024-04-01' THEN 'Easter Monday'
		WHEN DATE = '2024-05-06' THEN 'Early May bank holiday'
		WHEN DATE = '2024-05-27' THEN 'Spring bank holiday'
		WHEN DATE = '2023-12-25' THEN 'Christmas Day'
		WHEN DATE = '2023-12-26' THEN 'Boxing Day'
        ELSE NULL
    END AS Holiday_Name
FROM DateSeries
OPTION (MAXRECURSION 1000);


---7---

/* This SQL script populates the Station table with unique station codes and names from the Railway table.
It ensures that every station appearing as either a departure or arrival station is added only once to the Station table. */


INSERT INTO Station (Station_Code, Station_Name)
SELECT DISTINCT Departure_Station_Code, Departure_Station 
FROM Railway;


INSERT INTO Station (Station_Code, Station_Name)
SELECT DISTINCT Arrival_Destination_Code, Arrival_Destination 
FROM Railway
WHERE Arrival_Destination_Code NOT IN (SELECT Station_Code FROM Station);


---8---

/* This SQL script inserts unique routes from the Railway table into the Routes table.
Each route represents a unique combination of a departure station and an arrival station,
ensuring that no duplicate routes are stored.*/


INSERT INTO Routes (Route_Code, Departure_Station_Code, Arrival_Destination_Code)
SELECT DISTINCT 
    CONCAT(Departure_Station_Code, '-', Arrival_Destination_Code) AS Route_Code,
    Departure_Station_Code,
    Arrival_Destination_Code
FROM Railway;


---9---

/* This SQL script inserts unique journeys from the Railway table into the Journey table,
ensuring that each journey has a unique identifier and is properly linked to its respective route and date. */



INSERT INTO Journeys(Journey_ID, Route_Code, Date_Of_Journey, Departure_Time, Arrival_Time, 
                     Actual_Arrival_Time, Journey_Status, Reason_For_Delay)
SELECT DISTINCt
    CONCAT(Routes.Route_Code, ':', Railway.Date_Of_Journey, ':', FORMAT(Railway.Departure_Time, 'hhmm')) AS Journey_ID,
    Routes.Route_Code,
    Railway.Date_Of_Journey,
    Railway.Departure_Time,
    Railway.Arrival_Time,
    Railway.Actual_Arrival_Time, 
    Railway.Journey_Status,
	Railway.Reason_For_Delay
FROM Railway
JOIN Routes 
    ON Railway.Departure_Station_Code = Routes.Departure_Station_Code
    AND Railway.Arrival_Destination_Code = Routes.Arrival_Destination_Code;


---10---

/* This SQL script inserts transaction records from the Railway table into the Transactions table,
ensuring each transaction is correctly linked to a Journey based on the Journey_ID. */



INSERT INTO Transactions (Transaction_ID, Date_Of_Purchase, Journey_ID, Time_Of_Purchase, 
                          Purchase_Type, Payment_Method, Railcard, Ticket_Class, 
                          Ticket_Type, Price, Refund_Request)
SELECT 
    Railway.Transaction_ID,
    Railway.Date_Of_Purchase,
    Journeys.Journey_ID,
    Railway.Time_Of_Purchase,
    Railway.Purchase_Type,
    Railway.Payment_Method,
    Railway.Railcard,
    Railway.Ticket_Class,
    Railway.Ticket_Type,
    Railway.Price,
    Railway.Refund_Request
FROM Railway
JOIN Journeys 
    ON Railway.Departure_Station_Code = LEFT(Journeys.Route_Code, 3)
    AND Railway.Arrival_Destination_Code = RIGHT(Journeys.Route_Code, 3)
    AND Railway.Date_Of_Journey = Journeys.Date_Of_Journey
    AND Railway.Departure_Time = Journeys.Departure_Time;

--- Analysis Questions And Answers ---

-- Passenger Performance --

-- 1. What is the number of Tickets sold? --

select COUNT(Transaction_ID) as #_of_Tickets 
from Transactions

-- 2. What is the most Payment Method? --

select Payment_Method, COUNT(Payment_Method) as #_of_Payment_Method,
	   Format( (COUNT(Payment_Method)*100/(select COUNT(*)* 1.0 from Transactions)),'N2')+'%' as '%_of_Payment_Method'
from Transactions
group by Payment_Method
order by COUNT(Payment_Method) desc

-- 3. What is the most common Ticket Type? --

select Ticket_Type, COUNT(Ticket_Type) as #_of_Ticket_Type,
	   Format( (COUNT(Ticket_Type)*100/(select COUNT(*)* 1.0 from Transactions)),'N2')+'%' as '%_of_Ticket_Type'
from Transactions
group by Ticket_Type
order by COUNT(Ticket_Type) desc

-- 4. What is the most common Ticket Class? --

select Ticket_Class, COUNT(Ticket_Class) as #_of_Ticket_Class,
	   Format( (COUNT(Ticket_Class)*100/(select COUNT(*)* 1.0 from Transactions)),'N2')+'%' as '%_of_Ticket_Class'
from Transactions
group by Ticket_Class
order by COUNT(Ticket_Class) desc

-- 5. What is the Number of online Transactions vs station Transactions? --

select Purchase_Type, COUNT(Purchase_Type) as #_of_Purchase_Type,
	   Format( (COUNT(Purchase_Type)*100/(select COUNT(*)* 1.0 from Transactions)),'N2')+'%' as '%_of_Purchase_Type'
from Transactions
group by Purchase_Type
order by COUNT(Purchase_Type) desc

-- 6. What percentage of customers use railcard? --

select Railcard, COUNT(Railcard) as #_of_Railcard,
	   Format( (COUNT(Railcard)*100/(select COUNT(*)* 1.0 from Transactions)),'N2')+'%' as '%_of_Railcard'
from Transactions
group by Railcard
order by COUNT(Railcard) desc

-- 7. What is the number of Tickets per Month? --

WITH MonthlyCounts AS (
    SELECT 
        MONTH(Date_of_Purchase) AS Month_Number,
        DATENAME(month, Date_of_Purchase) AS Month_Name,
        COUNT(*) AS #_of_Tickets_ber_Month
    FROM Transactions
    GROUP BY 
        MONTH(Date_of_Purchase), 
        DATENAME(month, Date_of_Purchase))
SELECT 
    Month_Name,
    #_of_Tickets_ber_Month,
    #_of_Tickets_ber_Month - LAG(#_of_Tickets_ber_Month) OVER (ORDER BY Month_Number) AS DifferenceFromPrevious
FROM MonthlyCounts
where Month_Name<>'December'
ORDER BY Month_Number

-- 8. What are the numbers of Passenger per Days? --

select DATENAME(WEEKDAY,Date_of_Journey) as Day_Name,
	   COUNT(*) as #_of_Passenger_per_Day
from Transactions t join Journeys j
on t.Journey_ID=j.Journey_ID
group by DATEPART(WEEKDAY,Date_of_Journey),
		 DATENAME(WEEKDAY,Date_of_Journey)
order by DATEPART(WEEKDAY,Date_of_Journey)

-- 9. What are the numbers of Passenger per hours? --

SELECT 
    RIGHT('0' + CAST(DATEPART(HOUR, Departure_Time) % 12 AS VARCHAR), 2) +
    CASE WHEN DATEPART(HOUR, Departure_Time) < 12 THEN ' AM' ELSE ' PM'
    END AS Journeys_Departure_Time,
    COUNT(*) AS #_of_Passenger_per_Hour
FROM Transactions t join Journeys j
on t.Journey_ID=j.Journey_ID
GROUP BY DATEPART(HOUR, Departure_Time)
ORDER BY DATEPART(HOUR, Departure_Time)

-- 10. What is the Average Number of Transactions per Day Type? --

select Day_Type,COUNT(Transaction_ID)/COUNT(distinct Date) as avg_Tickets_per_day_Type
from Transactions t join Calendar c
on t.Date_of_Purchase=c.Date
group by Day_Type
order by COUNT(Transaction_ID)/COUNT(distinct Date) desc

-- Railway Performance --

-- 1. What is the total number of Journeys? --

select count(*) as #_of_Journeys
from Journeys

-- 2. What is the total number of Journeys On Time? --

select count(*) as #_of_Journeys_On_Time
from Journeys
where Journey_Status='On Time'

-- 3. How many journeys are delayed? --

select count(*) as #_of_Journeys_On_Time
from Journeys
where Journey_Status='Delayed'

-- 4. How many journeys are cancelled? --

select count(*) as #_of_Journeys_On_Time
from Journeys
where Journey_Status='Cancelled'

-- 5. How is Journeys distributed by Journey per month? --

select DATENAME(MONTH,Date_of_Journey) as Month_Name, COUNT(Date_of_Journey) as #_of_Journeys_per_Month
from Journeys
group by DATEPART(MONTH,Date_of_Journey),
		 DATENAME(MONTH,Date_of_Journey)
order by DATEPART(MONTH,Date_of_Journey)

-- 6. What is the number of Journeys per Day? --

select DATENAME(WEEKDAY,Date_of_Journey) as Day_Name, COUNT(Date_of_Journey) as #_of_Journeys_per_Day
from Journeys
group by DATEPART(WEEKDAY,Date_of_Journey),
		 DATENAME(WEEKDAY,Date_of_Journey)
order by DATEPART(WEEKDAY,Date_of_Journey)

-- 7. How were journeys distributed by delay reason? --

select Reason_for_Delay, COUNT(Reason_for_Delay) as #_of_Delayed_Journeys_by_Reasons
from Journeys
where Reason_for_Delay is not null
group by Reason_for_Delay
order by COUNT(Reason_for_Delay) desc

-- 8. How many Transactions are cancelled and delayed? and what is the percentage of them?--

select Journey_Status, COUNT(Transaction_ID) as #_Transactions,
	   SUM(CASE WHEN t.Refund_Request = 'Yes' THEN 1 ELSE 0 END) AS #_Refunded
from Journeys j join Transactions t
on j.Journey_ID=t.Journey_ID
where Journey_Status<>'On Time'
group by Journey_Status

-- 9. What is the average delay duration? --

select CONVERT(varchar,DATEADD(SECOND,AVG(DATEDIFF(SECOND,Arrival_Time,Actual_Arrival_Time)),0),108)
	   as AVG_Delay_Duration
from Journeys
where Journey_Status='Delayed'

-- 10. What is the Average Number of Journeys per Day Type? --

select Day_Type,format(COUNT(Journey_ID)*1.0/COUNT(distinct Date),'n1') as avg_Journeys_per_day_Type
from Journeys j join Calendar c
on j.Date_of_Journey=c.Date
group by Day_Type
order by COUNT(Journey_ID)/COUNT(distinct Date) desc

-- 11. What is the number of Journeys On Time per Month?--

select DATENAME(MONTH,Date_of_Journey) as Month_Name, COUNT(Journey_ID) as #_Of_Journey_On_Time
from Journeys
where Journey_Status='On Time'
group by DATENAME(MONTH,Date_of_Journey), DATEPART(MONTH,Date_of_Journey)
order by DATEPART(MONTH,Date_of_Journey)

-- 12. What is the Reliability Score for On Time Journeys?--

select DATENAME(MONTH,Date_of_Journey) as Month_Name,
	   format(COUNT(CASE WHEN Journey_Status='On Time' THEN Journey_ID END)*100.0/COUNT(Journey_ID),'n2')+'%' AS On_Time_Percentage
from Journeys
group by DATENAME(MONTH,Date_of_Journey),DATEPART(MONTH,Date_of_Journey)
order by DATEPART(MONTH,Date_of_Journey)

-- Routes & Stations Analysis --

-- 1. What is the number of Routes? --

select count(*) as #_of_Routes
from Routes

-- 2. What is the number of Departure Stations? --

select count(distinct Departure_Station_Code) as #_Departure_Stations
from Routes r join Station s
on r.Departure_Station_Code=s.Station_Code

-- 3. What is the number of Arrival Stations? --

select count(distinct Arrival_Destination_Code) as #_Arrival_Stations
from Routes r join Station s
on r.Departure_Station_Code=s.Station_Code

-- 4. What are the top 5 routes with highest percentage of delays? --

select top 5 r.Route_Code, s.Station_Name+' - '+a.Station_Name AS Route_Name,count(Journey_ID) AS Total_Journeys,
	count(case when Journey_Status = 'Delayed' THEN Journey_ID END) as Delayed_Journeys, 
    convert(varchar, count(case when Journey_Status = 'Delayed' THEN Journey_ID END)* 100 / count(Journey_ID)) + '%' as Delay_Percentage
from Journeys j join Routes r
on j.Route_Code=r.Route_Code join Station s
on r.Departure_Station_Code=s.Station_Code join Station a
on r.Arrival_Destination_Code=a.Station_Code
group by r.Route_Code, s.Station_Name+' - '+a.Station_Name
order by count(case when Journey_Status = 'Delayed' THEN Journey_ID END)* 100 / count(Journey_ID) desc

-- 5. What are the top 5 routes with highest percentage of cancellations? --

select top 5 r.Route_Code, s.Station_Name+' - '+a.Station_Name AS Route_Name,count(Journey_ID) AS Total_Journeys,
	count(case when Journey_Status = 'Cancelled' THEN Journey_ID END) as Delayed_Journeys, 
    convert(varchar, count(case when Journey_Status = 'Cancelled' THEN Journey_ID END)* 100 / count(Journey_ID)) + '%' as Delay_Percentage
from Journeys j join Routes r
on j.Route_Code=r.Route_Code join Station s
on r.Departure_Station_Code=s.Station_Code join Station a
on r.Arrival_Destination_Code=a.Station_Code
group by r.Route_Code, s.Station_Name+' - '+a.Station_Name
order by count(case when Journey_Status = 'Cancelled' THEN Journey_ID END)* 100 / count(Journey_ID) desc


-- 6. What is the top 5 of used Departure Stations? --

select top 5 Station_Name, COUNT(Journey_ID) #_of_Journeys
from Journeys j join Routes r
on j.Route_Code=r.Route_Code
join Station s on r.Departure_Station_Code=s.Station_Code
group by Station_Name
order by COUNT(Journey_ID) desc

-- 7. What is the Bottom 5 of used Departure Stations? --

select top 5 Station_Name, COUNT(Journey_ID) #_of_Journeys
from Journeys j join Routes r
on j.Route_Code=r.Route_Code
join Station s on r.Departure_Station_Code=s.Station_Code
group by Station_Name
order by COUNT(Journey_ID) asc

-- 8. What is the top 5 of used Arrival Stations? --

select top 5 Station_Name, COUNT(Journey_ID) #_of_Journeys
from Journeys j join Routes r
on j.Route_Code=r.Route_Code
join Station s on r.Arrival_Destination_Code=s.Station_Code
group by Station_Name
order by COUNT(Journey_ID) desc

-- 9. What is the Bottom 5 of used Arrival Stations? --

select top 5 Station_Name, COUNT(Journey_ID) as #_of_Journeys
from Journeys j join Routes r
on j.Route_Code=r.Route_Code
join Station s on r.Arrival_Destination_Code=s.Station_Code
group by Station_Name
order by COUNT(Journey_ID) asc

-- 10. What are the Bottom 5 Routes with number of journeys? --

select distinct top 5 r.Route_Code, (s.Station_Name+' - '+a.Station_Name) as Route_Name, COUNT(Journey_ID) as #_of_Journey
from Journeys j join Routes r
on j.Route_Code=r.Route_Code join Station s
on r.Departure_Station_Code=s.Station_Code join Station a
on r.Arrival_Destination_Code=a.Station_Code
group by r.Route_Code, s.Station_Name+' - '+a.Station_Name
order by COUNT(Journey_ID) desc

-- 11. What are the Bottom 5 Routes with number of journeys? --

select distinct top 5 r.Route_Code, (s.Station_Name+' - '+a.Station_Name) as Route_Name, COUNT(Journey_ID) as #_of_Journey
from Journeys j join Routes r
on j.Route_Code=r.Route_Code join Station s
on r.Departure_Station_Code=s.Station_Code join Station a
on r.Arrival_Destination_Code=a.Station_Code
group by r.Route_Code, s.Station_Name+' - '+a.Station_Name
order by COUNT(Journey_ID) asc

-- 12. What are the number of journeys in each Route? --

select distinct r.Route_Code, (s.Station_Name+' - '+a.Station_Name) as Route_Name, COUNT(Journey_ID) as #_of_Journey
from Journeys j join Routes r
on j.Route_Code=r.Route_Code join Station s
on r.Departure_Station_Code=s.Station_Code join Station a
on r.Arrival_Destination_Code=a.Station_Code
group by r.Route_Code, s.Station_Name+' - '+a.Station_Name
order by COUNT(Journey_ID) desc

-- Sales & financial  --

-- 1. What is the total revenue? --

select '$'+CONVERT(varchar,SUM(Price)) as Total_Revenue
from Transactions

-- 2. What is the total refund? --

select '$'+CONVERT(varchar,SUM(Price)) as Total_Refund,
	   FORMAT((SUM(Price)*100/(select SUM(Price)*1.0 from Transactions)),'n1')+'%' as Refund_Percentage
from Transactions
where Refund_Request='Yes'

-- 3. What is the net revenue? --

select '$'+CONVERT(varchar,SUM(Price)) as Net_Revenue,
	   FORMAT(((select SUM(Price) from Transactions where Refund_Request<>'Yes')*100/
	   (select SUM(Price)*1.0 from Transactions)),'n1')+'%' as Net_Revenue_Percentage
from Transactions
where Refund_Request<>'Yes'

-- 4. What is the average ticket price? --

select '$'+format(AVG(Price*1.0),'n1') as Average_Price
from Transactions

-- 5. What is the top 5 Routes by Revenue? --

SELECT top 5 j.Route_Code, (s.Station_Name+' - '+a.Station_Name) as Route_Name,
	   '$'+CONVERT(varchar,SUM(Price)) AS Total_Revenue
FROM Transactions t
JOIN Journeys j ON t.Journey_ID = j.Journey_ID
JOIN Routes r ON j.Route_Code = r.Route_Code
JOIN Station s ON r.Departure_Station_Code = s.Station_Code
JOIN Station a ON r.Arrival_Destination_Code = a.Station_Code
WHERE Refund_Request = 'No'
GROUP BY j.Route_Code, (s.Station_Name+' - '+a.Station_Name)
ORDER BY SUM(Price) DESC

-- 6. What is the bottom 5 Routes by Revenue? --

SELECT TOP 5 r.Route_Code, (s.Station_Name+' - '+a.Station_Name) as Route_Name,
    '$'+CONVERT(varchar,ISNULL(SUM(t.Price), 0)) AS Total_Revenue
FROM Routes r
LEFT JOIN Journeys j ON r.Route_Code = j.Route_Code
LEFT JOIN Transactions t ON j.Journey_ID = t.Journey_ID AND t.Refund_Request = 'No'
LEFT JOIN Station s ON r.Departure_Station_Code = s.Station_Code
LEFT JOIN Station a ON r.Arrival_Destination_Code = a.Station_Code
GROUP BY r.Route_Code, (s.Station_Name+' - '+a.Station_Name)
ORDER BY ISNULL(SUM(t.Price), 0) ASC 

-- 7. How is revenue distributed by payment method? --

select Payment_Method, '$'+CONVERT(varchar,SUM(Price)) AS Total_Revenue
from Transactions
where Refund_Request='No'
group by Payment_Method
order by SUM(Price) desc

-- 8. How is revenue distributed by Purchase Type? --

select Purchase_Type, '$'+CONVERT(varchar,SUM(Price)) AS Total_Revenue
from Transactions
where Refund_Request='No'
group by Purchase_Type
order by SUM(Price) desc

-- 9. How are ticket sales distributed by ticket type? --

select Ticket_Type, '$'+CONVERT(varchar,SUM(Price)) AS Total_Revenue
from Transactions
where Refund_Request='No'
group by Ticket_Type
order by SUM(Price) desc

-- 10. What is the monthly Trend of Net Revenue? --

select DATENAME(MONTH,Date_of_Purchase) as Month_Name, '$'+CONVERT(varchar,SUM(Price)) as Total_Revenue
from Transactions
where month(Date_of_Purchase)<>12
and Refund_Request='No'
group by DATENAME(MONTH,Date_of_Purchase), DATEPART(MONTH,Date_of_Purchase)
order by DATEPART(MONTH,Date_of_Purchase)

-- 11. What is the total refund by journey statues? --

select Journey_Status, '$'+CONVERT(varchar,SUM(Price)) AS Total_Revenue
from Transactions t join Journeys j
on t.Journey_ID=j.Journey_ID
where Refund_Request='Yes'
group by Journey_Status

-- 12. What is the Average Net Revenue per Day Type? --

select Day_Type,'$'+CONVERT(varchar,SUM(Price)/COUNT(distinct j.Date_of_Journey)) as avg_Net_Revenue_per_day_Type
from Journeys j join Calendar c
on j.Date_of_Journey=c.Date
join Transactions t on j.Journey_ID=t.Journey_ID
where Refund_Request='No'
group by Day_Type
order by sum(Price)/COUNT(distinct j.Date_of_Journey) desc

-- 13. What is the Impact of Delay Time on refund? --

WITH Journey_Delays AS (SELECT CASE WHEN DATEDIFF(MINUTE, Arrival_Time, Actual_Arrival_Time) = 0 THEN '0 mins'
        WHEN DATEDIFF(MINUTE, Arrival_Time, Actual_Arrival_Time) <= 15 THEN '1–15 mins'
        WHEN DATEDIFF(MINUTE, Arrival_Time, Actual_Arrival_Time) <= 30 THEN '16–30 mins'
        WHEN DATEDIFF(MINUTE, Arrival_Time, Actual_Arrival_Time) <= 45 THEN '31–45 mins'
        WHEN DATEDIFF(MINUTE, Arrival_Time, Actual_Arrival_Time) <= 60 THEN '46–60 mins'
        END AS Delay_Category,Price
FROM Journeys j JOIN Transactions t ON j.Journey_ID = t.Journey_ID
WHERE Refund_Request = 'Yes' AND Journey_Status = 'Delayed')
SELECT Delay_Category, '$'+convert(varchar,SUM(Price)) AS Total_Refunded_Amount
FROM Journey_Delays
GROUP BY Delay_Category
ORDER BY Delay_Category

-- 14. What is the Net Revenue by Journey Statues? --

WITH No_Refund_Revenue AS (SELECT SUM(Price) AS Total_Net_Revenue
FROM Transactions WHERE Refund_Request = 'No')
SELECT Journey_Status, '$'+convert(varchar,SUM(CASE WHEN Refund_Request = 'No' THEN Price END)) AS Net_Revenue,
format(round((SUM(CASE WHEN Refund_Request='No' THEN Price END)*100.0/n.Total_Net_Revenue),0),'n0')+'%' AS Percentage
FROM Journeys j JOIN Transactions t ON j.Journey_ID = t.Journey_ID
CROSS JOIN No_Refund_Revenue n
GROUP BY Journey_Status, n.Total_Net_Revenue
ORDER BY Journey_Status desc

