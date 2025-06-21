# Activity

# User Activity and Support System Analysis


This project analyzes user activity data, session logs, feature usage, and support ticket data to derive meaningful insights about user behavior and system performance.

## Problem Statement

The goal of this analysis is to:
1. Clean and prepare raw user activity data for analysis
2. Identify patterns in user engagement and session durations
3. Analyze feature adoption and usage trends
4. Examine support ticket resolution efficiency
5. Discover relationships between user activity and support needs

## Data Overview

The analysis works with four main tables:
1. `activity_log` - Records of user activities with timestamps
2. `sessions` - User login/logout sessions with durations
3. `feature_usage` - Tracking of which features users engage with
4. `support_tickets` - Records of user support requests and resolutions

## Key Insights

### 1. Session Duration Analysis
- Identified users with longest session durations each day
- Calculated average session durations by user
- Found users with high session counts but low feature usage

### 2. Feature Usage Trends
- Discovered top 3 most used features in last 30 days
- Identified users with high feature adoption (>3 features)
- Analyzed correlation between session duration and feature usage

### 3. Support System Performance
- Calculated average ticket resolution time
- Identified users with quickest resolutions (<2 days average)
- Found active users who never submitted support tickets

### 4. Activity Patterns
- Determined days with highest user activity
- Analyzed 60-day activity trends
- Identified inactive users (no login in 2 months)

## Data Cleaning Process

The analysis began with comprehensive data cleaning:
1. Removed duplicate activity records
2. Handled missing values in activity types
3. Standardized datetime formats
4. Filtered out-of-range dates
5. Verified correct data types

## Recommendations

Based on the analysis:
1. **For Engaged Users**: Implement advanced feature tutorials for power users with long sessions but low feature usage
2. **Support Optimization**: Investigate why some active users never submit tickets - may indicate hidden issues
3. **Feature Development**: Focus resources on the most popular features identified in the top 3 analysis
4. **Re-engagement**: Create campaigns targeting users who haven't logged in for 2 months



## Conclusion

This analysis provides a comprehensive view of user engagement patterns, feature popularity, and support system effectiveness. The insights can drive product development decisions, customer support improvements, and targeted user engagement strategies.

