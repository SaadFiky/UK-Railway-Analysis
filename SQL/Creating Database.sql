-- Creat the database
CREATE DATABASE UK_Railways;
Go

-- Use the previously created database
USE UK_Railways;

-- Create Station table
CREATE TABLE Station (
	Station_Code NVARCHAR(50) PRIMARY KEY NOT NULL,
	Station_Name NVARCHAR(50) NOT NULL
	);

-- Creat Routes table
CREATE TABLE Routes (
	Route_Code NVARCHAR(50) PRIMARY KEY NOT NULL,
	Departure_Station_Code NVARCHAR(50) NOT NULL,
	Arrival_Destination_Code NVARCHAR(50) NOT NULL,
	CONSTRAINT DSC_FK FOREIGN KEY (Departure_Station_Code) REFERENCES Station(Station_Code),
	CONSTRAINT ADC_FK FOREIGN KEY (Arrival_Destination_Code) REFERENCES Station(Station_Code)
	);

-- Create Calendar table
CREATE TABLE Calendar (
	Date DATE PRIMARY KEY NOT NULL,
	Year INT NOT NULL,
	Quarter INT NOT NULL,
	Month INT NOT NULL,
	Month_Name NVARCHAR(50) NOT NULL,
	Week INT NOT NULL,
	Day_of_Week	NVARCHAR(50) NOT NULL,
	Day_Type NVARCHAR(50) NOT NULL,
	Holiday_Name NVARCHAR(50)
	);

-- Create Journeys table
CREATE TABLE Journeys (
	Journey_ID NVARCHAR(50) PRIMARY KEY NOT NULL,
	Route_Code NVARCHAR(50) NOT NULL,
	Date_of_Journey DATE NOT NULL,
	Departure_Time TIME NOT NULL,
	Arrival_Time TIME NOT NULL,
	Actual_Arrival_Time TIME,
	Delay_Duration NVARCHAR(50),
	Journey_Status NVARCHAR(50) NOT NULL CHECK (Journey_Status IN ('On Time', 'Delayed', 'Cancelled')), -- Validate status
	Reason_for_Delay NVARCHAR(50),
	CONSTRAINT RC_FK FOREIGN KEY (Route_Code) REFERENCES Routes(Route_Code),
	CONSTRAINT DOJ_FK FOREIGN KEY (Date_of_Journey) REFERENCES Calendar(Date)
	);

-- Create Transations table
CREATE TABLE Transactions (
	Transaction_ID NVARCHAR(50) PRIMARY KEY NOT NULL,
	Journey_ID NVARCHAR(50) NOT NULL,
	Date_of_Purchase DATE NOT NULL,
	Time_of_Purchase TIME NOT NULL,
	Purchase_Type NVARCHAR(50) NOT NULL CHECK (Purchase_Type IN ('Station', 'Online')), -- Validate purchase type
	Payment_Method NVARCHAR(50) NOT NULL CHECK (Payment_Method IN ('Credit Card', 'Debit Card', 'Contactless')), -- Validate payment method
	Railcard NVARCHAR(50) NOT NULL CHECK (Railcard IN ('No Railcard', 'Adult', 'Disalbed', 'Senior')), -- Validate Railcard type
	Ticket_Class NVARCHAR(50) NOT NULL CHECK (Ticket_Class IN ('First Class', 'Standard')), -- Validate ticket class
	Ticket_Type	NVARCHAR(50) NOT NULL CHECK (Ticket_Type IN ('Advance', 'Anytime', 'Off-Peak')), -- Validate ticket type
	Price INT NOT NULL CHECK (Price >= 0), -- Validate non-negative price
	Refund_Request NVARCHAR(50) NOT NULL CHECK (Refund_Request IN ('Yes', 'No')), -- Validate refund request
	CONSTRAINT J_ID_FK FOREIGN KEY (Journey_ID) REFERENCES Journeys(Journey_ID),
	CONSTRAINT DOP_FK FOREIGN KEY (Date_of_Purchase) REFERENCES Calendar(Date)
	);