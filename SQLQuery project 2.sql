-- إنشاء قاعدة البيانات 
CREATE DATABASE railway;


-- إنشاء جدول journey
CREATE TABLE journey (
    journey_id INT PRIMARY KEY NOT NULL,
    journey_status VARCHAR(50) NULL,
    reason_for_delay VARCHAR(50) NULL,
    refund_request VARCHAR(50) NULL
);


-- إنشاء جدول station
CREATE TABLE station (
    station_id INT IDENTITY(1,1) PRIMARY KEY, 
    station VARCHAR(100));

-- إنشاء جدول date
CREATE TABLE date (
    date_id INT IDENTITY(1,1) PRIMARY KEY, 
    full_date DATE,
    year INT,
    month INT,
    day INT,
    week_day VARCHAR(20));


-- إنشاء جدول time
CREATE TABLE time (
    time_id INT IDENTITY(1,1) PRIMARY KEY, 
    full_time TIME,
    hour INT,
    minute INT,
    period VARCHAR(50));


-- إنشاء جدول payment
CREATE TABLE payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY, 
    purchase_type VARCHAR(50), 
    payment_method VARCHAR(50));


-- إنشاء جدول ticket
CREATE TABLE ticket (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY, 
    ticket_type VARCHAR(50), 
    ticket_class VARCHAR(50),
    railcard VARCHAR(50));


-- إنشاء جدول fact_railway
CREATE TABLE fact_railway (
    transaction_id VARCHAR(50) PRIMARY KEY, 
    ticket_id INT,
    payment_id INT,
    departure_station_id INT,
    arrival_station_id INT,
    journey_id INT,
    price DECIMAL(10,2),
    purchase_date_id INT,
    journey_date_id INT,
    purchase_time_id INT,
    departure_time_id INT,
    arrival_time_id INT,
    actual_arrival_time_id INT) 
    
    -- الربط بالمفاتيح الخارجية
FOREIGN KEY (ticket_id) REFERENCES dim_ticket(ticket_id),
FOREIGN KEY (payment_id) REFERENCES dim_payment(payment_id),
FOREIGN KEY (departure_station_id) REFERENCES dim_station(station_id),
FOREIGN KEY (arrival_station_id) REFERENCES dim_station(station_id),
FOREIGN KEY (journey_id) REFERENCES dim_journey(journey_id),
FOREIGN KEY (purchase_date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (journey_date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (purchase_time_id) REFERENCES dim_time(time_id),
FOREIGN KEY (departure_time_id) REFERENCES dim_time(time_id),
FOREIGN KEY (arrival_time_id) REFERENCES dim_time(time_id),
FOREIGN KEY (actual_arrival_time_id) REFERENCES dim_time(time_id)
);

INSERT INTO dim_date (full_date, year, month, day, week_day)
SELECT DISTINCT 
    Date_of_Purchase AS full_date,
    YEAR(Date_of_Purchase) AS year,
    MONTH(Date_of_Purchase) AS month,
    DAY(Date_of_Purchase) AS day,
    DATENAME(WEEKDAY, Date_of_Purchase) AS week_day
FROM railway
WHERE Date_of_Purchase IS NOT NULL;

INSERT INTO dim_date (full_date, year, month, day, week_day)
SELECT DISTINCT 
    Date_of_Journey AS full_date,
    YEAR(Date_of_Journey) AS year,
    MONTH(Date_of_Journey) AS month,
    DAY(Date_of_Journey) AS day,
    DATENAME(WEEKDAY, Date_of_Journey) AS week_day
FROM railway
WHERE Date_of_Journey IS NOT NULL;

select*from[dbo].[dim_date];

INSERT INTO dim_journey (journey_status, reason_for_delay, refund_request)
SELECT DISTINCT 
    journey_status, 
    reason_for_delay, 
    refund_request
FROM railway;

select*from  [dbo].[dim_journey] ;

INSERT INTO dbo.dim_payment (purchase_type, payment_method)
SELECT DISTINCT 
    purchase_type, 
    payment_method
FROM railway

select*from [dbo].[dim_payment]

INSERT INTO dbo.dim_station (station)
SELECT DISTINCT Arrival_Destination FROM railway
WHERE Arrival_Destination IS NOT NULL

UNION 

SELECT DISTINCT Departure_Station FROM railway
WHERE Departure_Station IS NOT NULL;

select* from [dbo].[dim_station];

INSERT INTO dbo.dim_ticket (ticket_type, ticket_class, railcard)
SELECT DISTINCT ticket_type, ticket_class, railcard 
FROM railway;

select * from [dbo].[dim_time]; 



UPDATE f
SET f.[purchase_date_id] = d.date_id
FROM[fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id   
JOIN [dbo].[dim_date] d ON r.Date_of_Purchase = d.full_date
WHERE r.Date_of_Purchase IS NOT NULl

UPDATE f
SET f.[journey_date_id] = d.date_id
FROM[fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id  
JOIN [dbo].[dim_date] d ON r.[Date_of_Journey] = d.full_date
WHERE r.[Date_of_Journey] IS NOT NULl




INSERT INTO [fact_railway] (transaction_id)
SELECT transaction_id FROM [dbo].[railway]
WHERE transaction_id IS NOT NULL;

UPDATE f
SET f.[departure_time_id] = t.time_id
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id 
JOIN [dbo].[dim_time] t ON CAST(r.[departure_time] AS TIME) = t.full_time
WHERE r.[departure_time] IS NOT NULL;

UPDATE f
SET f.[purchase_time_id] = t.time_id
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.transaction_id  
JOIN [dbo].[dim_time] t ON CAST(r.[Time_of_Purchase] AS TIME) = t.full_time
WHERE r.[Time_of_Purchase] IS NOT NULL;

UPDATE f
SET f.[actual_arrival_time_id] = t.time_id
FROM [fact_railway] f
JOIN railway r ON f.transaction_id = r.Transaction_ID
JOIN [dbo].[dim_time] t ON CAST(r.[Actual_Arrival_Time] AS TIME) = t.full_time
WHERE r.[Actual_Arrival_Time] IS NOT NULL;

UPDATE f
SET f.price = r.price
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
WHERE r.price IS NOT NULL;

UPDATE f
SET f.journey_id = j.journey_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN [dim_journey] j 
    ON r.journey_status = j.journey_status 
    AND r.reason_for_delay = j.reason_for_delay
    AND r.refund_request = j.refund_request
WHERE j.journey_id IS NOT NULL;

UPDATE f
SET f.journey_id = j.journey_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN [dim_journey] j 
    ON r.reason_for_delay = j.reason_for_delay and r.[journey_status]=j.[journey_status] and r.[refund_request]=j.[refund_request]
WHERE j.journey_id IS NOT NULL;


UPDATE f
SET f.[departure_station_id] = s.station_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN [dim_station] s 
    ON r.[Departure_Station] = s.station
WHERE s.station_id IS NOT NULL;

UPDATE f
SET f.payment_id = p.payment_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN [dim_payment] p 
    ON r.payment_method = p.payment_method
    AND r.purchase_type = p.purchase_type
WHERE p.payment_id IS NOT NULL;

UPDATE f
SET f.ticket_id = t.ticket_id
FROM [fact_railway] f
JOIN [railway] r ON f.transaction_id = r.transaction_id
JOIN [dim_ticket] t 
    ON r.ticket_type = t.ticket_type
    AND r.ticket_class = t.ticket_class
    AND r.railcard = t.railcard
WHERE t.ticket_id IS NOT NULL;






select*from[dbo].[fact_railway]


select*from[dbo].[railway]


UPDATE ticket
SET Railcard = 
    CASE 
        WHEN Railcard = 'None' THEN 'No Discount'
        ELSE Railcard
    END;

	select*from ticket

