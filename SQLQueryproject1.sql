

SELECT COLUMN_NAME  
FROM INFORMATION_SCHEMA.COLUMNS  
WHERE TABLE_NAME = 'railway';  

-- Update empty values in "Reason for Delay" column to 'On Time'  
UPDATE railway  
SET Reason_for_Delay = 'On Time'  
WHERE TRIM(Reason_for_Delay) = '';  

-- Update values in [Refund Request] column to 'not-refunded' if they are 'no'  
UPDATE railway  
SET Refund_Request = 'not-refunded'  
WHERE TRIM(Refund_Request) = 'no';  

-- Update values in [Refund Request] column to 'refunded' if they are 'yes'  
UPDATE railway  
SET Refund_Request = 'refunded'  
WHERE TRIM(Refund_Request) = 'yes';  

-- Standardize values in the [Reason for Delay] column for similar categories  
UPDATE railway  
SET Reason_for_Delay =  
 CASE  
 WHEN Reason_for_Delay IN ('Weather', 'Weather Conditions') THEN 'Weather'  
 WHEN Reason_for_Delay IN ('Staffing', 'Staff Shortage') THEN 'Staffing'  
 ELSE Reason_for_Delay 
  END;  

-- Calculate the average price for each combination of [Railcard], [Ticket_Type], and [Ticket_Class], sorted by price  
SELECT Railcard, Ticket_Type, Ticket_Class, Departure_Station, Arrival_Destination, 
       AVG(Price) AS Avg_Price
FROM railway
GROUP BY Railcard, Ticket_Type, Ticket_Class, Departure_Station, Arrival_Destination
ORDER BY Railcard, Ticket_Type, Ticket_Class, Avg_Price DESC;

--is query categorizes the Railcard column by replacing 'None' with 'No Discount'.
UPDATE [dbo].[railway]
SET Railcard = 
    CASE 
        WHEN Railcard = 'None' THEN 'No Discount'
        ELSE Railcard
    END;

select * from railway