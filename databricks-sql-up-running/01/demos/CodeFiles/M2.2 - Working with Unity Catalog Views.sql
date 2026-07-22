-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### A. Set Catalog and Schema

-- COMMAND ----------

-- DBTITLE 1,Use statements to set catalog and schema
USE CATALOG taxicatalog;

USE SCHEMA bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B. Standard Views in Unity Catalog

-- COMMAND ----------

-- DBTITLE 1,Create view
CREATE OR REPLACE VIEW BronxRides
AS

    SELECT tr.RideId,
           tr.VendorId,
           tr.PickupTime,
           tr.DropTime,

           DATEDIFF(MINUTE, tr.PickupTime, tr.DropTime)  AS TripTimeInMinutes,
          
           tr.TripDistance,
           tr.TotalAmount,
            
           tz.Zone            AS PickupZone,
           tz.service_zone    AS PickupServiceZone

    FROM TaxiRides tr
        
        JOIN TaxiZones tz     ON tr.PickupLocationId = tz.LocationID

    WHERE tz.Borough = 'Bronx'

-- COMMAND ----------

-- DBTITLE 1,Query the view
SELECT * FROM BronxRides

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C. Metric Views in Unity Catalog

-- COMMAND ----------

-- DBTITLE 1,Query metric view
-- Calculate average trip time by Vendor and Pickup Location

SELECT 
       -- Select fields/dimensions
       VendorId
     , PickupLocationId

     , ROUND (
                -- Select measure
                MEASURE ( `Average Trip Time` ),      -- Wrap up measure name in MEASURE function
                
                2
             ) AS AverageTripTime

FROM taxicatalog.bronze.RidesMetricView

GROUP BY ALL                                          -- Group by VendorId and PickupLocationId


-- COMMAND ----------

