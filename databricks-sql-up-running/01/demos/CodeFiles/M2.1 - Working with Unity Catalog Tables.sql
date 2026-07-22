-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### A. Set Catalog and Schema

-- COMMAND ----------

-- DBTITLE 1,Use statements to set catalog and schema
USE CATALOG taxicatalog;

USE SCHEMA bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B. Options to Create Tables in Unity Catalog

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B.1 Create table using CTAS
-- MAGIC
-- MAGIC CTAS -> Create Table As Select

-- COMMAND ----------

-- DBTITLE 1,Create TaxiZones using CTAS
CREATE TABLE IF NOT EXISTS TaxiZones
AS

SELECT * 

FROM read_files(
                    '/Volumes/taxicatalog/bronze/raw/TaxiZones.csv',
                    
                    format => 'csv',
                    
                    header => true,

                    schemaEvolutionMode => 'none'
               );

-- COMMAND ----------

-- DBTITLE 1,Query the table
SELECT *
FROM TaxiZones;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B.2 Use DDL command - CREATE TABLE

-- COMMAND ----------

-- DBTITLE 1,Create TaxiRides using Create Table command
CREATE TABLE TaxiRides
(
    RideId                  INT               COMMENT 'This is the primary key column',
    VendorId                INT,

    PickupTime              TIMESTAMP,
    DropTime                TIMESTAMP,

    PickupLocationId        INT,
    DropLocationId          INT,

    CabNumber               STRING,
    DriverLicenseNumber     STRING,

    PassengerCount          INT,

    TripDistance            DOUBLE,
    RatecodeId              INT,

    PaymentType             INT,

    TotalAmount             DOUBLE,
    FareAmount              DOUBLE,
    Extra                   DOUBLE,
    MtaTax                  DOUBLE,
    TipAmount               DOUBLE,

    TollsAmount             DOUBLE,         
    ImprovementSurcharge    DOUBLE
)

USING DELTA                                                             -- default in Databricks is Delta

-- LOCATION "/Volumes/taxicatalog/bronze/raw/Output/TaxiRides.delta"    -- Without location, it will become a managed table

COMMENT 'This table stores ride information';


-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C. Options to Insert Data in Unity Catalog Table

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C.1 Use DML command - INSERT

-- COMMAND ----------

-- DBTITLE 1,Insert into TaxiRides table
INSERT INTO TaxiRides

(RideId, VendorId, PickupTime, DropTime, PickupLocationId, DropLocationId, CabNumber, DriverLicenseNumber, PassengerCount, TripDistance, RateCodeId, PaymentType, TotalAmount, FareAmount, Extra, MtaTax, TipAmount, TollsAmount, ImprovementSurcharge)

VALUES 
(2000000, 3, '2026-05-01T00:00:00.000Z', '2026-05-01T00:15:34.000Z', 170, 140, 'TAC399', '5131685', 1, 2.9, 1, 1, 15.3, 13.0, 0.5, 0.5, 1.0, 0.0, 0.3);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### C.2 Use COPY command

-- COMMAND ----------

-- DBTITLE 1,Copy into TaxiRides table
COPY INTO TaxiRides

FROM (
        SELECT RideId::Int
        
             , VendorId::Int , PickupTime::Timestamp, DropTime::Timestamp, PickupLocationId::Int, DropLocationId::Int
             , CabNumber::String, DriverLicenseNumber::String, PassengerCount::Int, TripDistance::Double
             , RateCodeId::Int, PaymentType::Int, TotalAmount::Double, FareAmount::Double, Extra::Double
             , MtaTax::Double, TipAmount::Double, TollsAmount::Double, ImprovementSurcharge::Double
             
        FROM '/Volumes/taxicatalog/bronze/raw/TaxiRides.csv'         
    )    
    
    FILEFORMAT = CSV                                    -- Other options: JSON, PARQUET, AVRO, ORC, TEXT, BINARYFILE    

    FORMAT_OPTIONS ('header' = 'true');                 -- Several format options are available
                                                        -- Generic and specific to file format

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D. Options to Check Metadata

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D.1 Use SHOW command
-- MAGIC
-- MAGIC To check list of database objects

-- COMMAND ----------

-- DBTITLE 1,Show list of tables
SHOW TABLES IN taxicatalog.bronze

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D.2 Use DESCRIBE TABLE command
-- MAGIC
-- MAGIC To check table properties

-- COMMAND ----------

-- DBTITLE 1,Describe detailed properties of table
DESCRIBE TABLE EXTENDED TaxiRides

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### D.3 Use DESCRIBE HISTORY command
-- MAGIC
-- MAGIC To check audit log of Delta tables

-- COMMAND ----------

-- DBTITLE 1,Check audit/transaction log
DESCRIBE HISTORY TaxiRides

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E. Create Other Tables

-- COMMAND ----------

-- DBTITLE 1,Define tables
-- Create table: Cabs
CREATE TABLE IF NOT EXISTS Cabs
(
    CabNumber               STRING,
    VehicleLicenseNumber    STRING,
    Name                    STRING,
    LicenseType             STRING,
    Active                  STRING,
    PermitLicenseNumber     STRING,
    VehicleVinNumber        STRING,
    VehicleYear             INT,
    VehicleType             STRING,
    TelephoneNumber         STRING,
    Website                 STRING,
    Address                 STRING
)
USING DELTA;


-- Create table: Drivers
CREATE TABLE IF NOT EXISTS Drivers
(
    DriverLicenseNumber    STRING,
    Name                   STRING,
    Type                   STRING,
    ExpirationDate         STRING
)
USING DELTA;


-- Create table: RidesFeedback
CREATE TABLE IF NOT EXISTS RidesFeedback
(
    RideId              INT,
    PickupLocationId    INT,
    Rating              FLOAT,
    Feedback            STRING
)
USING DELTA;


-- Create table: Customers
CREATE TABLE IF NOT EXISTS Customers 
(
    CustomerId          INT,
    CustomerName        STRING,
    Passport            STRING,
    CreditCard          STRING,
    City                STRING,
    SalesPerson         STRING
)
USING DELTA;

-- COMMAND ----------

-- DBTITLE 1,Copy data into tables
-- Copy data: Cabs
COPY INTO Cabs
FROM (
        SELECT 
            CabNumber::String,
            VehicleLicenseNumber::String,
            Name::String,
            LicenseType::String,
            Active::String,
            PermitLicenseNumber::String,
            VehicleVinNumber::String,
            VehicleYear::Int,
            VehicleType::String,
            TelephoneNumber::String,
            Website::String,
            Address::String
        FROM '/Volumes/taxicatalog/bronze/raw/Cabs.csv'
     )
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true');


-- Copy data: Drivers
COPY INTO Drivers
FROM (
        SELECT 
            DriverLicenseNumber::String,
            Name::String,
            Type::String,
            ExpirationDate::String
        FROM '/Volumes/taxicatalog/bronze/raw/Drivers.csv'
     )
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true');


-- Copy data: RidesFeedback
COPY INTO RidesFeedback
FROM (
        SELECT 
            RideId::Int,
            PickupLocationId::Int,
            Rating::Float,
            Feedback::String
        FROM '/Volumes/taxicatalog/bronze/raw/RidesFeedback.csv'
     )
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true');


-- Copy data: Customers
COPY INTO Customers
FROM (
        SELECT 
            CustomerId::Int,
            CustomerName::String,
            Passport::String,
            CreditCard::String,
            City::String,
            SalesPerson::String
        FROM '/Volumes/taxicatalog/bronze/raw/Customers.csv'
     )
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true');