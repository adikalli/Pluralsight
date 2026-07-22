-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### A. Set Catalog and Schema

-- COMMAND ----------

-- DBTITLE 1,Use statements to set catalog and schema
USE CATALOG taxicatalog;

USE SCHEMA bronze;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### B. Check Table Data

-- COMMAND ----------

-- DBTITLE 1,Query feedback table
SELECT *
FROM RidesFeedback

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### C. AI Function: Translate Data

-- COMMAND ----------

-- DBTITLE 1,ai_translate
SELECT Feedback

     , ai_translate ( Feedback, 'en' )   AS Translation         -- Languages: en, fr, de, hi, it, pt, es, etc.

FROM RidesFeedback
WHERE RideId = 1

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### D. AI Function: Fix Grammar

-- COMMAND ----------

-- DBTITLE 1,ai_fix_grammar
SELECT Feedback

     , ai_fix_grammar ( Feedback )   AS CorrectedGrammar

FROM RidesFeedback
WHERE RideId = 2

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### E. AI Function: Summarize Data

-- COMMAND ----------

-- DBTITLE 1,ai_summarize
SELECT Feedback

     , ai_summarize ( Feedback )   AS Summarized        -- Optionally, max words can be passed to limit the output

FROM RidesFeedback
WHERE RideId = 3

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### F. AI Function: Mask Data

-- COMMAND ----------

-- DBTITLE 1,ai_mask
SELECT Feedback

     , ai_mask ( Feedback,
     
                 array('person', 'email', 'phone') )   AS Masked

FROM RidesFeedback
WHERE RideId = 4

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### G. AI Function: Classify Data

-- COMMAND ----------

-- DBTITLE 1,ai_classify
SELECT Feedback

     , ai_classify ( Feedback,
     
                     '["urgent", "not_urgent"]' )   AS Classification

FROM RidesFeedback
WHERE RideId = 5

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### H. AI Function: Analyze Sentiment

-- COMMAND ----------

-- DBTITLE 1,ai_analyze_sentiment
SELECT Feedback

     , ai_analyze_sentiment ( Feedback )   AS Summarized         -- Return values: positive, negative, neutral, mixed

FROM RidesFeedback
WHERE RideId = 6

-- COMMAND ----------

