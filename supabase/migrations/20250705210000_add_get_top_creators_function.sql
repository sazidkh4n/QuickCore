-- migration.sql
CREATE OR REPLACE FUNCTION get_top_creators()
RETURNS SETOF profiles
LANGUAGE sql
AS $$
  SELECT p.*
  FROM profiles p
  LEFT JOIN (
    SELECT following_id, COUNT(*) as followers_count
    FROM user_follows
    GROUP BY following_id
  ) f ON p.id = f.following_id
  ORDER BY f.followers_count DESC NULLS LAST
  LIMIT 10;
$$; 