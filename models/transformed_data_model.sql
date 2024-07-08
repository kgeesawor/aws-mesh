MODEL (
    name transformed_data_model,
    kind FULL,
    cron '@daily',
    grain [id]
);

SELECT 
    id,
    name,
    value,
    CASE 
        WHEN value > 50 THEN 'High'
        WHEN value > 25 THEN 'Medium'
        ELSE 'Low'
    END AS value_category
FROM raw_data_model;

-- Audits
CREATE OR REPLACE TABLE transformed_data_model_audit AS (
    -- Check for null values
    SELECT 'Null values found' AS issue, COUNT(*) AS count
    FROM transformed_data_model
    WHERE id IS NULL OR name IS NULL OR value IS NULL OR value_category IS NULL

    UNION ALL

    -- Check value categories
    SELECT 'Invalid value categories' AS issue, COUNT(*) AS count
    FROM transformed_data_model
    WHERE value_category NOT IN ('Low', 'Medium', 'High')

    UNION ALL

    -- Check value category consistency
    SELECT 'Inconsistent value categories' AS issue, COUNT(*) AS count
    FROM transformed_data_model
    WHERE (value > 50 AND value_category != 'High')
       OR (value > 25 AND value <= 50 AND value_category != 'Medium')
       OR (value <= 25 AND value_category != 'Low')
);