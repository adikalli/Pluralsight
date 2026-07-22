-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### A. Set Catalog and Schema

-- COMMAND ----------

-- DBTITLE 1,Use statements to set catalog and schema
USE CATALOG taxicatalog;

USE SCHEMA bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B. Run Standard SQL Query

-- COMMAND ----------

-- DBTITLE 1,Query TaxiRides and TaxiZones
SELECT tr.RideId
          , tr.VendorId
          , tr.PickupTime
          , tr.DropTime

          , DATEDIFF(MINUTE, tr.PickupTime, tr.DropTime)  AS TripTimeInMinutes
          
          , tr.TripDistance
          , tr.TotalAmount
            
          , tz.Zone            AS PickupZone
          , tz.service_zone    AS PickupServiceZone

    FROM TaxiRides tr
        
        JOIN TaxiZones tz     ON tr.PickupLocationId = tz.LocationID