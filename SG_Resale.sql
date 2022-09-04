#SQL
/*
SG Resale Flat DATA EXPLORATION 
SKILLS USED: WINDOWS FUNCTION, AGGREGATE FUNCTIONS, CREATING VIEWS
*/

------------------------------------ To view whole dataset ------------------------------------

SELECT 
    *
FROM
    sg_resale.flat_prices;


------------------------------------ To check if NULL value exist in the data ------------------------------------

SELECT 
    *
FROM
    sg_resale.flat_prices
WHERE
    NULL;


------------------------------------ To check number of distinct towns (26 distinct town) ------------------------------------

SELECT DISTINCT
    town
FROM
    sg_resale.flat_prices;


------------------------------------ To check number of distinct flat models (13 distinct flat model) ------------------------------------

SELECT DISTINCT
    flat_model
FROM
    sg_resale.flat_prices;


------------------------------------ To check number of distinct flat type (7 distinct flat type) ------------------------------------

SELECT DISTINCT
    flat_type
FROM
    sg_resale.flat_prices;


------------------------------------ Upon checking, 2-rooms is showing in flat_type and flat_model ------------------------------------

SELECT 
    *
FROM
    sg_resale.flat_prices
WHERE
    flat_model = '2-ROOM';


------------------------------------ To change flat_model with 2-rooms to Standard after extensive check online to confirm (https://www.teoalida.com/singapore/hdbflattypes/) ------------------------------------

UPDATE sg_resale.flat_prices 
SET 
    flat_model = CASE flat_prices_id
        WHEN 2322 THEN 'STANDARD'
        WHEN 7236 THEN 'STANDARD'
        WHEN 9312 THEN 'STANDARD'
        WHEN 13400 THEN 'STANDARD'
        WHEN 36781 THEN 'STANDARD'
        WHEN 50680 THEN 'STANDARD'
        WHEN 93091 THEN 'STANDARD'
        WHEN 93838 THEN 'STANDARD'
        WHEN 121865 THEN 'STANDARD'
        WHEN 136499 THEN 'STANDARD'
        WHEN 137470 THEN 'STANDARD'
        WHEN 160674 THEN 'STANDARD'
        WHEN 168852 THEN 'STANDARD'
        WHEN 217479 THEN 'STANDARD'
        WHEN 222388 THEN 'STANDARD'
        WHEN 243436 THEN 'STANDARD'
        WHEN 248957 THEN 'STANDARD'
        WHEN 248958 THEN 'STANDARD'
        WHEN 265910 THEN 'STANDARD'
        WHEN 286060 THEN 'STANDARD'
        WHEN 286061 THEN 'STANDARD'
    END
WHERE
    flat_prices_id IN (2322 , 7236,
        9312,
        13400,
        36781,
        50680,
        93091,
        93838,
        121865,
        136499,
        137470,
        160674,
        168852,
        217479,
        222388,
        243436,
        248957,
        248958,
        265910,
        286060,
        286061);


------------------------------------ Updated number of flat model (12 distinct flat model) ------------------------------------

SELECT DISTINCT
    flat_model
FROM
    sg_resale.flat_prices;


------------------------------------ To check number of distinct lease commence date of the flats (31 distinct lease commence date) ------------------------------------

SELECT DISTINCT
    lease_commence_date
FROM
    sg_resale.flat_prices;


------------------------------------ Create a new column with date formatted. However as data did not have day, the days are 00 (which will be disregarded in future analysis) ------------------------------------

ALTER TABLE sg_resale.flat_prices ADD newcol date;
UPDATE sg_resale.flat_prices 
SET 
    newcol = DATE_FORMAT(STR_TO_DATE(month, '%Y-%m'), '%Y/%m/%d');

# Rename the column newcol to date
ALTER TABLE sg_resale.flat_prices
RENAME COLUMN newcol TO date;


------------------------------------ To view the max and min floor area sqm ------------------------------------

SELECT 
    flat_type,
    MAX(floor_area_sqm) AS floor_area_sqm,
    town,
    'MAX' AS Type
FROM
    sg_resale.flat_prices
GROUP BY flat_type 
UNION ALL SELECT 
    flat_type,
    MIN(floor_area_sqm) AS floor_area_sqm,
    town,
    'MIN'
FROM
    sg_resale.flat_prices
GROUP BY flat_type
ORDER BY flat_type , floor_area_sqm;


------------------------------------ Count number of lease commence date ------------------------------------

SELECT 
    lease_commence_date, COUNT(lease_commence_date) AS Count
FROM
    sg_resale.flat_prices
GROUP BY lease_commence_date
ORDER BY Count DESC;


------------------------------------ To find the min and max resale price against flat type ------------------------------------

SELECT 
    flat_type,
    MIN(resale_price) AS min_resale_price,
    MAX(resale_price) AS max_resale_price
FROM
    sg_resale.flat_prices
GROUP BY flat_type;


------------------------------------ To find the min and max resale price against flat model ------------------------------------

SELECT MIN(resale_price) as min_resale_price, MAX(resale_price) as max_resale_price, flat_model
FROM (
select *,row_number() over(partition by flat_model)
from sg_resale.flat_prices
) A
group by flat_model
ORDER BY flat_model;


------------------------------------ To find total count of dictinct dates (120 distinct dates (months and years combine)) ------------------------------------

SELECT 
    COUNT(DISTINCT date)
FROM
    sg_resale.flat_prices;


------------------------------------ To find total count of dictinct years (10 distinct years (1990 - 1999)) ------------------------------------

SELECT DISTINCT
    DATE_FORMAT(date, '%Y') AS yearly_date
FROM
    sg_resale.flat_prices;


------------------------------------ To view the max and min resale price ------------------------------------

SELECT DISTINCT
    town,
    flat_type,
    MAX(resale_price) AS resale_price,
    'MAX' AS Type
FROM
    sg_resale.flat_prices
GROUP BY town 
UNION ALL SELECT DISTINCT
    town, flat_type, MIN(resale_price) AS resale_price, 'MIN'
FROM
    sg_resale.flat_prices
GROUP BY town
ORDER BY town , resale_price , flat_type;


------------------------------------ To view lowest sqm per town with highest resale price ------------------------------------

SELECT 
    t1.town,
    t1.floor_area_sqm,
    MAX(t1.resale_price) AS resale_value
FROM
    sg_resale.flat_prices AS t1
        JOIN
    (SELECT 
        town, MIN(floor_area_sqm) AS floor_area_sqm
    FROM
        sg_resale.flat_prices
    GROUP BY town) AS t2 ON t1.town = t2.town
        AND t1.floor_area_sqm = t2.floor_area_sqm
GROUP BY t1.town , t1.floor_area_sqm
ORDER BY town;


------------------------------------ Min storey range and max storey range (01 to 03, 25 to 27) ------------------------------------

SELECT 
    MIN(storey_range), MAX(storey_range)
FROM
    sg_resale.flat_prices;


------------------------------------ To view if it was possible to pull the value out of string. (Possible but cannot do the calculation for avg resale price against storey range as in string format) ------------------------------------

SELECT 
    storey_range, resale_price
FROM
    sg_resale.flat_prices
WHERE
    storey_range < 9;


------------------------------------ Create new column to store the last 2 digits of storey range ------------------------------------

ALTER TABLE sg_resale.flat_prices ADD storey VARCHAR(12);
UPDATE sg_resale.flat_prices 
SET 
    storey = RIGHT(storey_range, 2);


------------------------------------ Convert the new storey column to INT from VARCHAR ------------------------------------

ALTER TABLE sg_resale.flat_prices
MODIFY COLUMN storey INT;


------------------------------------ Create column storey status to indicate the bandwidth of each property based off the storey range/storey data ------------------------------------

ALTER TABLE sg_resale.flat_prices ADD storey_status VARCHAR(25);
UPDATE sg_resale.flat_prices 
SET 
    storey_status = CASE
        WHEN storey <= 9 THEN 'low_storey'
        WHEN storey >= 10 AND storey <= 18 THEN 'mid_storey'
        WHEN storey >= 19 AND storey <= 27 THEN 'high_storey'
        WHEN storey IS NULL THEN 'NULL'
        ELSE 'Error'
    END;


------------------------------------ Calculate the avg resale price per storey status (low,mid,high) ------------------------------------

SELECT 
    storey_status, AVG(resale_price) AS avg_resale_price
FROM
    sg_resale.flat_prices
GROUP BY storey_status;


 ------------------------------------ Altering sale year column to only show the year ------------------------------------

ALTER TABLE sg_resale.flat_prices ADD sale_year INT;
UPDATE sg_resale.flat_prices 
SET 
    sale_year = LEFT(date, 4);


------------------------------------ To view char_length of the column date ------------------------------------   

SELECT CHAR_LENGTH(date) FROM sg_resale.flat_prices;


------------------------------------ To extract the month and create new column sale month column ------------------------------------

SELECT SUBSTRING(date, 6, 2) FROM sg_resale.flat_prices;
ALTER TABLE sg_resale.flat_prices ADD sale_month INT;
UPDATE sg_resale.flat_prices 
SET 
    sale_month = SUBSTRING(date, 6, 2);


------------------------------------ To change the sale month to actual month instead of numbers. Requires to change from INT to VARCHAR ------------------------------------

ALTER TABLE sg_resale.flat_prices
MODIFY COLUMN sale_month VARCHAR(12);
UPDATE sg_resale.flat_prices 
SET 
    sale_month = CASE
        WHEN sale_month = 1 THEN 'January'
        WHEN sale_month = 2 THEN 'Febraury'
        WHEN sale_month = 3 THEN 'March'
        WHEN sale_month = 4 THEN 'April'
        WHEN sale_month = 5 THEN 'May'
        WHEN sale_month = 6 THEN 'June'
        WHEN sale_month = 7 THEN 'July'
        WHEN sale_month = 8 THEN 'August'
        WHEN sale_month = 9 THEN 'September'
        WHEN sale_month = 10 THEN 'October'
        WHEN sale_month = 11 THEN 'November'
        WHEN sale_month = 12 THEN 'December'
        ELSE 'Error'
    END;


------------------------------------ To check if dashboard exist (NIL) ------------------------------------

DROP VIEW IF EXISTS sgflats;


------------------------------------ To create new dashboard with only necessary information ------------------------------------

CREATE VIEW sgflats AS
    SELECT 
        flat_prices_id,
        town,
        flat_type,
        storey_range,
        floor_area_sqm,
        flat_model,
        lease_commence_date,
        resale_price,
        storey_status,
        sale_year,
        sale_month
    FROM
        sg_resale.flat_prices;


------------------------------------ To check dashboard ------------------------------------   

SELECT 
    *
FROM
    sgflats;


------------------------------------ To view sum of resale price over sale years ------------------------------------

SELECT 
    SUM(resale_price) as total_resale_price, sale_year
FROM
    sgflats
GROUP BY sale_year
ORDER BY total_resale_price;


------------------------------------ To view sum of resale price over sale month ------------------------------------

SELECT 
    SUM(resale_price) as total_resale_price, sale_month
FROM
    sgflats
GROUP BY sale_month
ORDER BY total_resale_price;


------------------------------------ To view sum of resale price over storey status ------------------------------------

SELECT 
    SUM(resale_price) as total_resale_price, storey_status
FROM
    sgflats
GROUP BY storey_status
ORDER BY total_resale_price;


------------------------------------ To view total sales within a month and year ------------------------------------

SELECT 
    sale_month,
    sale_year,
    SUM(resale_price) AS total_resale_price
FROM
    sgflats
GROUP BY sale_year , sale_month;
