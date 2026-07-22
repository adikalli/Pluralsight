-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### A. Set Catalog and Schema

-- COMMAND ----------

-- DBTITLE 1,Use statements to set catalog and schema
USE CATALOG taxicatalog;

USE SCHEMA bronze;


-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B. Simple SQL Query

-- COMMAND ----------

-- DBTITLE 1,Filter table and limit records
SELECT *
FROM TaxiRides

WHERE VendorId = 1

LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C. Date & Time Functions

-- COMMAND ----------

-- DBTITLE 1,Extracting date related fields
SELECT
      PickupTime
      
    , YEAR       (PickupTime)       AS TripYear       -- Extract year value
    , MONTHNAME  (PickupTime)       AS TripMonth      -- Extract month name
    , DAYOFMONTH (PickupTime)       AS TripDay        -- Extract day of month value
    
    , DATE_PART  ('HOUR', PickupTime) AS TripHour     -- Extract hour value
                                                      -- Can specify date parts like YEAR, MONTH, WEEK, QUARTER etc.

    , TO_DATE    (PickupTime)       AS TripDate       -- Cast to date
    
FROM TaxiRides
LIMIT 100;


-- COMMAND ----------

-- DBTITLE 1,Manipulating dates
SELECT
      PickupTime
    , DropTime
    
    , DATEDIFF (MINUTE, PickupTime, DropTime)   AS TripTimeInMinutes    -- Extract Trip Time in minutes	
                                                                        -- TIMESTAMPDIFF is an alias    
    
    , DATEADD (HOUR, -1, PickupTime)            AS NewPickupTime        -- Subtract 1 hour from PickupTime
                                                                        -- TIMESTAMPADD is an alias

FROM TaxiRides
ORDER BY RideId
LIMIT 100;


-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D. Numeric Functions

-- COMMAND ----------

-- DBTITLE 1,Rounding numbers
SELECT 
       ROUND (122.72)          AS amt_NoDecimal           -- Round to nearest whole number
     , ROUND (122.72, 1)       AS amt_OneDecimal          -- Round to nearest one decimal place
     , ROUND (122.72, -1)      AS amt_OnesPlace           -- Round to nearest one's place
     
     , CEILING (122.72)        AS amt_Ceil_NoDecimal      -- Round to higher side whole number
     , FLOOR   (122.72)        AS amt_Floor_NoDecimal     -- Round to lower side whole number


-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E. Conditional Functions

-- COMMAND ----------

-- DBTITLE 1,Applying if-else conditions
SELECT

	-- Single condition

      RateCodeId      
    , IFF (RateCodeId = 6, 'SharedTrip', 'SoloTrip')       AS TripType
    
	
	-- Multiple conditions
	
    , PaymentType    
    , CASE PaymentType
            WHEN 1 THEN 'Credit Card'
            WHEN 2 THEN 'Cash'
            WHEN 3 THEN 'No Charge'
            WHEN 4 THEN 'Dispute'
            WHEN 6 THEN 'Voided Trip'
            ELSE        'Unknown'
      END                                                  AS PaymentTypeName
    
FROM TaxiRides
ORDER BY RideId
LIMIT 100;


-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### F. Null Functions

-- COMMAND ----------

-- DBTITLE 1,Perform null-check and null replace
SELECT C1
    
     , ISNULL (C1)                      -- Check if column value is null
                                        -- ISNOTNULL is inverse of this function
     
     , IFNULL (C1, -1)                  -- Replace null value with -1
    
FROM
(
    VALUES      (100,   200,  300),
                (NULL,  200,  300),
                (NULL, NULL, NULL)
    
) Dataset (C1, C2, C3)


-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### G. String Functions

-- COMMAND ----------

-- DBTITLE 1,Manipulate strings
SELECT
       Name
     , LOWER(Name)                          AS CabOwner     		          -- Convert to lower case
                                                                          -- Use UPPER to convert to upper case
     
     , REPLACE(CabOwner, ' and ', ' & ')    AS CabOwnerUpdatedName        -- Replace ' and ' with ' & '     
     
     -- If address field is more than 30 characters, truncate the field	 
     , IFF (
                LEN(Address) <= 30

                    , Address

                    , CONCAT (
                                SUBSTR (Address, 0, 27),
                                '...' 
                             )
                             
           ) AS TruncatedAddressName
        
FROM Cabs

WHERE Name LIKE '% AND %'           --    CONTAINS   (Name, 'ABC')  =>  LIKE '%ABC%'
                                    --    STARTSWITH (Name, 'ABC')  =>  LIKE 'ABC%'
                                    --    ENDSWITH   (Name, 'ABC')  =>  LIKE '%ABC'
LIMIT 100;






-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### H. Aggregate Functions

-- COMMAND ----------

-- DBTITLE 1,Aggregate data
SELECT 
        DATE_PART('YEAR', CURRENT_DATE()) - c.vehicleYear AS CurrentVehicleAge

        , COUNT(1) AS TotalVehicles                                         -- Other aggregate functions: MIN, MAX, SUM, AVG, etc.

FROM Cabs c

WHERE c.active = 'YES'

GROUP BY CurrentVehicleAge

ORDER BY CurrentVehicleAge
