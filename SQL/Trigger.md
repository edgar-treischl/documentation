```
-- !preview

CREATE OR REPLACE FUNCTION notify_table_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('dataset_update',
    json_build_object(
      'table', 'test',  -- Table name
      'id', NEW.id,     -- Add data fields from the updated row
      'val', NEW.val,   -- Adjust this based on your actual table's columns
      'timestamp', NEW.timestamp
    )::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if needed
DROP TRIGGER IF EXISTS after_test_update ON test;

-- Create a new trigger that calls the function after an update
CREATE TRIGGER after_test_update
AFTER UPDATE ON test
FOR EACH ROW
EXECUTE FUNCTION notify_table_change();






#Tested, older

CREATE OR REPLACE FUNCTION notify_table_change()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('dataset_update', 'Table test changed');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS after_test_update ON test;

CREATE TRIGGER after_test_update
AFTER UPDATE ON test
FOR EACH ROW
EXECUTE FUNCTION notify_table_change();

```
