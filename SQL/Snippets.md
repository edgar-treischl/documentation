Store XML in Postgres

```sql
CREATE TABLE lss_surveys (
    id SERIAL PRIMARY KEY,        -- Unique identifier for the record
    file_id VARCHAR(255) UNIQUE,  -- The file ID (which will be the name of the .lss file)
    master VARCHAR(255),    -- Survey title extracted from the .lss file
    survey_data XML               -- The XML content of the .lss file
);

```

To run a minimal example in R, see [[R/Snippets|Snippets]]
