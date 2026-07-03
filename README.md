# YouTube India Publisher Strategy Analysis

## Project Overview
This project focuses on analyzing a dataset of over 16,000 historical YouTube records from top channels in India (`IN_Trending.csv`(Downloaded from kaggle)). Using **Snowflake SQL**, the data was cleaned, structured, and queried to understand how major Indian media networks schedule their content, optimize their titles, and engage their audiences.

---

## Key Project Steps

### 1. Grouping & Aggregations
*   **Channel Reach:** Grouped the data by channel titles to rank the top media networks by total views, likes, and content volume.
*   **Audience Engagement Rates:** Calculated engagement ratios (likes-to-views) using safe division filters to identify channels with the most active fanbases.
*   **Day of the Week Trends:** Analyzed video upload timestamps against week days to see which publishing days accumulate the highest average view counts.

### 2. Advanced Strategic Insights
*   **Category Performance & Modern Market Share:** Mapped video category IDs to real-world genres (Music, Gaming, Entertainment, etc.) and utilized SQL window functions to calculate the exact market share of viewer attention captured during the modern era (2025–2026).
*   **Title Capitalization ("Clickbait") Impact:** Used regular expression counters (`REGEXP_COUNT`) to measure the ratio of uppercase lettering in video titles to study how aggressive title text patterns correlate with average views.
*   **Channel Longevity & View Velocity:** Parsed the operational timeline of networks using date differentials (`DATEDIFF`) to separate long-term legacy channels from high-velocity creators based on their annual view generation speed.

---

## Repository Files
*   `youtube_analysis_queries.sql`: The single script containing all the data cleaning setups and analytical queries performed on the data.

## Technologies Used
*   **Database Platform:** Snowflake Cloud Data Platform
*   **Language:** SQL
