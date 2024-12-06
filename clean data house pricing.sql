--create table
CREATE TABLE energy_usage_staging (
    type TEXT,
    date DATE,
    start_time TIME,
    end_time TIME,
    usage FLOAT4,
    units TEXT,
    cost TEXT,
    notes TEXT
);

--copy data from csv file
COPY Public."energy_usage_staging" FROM 'D:\D202.csv' DELIMITER ',' CSV HEADER;

--display dataset
SELECT * FROM energy_usage_staging;


--combine date and start_time column into time column
SELECT date, start_time, (date + start_time) AS time 
FROM energy_usage_staging eus;

--create a new column called cost_new 
SELECT cost, TO_NUMBER("cost", 'L9G999D99') AS cost_new
FROM energy_usage_staging eus  
ORDER BY cost_new DESC

-- query the right data that I want
SELECT type, 
(date + start_time) AS time, 
"usage", 
units, 
TO_NUMBER("cost", 'L9G999D99') AS cost, 
notes 
FROM energy_usage_staging

--create view from the query above
CREATE VIEW energy_view AS
SELECT type, 
(date + start_time) AS time, 
"usage", 
units, 
TO_NUMBER("cost", 'L9G999D99') AS cost, 
notes 
FROM energy_usage_staging


--detect blank notes
SELECT * 
FROM energy_view ew
-- where notes are not equal to an empty string
WHERE notes!='';

--extract day-of-week from date column and cast the output to an int
--DOW (day-of-week) which maps 0 to Sunday through to 6 for Saturday
SELECT *,
EXTRACT(DOW FROM time)::int AS day_of_week
FROM energy_view ew

--another method to create a binary column
--WHEN a day_of_week value is IN the set (0,6) THEN the it true, ELSE it false
SELECT type, time, usage, units, cost,
EXTRACT(DOW FROM time)::int AS day_of_week, 
EXTRACT(DOW FROM time)::int IN (0,6) AS is_weekend
FROM energy_view ew


--create table for the holidays
CREATE TABLE holidays (
date date)

--insert the holidays into table
INSERT INTO holidays 
VALUES ('2016-11-11'), 
('2016-11-24'), 
('2016-12-24'), 
('2016-12-25'), 
('2016-12-26'), 
('2017-01-01'),  
('2017-01-02'), 
('2017-01-16'), 
('2017-02-20'), 
('2017-05-29'), 
('2017-07-04'), 
('2017-09-04'), 
('2017-10-9'), 
('2017-11-10'), 
('2017-11-23'), 
('2017-11-24'), 
('2017-12-24'), 
('2017-12-25'), 
('2018-01-01'), 
('2018-01-15'), 
('2018-02-19'), 
('2018-05-28'), 
('2018-07-4'), 
('2018-09-03'), 
('2018-10-8')


--create another view with the data from our first round of cleaning
SELECT type, 
       time, 
       usage, 
       units, 
       cost,
       EXTRACT(DOW FROM time)::int AS day_of_week,
       (EXTRACT(DOW FROM time)::int IN (0, 6)) AS is_weekend,
       (DATE(time) IN (SELECT date FROM holidays)) AS is_holiday
FROM energy_view ew;



--if you use binary columns, then you can filter with a simple WHERE statement
SELECT *
FROM energy_view ew
WHERE is_weekend AND is_holiday




