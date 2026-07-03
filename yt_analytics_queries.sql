SELECT 
    channel_title,
    COUNT(video_id) AS total_trending_videos,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes
FROM clean_v1_yt_trending
GROUP BY channel_title
ORDER BY total_views DESC
LIMIT 10;


SELECT 
    channel_title,
    COUNT(video_id) AS total_trending_videos,
    SUM(views) AS total_views,
    SUM(likes) AS total_likes,
    -- Calculate engagement percentage: (Total Likes / Total Views) * 100
    ROUND((SUM(likes) / NULLIF(SUM(views), 0)) * 100, 2) AS engagement_rate_percentage
FROM clean_v1_yt_trending
GROUP BY channel_title
HAVING COUNT(video_id) >= 3  -- Filter out one-hit wonders
ORDER BY engagement_rate_percentage DESC
LIMIT 10;


SELECT 
    DAYNAME(published_date) AS day_of_week,
    COUNT(video_id) AS total_videos_published,
    ROUND(AVG(views), 0) AS average_views_per_video
FROM clean_v1_yt_trending
GROUP BY day_of_week
ORDER BY total_videos_published DESC;


SELECT 
    CASE 
        WHEN category_id = 10 THEN 'Music'
        WHEN category_id = 20 THEN 'Gaming'
        WHEN category_id = 24 THEN 'Entertainment'
        WHEN category_id = 22 THEN 'People & Blogs'
        WHEN category_id = 23 THEN 'Comedy'
        ELSE 'Other Categories'
    END AS category_name,
    COUNT(video_id) AS total_trending_videos,
    ROUND(AVG(views), 0) AS average_views,
    ROUND(AVG(likes), 0) AS average_likes
FROM clean_v1_yt_trending
GROUP BY category_name
ORDER BY total_trending_videos DESC;


WITH modern_data AS (
    SELECT 
        views,
        likes,
        CASE 
            WHEN category_id = 10 THEN 'Music'
            WHEN category_id = 20 THEN 'Gaming'
            WHEN category_id = 24 THEN 'Entertainment'
            WHEN category_id = 22 THEN 'People & Blogs'
            WHEN category_id = 23 THEN 'Comedy'
            ELSE 'Other/Regional Content'
        END AS category_name
    FROM YTIN_data
    -- Isolate the modern streaming era
    WHERE EXTRACT(YEAR FROM TO_TIMESTAMP_NTZ(publish_time)) >= 2025
)
SELECT 
    category_name,
    COUNT(*) AS video_count,
    SUM(views) AS total_views,
    -- Find the market share percentage of total platform views
    ROUND((SUM(views) / SUM(SUM(views)) OVER ()) * 100, 2) AS view_market_share_percentage
FROM modern_data
GROUP BY category_name
ORDER BY total_views DESC;


WITH caps_calc AS (
    SELECT 
        views,
        title,
        -- Count only alphabetic characters
        REGEXP_COUNT(title, '[A-Za-z]') AS total_letters,
        -- Count only uppercase alphabetic characters
        REGEXP_COUNT(title, '[A-Z]') AS uppercase_letters
    FROM YTIN_DATA
),
caps_ratio_buckets AS (
    SELECT 
        views,
        CASE 
            WHEN total_letters = 0 THEN '01. No Text'
            WHEN (uppercase_letters / total_letters) <= 0.10 THEN '02. Low Caps (<10%)'
            WHEN (uppercase_letters / total_letters) BETWEEN 0.11 AND 0.40 THEN '03. Medium Caps (11-40%)'
            WHEN (uppercase_letters / total_letters) BETWEEN 0.41 AND 0.80 THEN '04. High Caps (41-80%)'
            ELSE '05. Intense ALL CAPS (>80%)'
        END AS capitalization_strategy
    FROM caps_calc
)
SELECT 
    capitalization_strategy,
    COUNT(*) AS total_videos,
    ROUND(AVG(views), 0) AS average_views
FROM caps_ratio_buckets
GROUP BY capitalization_strategy
ORDER BY capitalization_strategy ASC;


WITH channel_lifespan AS (
    SELECT 
        channel_title,
        MIN(TO_DATE(publish_time)) AS first_upload,
        MAX(TO_DATE(publish_time)) AS latest_upload,
        COUNT(video_id) AS total_videos,
        SUM(views) AS total_accumulated_views
    FROM YTIN_DATA
    GROUP BY channel_title
),
velocity_metrics AS (
    SELECT 
        channel_title,
        total_videos,
        total_accumulated_views,
        -- Calculate total days active and handle zero-day division safely
        NULLIF(DATEDIFF(day, first_upload, latest_upload), 0) AS days_active,
        -- Normalize active days into year fractions
        ROUND(days_active / 365.25, 2) AS years_active,
        -- Metric: Views generated per year of activity
        ROUND(total_accumulated_views / NULLIF(years_active, 0), 0) AS channel_view_velocity
    FROM channel_lifespan
)
SELECT 
    channel_title,
    years_active,
    total_videos,
    total_accumulated_views,
    channel_view_velocity
FROM velocity_metrics
WHERE total_videos >= 100 AND years_active > 0
ORDER BY channel_view_velocity DESC
LIMIT 10;