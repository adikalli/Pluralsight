-- Check ride count for current date
-- If taxi rides table has not loaded data for current date, raise an alert

SELECT COUNT(1) AS RideCount

FROM taxicatalog.bronze.TaxiRides

WHERE TO_DATE(PickupTime) = CURRENT_DATE()