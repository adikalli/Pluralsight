-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### A. Set Catalog and Schema

-- COMMAND ----------

-- DBTITLE 1,Use statements to set catalog and schema
USE CATALOG taxicatalog;

USE SCHEMA bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B. Check User and Account Functions

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B.1 Check user running the session or connected to Databricks

-- COMMAND ----------

-- DBTITLE 1,Check session user
SELECT session_user()

-- COMMAND ----------

-- MAGIC %md
-- MAGIC #### B.2 Check if connected user is a direct or indirect member of the specified group at the account level

-- COMMAND ----------

-- DBTITLE 1,Check user's account membership
SELECT is_account_group_member('finance')

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C. Analyze Table Data

-- COMMAND ----------

-- DBTITLE 1,Query customers table
SELECT * FROM Customers

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D. Dynamic Views

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D.1 Implement row-level security
-- MAGIC
-- MAGIC Use dynamic views with user/account functions

-- COMMAND ----------

-- DBTITLE 1,Create view for RLS
CREATE VIEW Customers_RowLevelSecurity
AS

    SELECT  *
    FROM Customers

    WHERE SalesPerson = session_user()

-- COMMAND ----------

-- DBTITLE 1,Query RLS view
SELECT * FROM Customers_RowLevelSecurity

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D.2 Implement column masking
-- MAGIC
-- MAGIC Use dynamic views with user/account functions

-- COMMAND ----------

-- DBTITLE 1,Create and query view for column masking
CREATE VIEW Customers_ColumnLevelSecurity
AS

    SELECT CustomerId, CustomerName, Passport, City, SalesPerson,
    
            CASE
                    WHEN is_account_group_member('finance')
                        THEN CreditCard
                    
                    ELSE
                        '** REDACTED **'

            END AS CreditCard
    
    FROM Customers;

-- Query view with column masking
SELECT * FROM Customers_ColumnLevelSecurity;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E. Table-level Filters

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E.1 Apply row-level filter on table
-- MAGIC
-- MAGIC Use table-level filters with user/account functions

-- COMMAND ----------

-- DBTITLE 1,Create function and apply row filter to table
-- Create function to filter rows based on SalesPerson

CREATE FUNCTION SalesPersonFilter(Name STRING)

    RETURNS BOOLEAN

    RETURN Name = session_user();


-- Set row filter
ALTER TABLE Customers 
    SET ROW FILTER SalesPersonFilter ON (SalesPerson);


-- Query table
SELECT * FROM Customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E.2 Apply column mask on table's column
-- MAGIC
-- MAGIC Use table-level masks with user/account functions

-- COMMAND ----------

-- DBTITLE 1,Create function and apply column mask to a column
-- Create function to apply mask to Credit Card column

CREATE FUNCTION CreditCardMask(CreditCard STRING)

    RETURN CASE 

                  WHEN is_account_group_member('finance')
                      THEN CreditCard
                  ELSE '** REDACTED **'

          END;


-- Set column mask
ALTER TABLE Customers 
      ALTER COLUMN CreditCard SET MASK CreditCardMask;
      

-- Query table
SELECT * FROM Customers;

-- COMMAND ----------

