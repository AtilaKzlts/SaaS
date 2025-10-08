-- Orbit SaaS Mobile Analysis Queries - Amazon Athena Syntax
-- S3 Bucket: s3://orbit-saas-data/
-- Database: orbit_analytics

-- 1. Complaint topics by operating system for users coming from mobile
SELECT 
    cst.category,
    ge.operating_system,
    COUNT(*) as ticket_count
FROM 
    "orbit_analytics"."ga4_events" ge 
JOIN 
    "orbit_analytics"."crm_support_tickets" cst ON ge.user_id = cst.user_id 
WHERE 
    ge.device_category = 'Mobile'
GROUP BY 
    cst.category, 
    ge.operating_system
ORDER BY 
    cst.category;

---

-- 2. Complaint rates by platform
WITH platform_users AS (
    SELECT
        platform,
        COUNT(DISTINCT user_id) AS total_users
    FROM 
        "orbit_analytics"."ga4_events"
    WHERE 
        device_category = 'Mobile'
    GROUP BY 
        platform
),
mobile_support_tickets AS (
    SELECT
        ge.platform,
        cst.category,
        COUNT(*) AS ticket_count
    FROM 
        "orbit_analytics"."ga4_events" ge
    JOIN 
        "orbit_analytics"."crm_support_tickets" cst ON ge.user_id = cst.user_id
    WHERE 
        ge.device_category = 'Mobile'
    GROUP BY 
        ge.platform, cst.category
)
SELECT
    mst.platform,
    mst.category,
    mst.ticket_count,
    pu.total_users,
    ROUND(
        CAST(mst.ticket_count AS DOUBLE) / CAST(pu.total_users AS DOUBLE) * 100, 2
    ) AS complaint_rate_percentage
FROM 
    mobile_support_tickets mst
JOIN 
    platform_users pu ON mst.platform = pu.platform
ORDER BY 
    mst.platform, 
    complaint_rate_percentage DESC;

---

-- 3. Support request topics of churned mobile users
SELECT
    cst.category,
    COUNT(*) AS churned_user_ticket_count
FROM 
    "orbit_analytics"."users" u
JOIN 
    "orbit_analytics"."crm_support_tickets" cst ON u.user_id = cst.user_id
WHERE 
    u.is_churned = true
    AND u.user_id IN (
        SELECT DISTINCT user_id
        FROM "orbit_analytics"."ga4_events"
        WHERE device_category = 'Mobile'
    )
GROUP BY 
    cst.category
ORDER BY 
    churned_user_ticket_count DESC;

---

-- 4. Last actions of churned mobile users
WITH ChurnedMobileUsersLastEvent AS (
    SELECT 
        user_id,
        FIRST_VALUE(event_name) OVER (
            PARTITION BY user_id 
            ORDER BY event_date DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS last_event_before_churn
    FROM 
        "orbit_analytics"."ga4_events"
    WHERE 
        device_category = 'Mobile'
        AND user_id IN (
            SELECT DISTINCT user_id
            FROM "orbit_analytics"."users"
            WHERE is_churned = true
        )
)
SELECT
    last_event_before_churn,
    COUNT(DISTINCT user_id) AS churn_count
FROM 
    ChurnedMobileUsersLastEvent
GROUP BY 
    last_event_before_churn
ORDER BY 
    churn_count DESC
LIMIT 10;

---

-- 5. Mobile user churn trend analysis (monthly)
SELECT
    DATE_TRUNC('month', CAST(u.churn_date AS DATE)) AS churn_month,
    COUNT(u.user_id) AS churned_mobile_users
FROM
    "orbit_analytics"."users" u
WHERE
    u.is_churned = true
    AND u.user_id IN (
        SELECT DISTINCT user_id
        FROM "orbit_analytics"."ga4_events"
        WHERE device_category = 'Mobile'
    )
    AND u.churn_date IS NOT NULL
GROUP BY
    DATE_TRUNC('month', CAST(u.churn_date AS DATE))
ORDER BY
    churn_month;

---

-- 6. Mobile churn analysis by plan type
SELECT 
    cs.plan_type,
    COUNT(DISTINCT u.user_id) AS churned_mobile_users_count
FROM 
    "orbit_analytics"."ga4_events" ge 
JOIN 
    "orbit_analytics"."crm_subscriptions" cs ON ge.user_id = cs.user_id 
JOIN
    "orbit_analytics"."users" u ON cs.user_id = u.user_id
WHERE 
    ge.device_category = 'Mobile' 
    AND u.is_churned = true
GROUP BY 
    cs.plan_type
ORDER BY
    churned_mobile_users_count DESC;

---

-- 7. Mobile churn rates by plan type (improved)
WITH plan_totals AS (
    SELECT 
        cs.plan_type,
        COUNT(DISTINCT cs.user_id) as total_users
    FROM "orbit_analytics"."crm_subscriptions" cs
    JOIN "orbit_analytics"."ga4_events" ge ON cs.user_id = ge.user_id  
    WHERE ge.device_category = 'Mobile'
    GROUP BY cs.plan_type
),
plan_churn AS (
    SELECT 
        cs.plan_type,
        COUNT(DISTINCT u.user_id) AS churned_count
    FROM "orbit_analytics"."ga4_events" ge 
    JOIN "orbit_analytics"."crm_subscriptions" cs ON ge.user_id = cs.user_id 
    JOIN "orbit_analytics"."users" u ON cs.user_id = u.user_id
    WHERE ge.device_category = 'Mobile' 
    AND u.is_churned = true
    GROUP BY cs.plan_type
)
SELECT 
    pc.plan_type,
    pc.churned_count,
    pt.total_users,
    ROUND(
        CAST(pc.churned_count AS DOUBLE) / CAST(pt.total_users AS DOUBLE) * 100, 
        2
    ) AS churn_rate_percent
FROM plan_churn pc
JOIN plan_totals pt ON pc.plan_type = pt.plan_type
ORDER BY churn_rate_percent DESC;

---

-- 8. Mobile churn analysis by acquisition channel
SELECT
    u.acquisition_channel,
    COUNT(u.user_id) AS churned_mobile_users_count
FROM
    "orbit_analytics"."users" u
WHERE
    u.is_churned = true
    AND u.user_id IN (
        SELECT DISTINCT user_id
        FROM "orbit_analytics"."ga4_events"
        WHERE device_category = 'Mobile'
    )
GROUP BY
    u.acquisition_channel
ORDER BY
    churned_mobile_users_count DESC;

---

-- 9. Channel churn rates (improved)
WITH channel_totals AS (
    SELECT 
        u.acquisition_channel,
        COUNT(DISTINCT u.user_id) as total_users
    FROM "orbit_analytics"."users" u
    JOIN "orbit_analytics"."ga4_events" ge ON u.user_id = ge.user_id
    WHERE ge.device_category = 'Mobile'
    GROUP BY u.acquisition_channel
),
channel_churn AS (
    SELECT
        u.acquisition_channel,
        COUNT(u.user_id) AS churned_count
    FROM "orbit_analytics"."users" u
    WHERE u.is_churned = true
    AND u.user_id IN (
        SELECT DISTINCT user_id
        FROM "orbit_analytics"."ga4_events"
        WHERE device_category = 'Mobile'
    )
    GROUP BY u.acquisition_channel
)
SELECT 
    cc.acquisition_channel,
    cc.churned_count,
    ct.total_users,
    ROUND(
        CAST(cc.churned_count AS DOUBLE) / CAST(ct.total_users AS DOUBLE) * 100, 
        2
    ) AS churn_rate_percent
FROM channel_churn cc
JOIN channel_totals ct ON cc.acquisition_channel = ct.acquisition_channel
ORDER BY churn_rate_percent DESC;

---

-- 10. Mobile churn distribution by industries
SELECT
    u.industry,
    COUNT(DISTINCT u.user_id) AS churned_mobile_users_count,
    ROUND(
        CAST(COUNT(DISTINCT u.user_id) AS DOUBLE) * 100.0 / 
        SUM(COUNT(DISTINCT u.user_id)) OVER (),
        2
    ) AS percentage_of_total_mobile_churn
FROM
    "orbit_analytics"."users" u
JOIN
    "orbit_analytics"."ga4_events" ge ON u.user_id = ge.user_id
WHERE
    u.is_churned = true
    AND ge.device_category = 'Mobile'
GROUP BY
    u.industry
ORDER BY
    percentage_of_total_mobile_churn DESC;

---

-- 11. Industry churn rates (improved)
WITH industry_totals AS (
    SELECT 
        u.industry,
        COUNT(DISTINCT u.user_id) as total_mobile_users
    FROM "orbit_analytics"."users" u
    JOIN "orbit_analytics"."ga4_events" ge ON u.user_id = ge.user_id
    WHERE ge.device_category = 'Mobile'
    GROUP BY u.industry
),
industry_churn AS (
    SELECT
        u.industry,
        COUNT(DISTINCT u.user_id) AS churned_mobile_users_count
    FROM "orbit_analytics"."users" u
    JOIN "orbit_analytics"."ga4_events" ge ON u.user_id = ge.user_id
    WHERE u.is_churned = true
    AND ge.device_category = 'Mobile'
    GROUP BY u.industry
)
SELECT
    ic.industry,
    ic.churned_mobile_users_count,
    it.total_mobile_users,
    ROUND(
        CAST(ic.churned_mobile_users_count AS DOUBLE) / CAST(it.total_mobile_users AS DOUBLE) * 100, 
        2
    ) AS industry_churn_rate_percent,
    ROUND(
        CAST(ic.churned_mobile_users_count AS DOUBLE) * 100.0 / 
        SUM(ic.churned_mobile_users_count) OVER (),
        2
    ) AS percentage_of_total_mobile_churn
FROM industry_churn ic
JOIN industry_totals it ON ic.industry = it.industry
ORDER BY industry_churn_rate_percent DESC;

---

-- 12. Pages visited by churned users
SELECT
    regexp_extract(ge.event_params, 'page_location":\s*"([^"]+)"', 1) AS page_location,
    COUNT(DISTINCT ge.user_id) AS churned_user_count
FROM
    "orbit_analytics"."ga4_events" ge
JOIN
    "orbit_analytics"."users" u ON u.user_id = ge.user_id
WHERE
    u.is_churned = true
    AND ge.device_category = 'Mobile'
    AND ge.event_params LIKE '%page_location%'
GROUP BY
    regexp_extract(ge.event_params, 'page_location":\s*"([^"]+)"', 1)
ORDER BY
    churned_user_count DESC;

---

-- 13. Page churn rates (improved)
WITH page_totals AS (
    SELECT 
        regexp_extract(ge.event_params, 'page_location":\s*"([^"]+)"', 1) AS page_location,
        COUNT(DISTINCT ge.user_id) as total_visitors
    FROM "orbit_analytics"."ga4_events" ge
    WHERE ge.device_category = 'Mobile'
    AND ge.event_params LIKE '%page_location%'
    GROUP BY regexp_extract(ge.event_params, 'page_location":\s*"([^"]+)"', 1)
),
churned_pages AS (
    SELECT
        regexp_extract(ge.event_params, 'page_location":\s*"([^"]+)"', 1) AS page_location,
        COUNT(DISTINCT ge.user_id) AS churned_user_count
    FROM "orbit_analytics"."ga4_events" ge
    JOIN "orbit_analytics"."users" u ON u.user_id = ge.user_id
    WHERE u.is_churned = true
    AND ge.device_category = 'Mobile'
    AND ge.event_params LIKE '%page_location%'
    GROUP BY regexp_extract(ge.event_params, 'page_location":\s*"([^"]+)"', 1)
)
SELECT
    cp.page_location,
    cp.churned_user_count,
    pt.total_visitors,
    ROUND(
        CAST(cp.churned_user_count AS DOUBLE) / CAST(pt.total_visitors AS DOUBLE) * 100, 
        2
    ) AS page_churn_rate_percent
FROM churned_pages cp
JOIN page_totals pt ON cp.page_location = pt.page_location
ORDER BY page_churn_rate_percent DESC;

---

-- 14. Features used by churned users
SELECT
    regexp_extract(ge.event_params, 'feature_name":\s*"([^"]+)"', 1) AS feature_name,
    COUNT(DISTINCT ge.user_id) AS churned_user_count
FROM
    "orbit_analytics"."ga4_events" ge
JOIN
    "orbit_analytics"."users" u ON u.user_id = ge.user_id
WHERE
    u.is_churned = true
    AND ge.device_category = 'Mobile'
    AND ge.event_params LIKE '%feature_name%'
GROUP BY
    regexp_extract(ge.event_params, 'feature_name":\s*"([^"]+)"', 1)
ORDER BY
    churned_user_count DESC;

---

-- 15. Device/browser combination signup performance
SELECT 
    operating_system,
    browser,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT CASE WHEN event_name = 'signup' THEN user_id END) as signups,
    ROUND(
        CAST(COUNT(DISTINCT CASE WHEN event_name = 'signup' THEN user_id END) AS DOUBLE) * 100.0 /
        CAST(COUNT(DISTINCT user_id) AS DOUBLE), 2
    ) as signup_rate
FROM "orbit_analytics"."ga4_events"
WHERE device_category = 'Mobile'
GROUP BY operating_system, browser
HAVING COUNT(DISTINCT user_id) > 50
ORDER BY signup_rate ASC;

---

-- 16. Conversion funnel analysis
SELECT 
    platform,
    funnel_step,
    step_order,
    total_users,
    conversion_rate,
    LAG(total_users) OVER (PARTITION BY platform ORDER BY step_order) as previous_step,
    CASE 
        WHEN LAG(total_users) OVER (PARTITION BY platform ORDER BY step_order) > 0 
        THEN ROUND(
            CAST(total_users AS DOUBLE) * 100.0 / 
            CAST(LAG(total_users) OVER (PARTITION BY platform ORDER BY step_order) AS DOUBLE),
            2
        )
        ELSE NULL
    END as step_conversion_rate
FROM "orbit_analytics"."conversion_funnel"
WHERE platform IN ('Web', 'Mobile')
ORDER BY platform, step_order;

---

-- 17. Monthly performance trend analysis
SELECT 
    month,
    total_subscribers,
    mrr,
    churn_rate,
    growth_rate,
    LAG(total_subscribers) OVER (ORDER BY month) as prev_month_subscribers,
    CASE 
        WHEN LAG(total_subscribers) OVER (ORDER BY month) > 0 
        THEN ROUND(
            (CAST(total_subscribers AS DOUBLE) - CAST(LAG(total_subscribers) OVER (ORDER BY month) AS DOUBLE)) * 100.0 / 
            CAST(LAG(total_subscribers) OVER (ORDER BY month) AS DOUBLE), 2
        )
        ELSE NULL
    END as calculated_growth_rate
FROM "orbit_analytics"."general_performance"
ORDER BY month;
