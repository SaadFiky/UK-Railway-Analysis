USE UK_Railways;

-- 11. What percentage of journeys are delayed?
SELECT 
    j.Journey_Status, 
    COUNT(*) AS Journeys_Count,
	CONCAT(
		CAST(
			ROUND(
				COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Journeys), 
				2) 
			AS DECIMAL(10, 2)
		), ' %') AS Percentage_of_Total
FROM 
    Journeys j
GROUP BY 
    j.Journey_Status;

-- 12. What are the most common reasons for delays?
SELECT 
	j.Reason_for_Delay,
	COUNT(*) AS Journeys_Count,
	CONCAT(
		CAST(
			ROUND(
				COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Journeys WHERE Journey_Status <> 'On Time'), 
				2) 
			AS DECIMAL(10, 2)
		), ' %') AS Percentage_of_Total
FROM Journeys j
WHERE j.Reason_for_Delay IS NOT NULL
GROUP BY j.Reason_for_Delay
ORDER BY Journeys_Count DESC

-- 13. How does delay/cancelled frequency vary by time of day?
SELECT 
    DATEPART(HOUR, j.Departure_Time) AS Hour_Of_Day,
    COUNT(CASE WHEN j.Journey_Status = 'Delayed' THEN 1 END) AS Delay_Journeys,
    COUNT(CASE WHEN j.Journey_Status = 'Cancelled' THEN 1 END) AS Cancelled_Journeys
FROM Journeys j
GROUP BY DATEPART(HOUR, j.Departure_Time)
ORDER BY Hour_Of_Day;

-- 14. What is the average delay duration?
SELECT CONVERT(TIME, DATEADD(SECOND, AVG(DATEDIFF(SECOND, j.Arrival_Time, j.Actual_Arrival_Time)),0)) As Avg_Delay_Duration
FROM Journeys j
WHERE j.Journey_Status = 'Delayed'
