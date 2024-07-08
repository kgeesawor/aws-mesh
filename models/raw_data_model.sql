MODEL (
    name raw_data_model,
    kind FULL,
    cron '@daily',
    grain [id]
);

SELECT * FROM read_csv_auto('seeds/raw_data.csv');

-- Audits
CREATE OR REPLACE TABLE raw_data_model_audit AS (
    -- Check for null values
    SELECT 'Null values found' AS issue, COUNT(*) AS count
    FROM raw_data_model
    WHERE id IS NULL OR name IS NULL OR value IS NULL

    UNION ALL

    -- Check for unique IDs
    SELECT 'Duplicate IDs found' AS issue, COUNT(*) AS count
    FROM (
        SELECT id, COUNT(*) as id_count
        FROM raw_data_model
        GROUP BY id
        HAVING COUNT(*) > 1
    ) duplicate_ids

    UNION ALL

    -- Check value range
    SELECT 'Values out of range' AS issue, COUNT(*) AS count
    FROM raw_data_model
    WHERE value < 0 OR value > 1000
);