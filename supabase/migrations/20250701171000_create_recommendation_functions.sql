-- Create functions for the recommendation system

-- Function to get trending skills based on recent views and likes
CREATE OR REPLACE FUNCTION get_trending_skills(days_ago INT DEFAULT 7, limit_count INT DEFAULT 20)
RETURNS SETOF skills
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT s.*
  FROM skills s
  LEFT JOIN (
    -- Count views in the last N days
    SELECT skill_id, COUNT(*) as recent_views
    FROM views
    WHERE viewed_at > (NOW() - (days_ago || ' days')::INTERVAL)
    GROUP BY skill_id
  ) rv ON s.id = rv.skill_id
  LEFT JOIN (
    -- Count likes in the last N days
    SELECT skill_id, COUNT(*) as recent_likes
    FROM likes
    WHERE liked_at > (NOW() - (days_ago || ' days')::INTERVAL)
    GROUP BY skill_id
  ) rl ON s.id = rl.skill_id
  -- Calculate trending score: 1 * views + 3 * likes
  ORDER BY (COALESCE(rv.recent_views, 0) + (COALESCE(rl.recent_likes, 0) * 3)) DESC
  LIMIT limit_count;
END;
$$;

-- Function to get popular topics with engagement metrics
CREATE OR REPLACE FUNCTION get_popular_topics(limit_count INT DEFAULT 10)
RETURNS TABLE(
  category TEXT,
  count BIGINT,
  engagement_score FLOAT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.category,
    COUNT(s.id) as count,
    -- Engagement score: average of (likes / views) ratio, scaled to 0-100
    COALESCE(AVG(CASE WHEN s.view_count > 0 THEN (s.like_count::float / s.view_count) * 100 ELSE 0 END), 0) as engagement_score
  FROM skills s
  WHERE s.category IS NOT NULL
  GROUP BY s.category
  -- Order by a combination of content count and engagement
  ORDER BY (COUNT(s.id) * 0.7 + COALESCE(AVG(CASE WHEN s.view_count > 0 THEN (s.like_count::float / s.view_count) * 100 ELSE 0 END), 0) * 0.3) DESC
  LIMIT limit_count;
END;
$$;

-- Function to get recommended creators based on user interests
CREATE OR REPLACE FUNCTION get_recommended_creators(user_id_param UUID, limit_count INT DEFAULT 5)
RETURNS SETOF profiles
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_interests TEXT[];
BEGIN
  -- Get user interests
  SELECT ARRAY_AGG(category) INTO user_interests
  FROM user_interests
  WHERE user_id = user_id_param;
  
  -- If no interests, return top creators by followers
  IF user_interests IS NULL OR array_length(user_interests, 1) IS NULL THEN
    RETURN QUERY
    SELECT p.*
    FROM profiles p
    LEFT JOIN (
      SELECT followed_id, COUNT(*) as follower_count
      FROM follows
      GROUP BY followed_id
    ) f ON p.id = f.followed_id
    WHERE p.id != user_id_param
    ORDER BY COALESCE(f.follower_count, 0) DESC
    LIMIT limit_count;
  ELSE
    -- Return creators who create content in user's interest categories
    RETURN QUERY
    SELECT DISTINCT p.*
    FROM profiles p
    JOIN skills s ON p.id = s.creator_id
    LEFT JOIN (
      SELECT followed_id, COUNT(*) as follower_count
      FROM follows
      GROUP BY followed_id
    ) f ON p.id = f.followed_id
    WHERE p.id != user_id_param
    AND s.category = ANY(user_interests)
    -- Not already following
    AND NOT EXISTS (
      SELECT 1 FROM follows
      WHERE follower_id = user_id_param AND followed_id = p.id
    )
    ORDER BY COALESCE(f.follower_count, 0) DESC
    LIMIT limit_count;
  END IF;
END;
$$;

-- Function to get personalized recommendations based on user interests and watch history
CREATE OR REPLACE FUNCTION get_personalized_recommendations(user_id_param UUID, limit_count INT DEFAULT 20)
RETURNS SETOF skills
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_interests TEXT[];
  watched_skills UUID[];
BEGIN
  -- Get user interests
  SELECT ARRAY_AGG(category) INTO user_interests
  FROM user_interests
  WHERE user_id = user_id_param;
  
  -- Get skills already watched
  SELECT ARRAY_AGG(skill_id) INTO watched_skills
  FROM views
  WHERE user_id = user_id_param;
  
  -- If no interests, return popular content not yet watched
  IF user_interests IS NULL OR array_length(user_interests, 1) IS NULL THEN
    RETURN QUERY
    SELECT s.*
    FROM skills s
    WHERE (watched_skills IS NULL OR s.id != ALL(watched_skills))
    ORDER BY s.view_count DESC
    LIMIT limit_count;
  ELSE
    -- Return content matching interests that hasn't been watched yet
    RETURN QUERY
    SELECT s.*
    FROM skills s
    WHERE s.category = ANY(user_interests)
    AND (watched_skills IS NULL OR s.id != ALL(watched_skills))
    ORDER BY s.created_at DESC
    LIMIT limit_count;
  END IF;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION get_trending_skills(INT, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_popular_topics(INT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_recommended_creators(UUID, INT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_personalized_recommendations(UUID, INT) TO authenticated; 