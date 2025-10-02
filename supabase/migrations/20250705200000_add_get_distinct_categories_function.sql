-- migration.sql
CREATE OR REPLACE FUNCTION get_distinct_categories()
RETURNS TABLE(category text) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT s.category
  FROM skills s
  WHERE s.category IS NOT NULL AND s.category != '';
END;
$$ LANGUAGE plpgsql; 