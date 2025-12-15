
<div align="center">
  <h1>AWS End-to-End Data Analytics for SaaS

</h1>
 </p>
</div>

![image](https://github.com/AtilaKzlts/SaaS/blob/main/assets/SaaS-Diagram.png)

## ▌ Table of Contents

* Introduction
* Executive Summary
* Business Problems
* Technologies and Architecture
* Analysis & Key Findings
* Solution and Recommendations (Action Plan)
* Dashboard Snapshot
* Next Steps


## ▌ Introduction

**The Problem: Growth Pains and Critical Revenue Loss**
Following last year’s rapid growth, Orbit has slowed down over the last six months.
The most critical issue: mobile app conversion rates are disastrously low compared to the website.

**The Solution: A Continuous Growth Infrastructure, Not a One-Time Answer**
Instead of providing a one-off answer to the CEO’s question (“Why did we slow down?”), I built a system that allows us to continuously monitor the problem and track the root cause at all times.

**Project Goal: Uniting Data Silos for Continuity and Efficiency Savings**

* **Bridging the Data Silos:**
  Dispersed data (GA4, CRM/PG, ADS) was consolidated into a single central repository (Amazon S3 Data Lake).

* **Saving Manpower Through Automation:**
  This data flow was automated using Airbyte. The team no longer spends hours on data gathering; their time is dedicated to analysis and action.

* **The Result:**
  The Growth team can now analyze live data, not just the past, allowing for fast, data-driven decisions and instant identification of the real cause of the slowdown.

This infrastructure is the permanent solution to ensure the problem never recurs.



## ▌ Executive Summary
##### [Click for Detailed PDF > ](https://github.com/AtilaKzlts/SaaS/blob/main/assets/Orbit%20SaaS-Report.pdf)

| **Stage / Area**                | **Insight (Key Finding)**                                                                                                                                                                              | **Recommended Action**                                                                                                                                           |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Onboarding Experience**       | 48% of users leave the app within the first 2 minutes — mainly due to UX and technical inconsistencies between iOS and Android. This creates weak first impressions and lost conversion opportunities. | Redesign the mobile onboarding journey to deliver immediate value and consistent cross-platform experience. Highlight core product benefits earlier in the flow. |
| **Technical Stability**         | Android users generate **2× more support tickets** than iOS users, reflecting unstable builds and higher maintenance overhead.                                                                         | Strengthen QA processes on Android and unify technical architecture to reduce issue frequency and support costs.                                                 |
| **Sign-up Funnel**              | iOS Chrome users show a **6% signup rate**, indicating significant friction at the registration step.                                                                                                  | Fix Chrome compatibility issues and simplify the signup form to improve conversion. Target signup increase to **15%**.                                           |
| **Customer Retention**          | The basic plan shows **24% churn**, leading to an estimated **$45,000 annual revenue loss**. Around 50% of this loss is linked to solvable technical issues.                                           | Prioritize technical fixes to recover half of the lost revenue. Introduce retention incentives (e.g., loyalty credits or guided onboarding).                     |
| **Referral vs Direct Channels** | Referral channel churn is **34%**, higher than direct traffic (**26%**). Referred users seem less engaged after signup.                                                                                | Audit referral traffic quality and redesign referral incentives to attract higher-intent users. Continue strengthening direct acquisition channels.              |
| **Business Outcome Projection** | Resolving onboarding and technical pain points is expected to recover measurable revenue within 3–6 months and increase mobile conversion rates significantly.                                         | Implement the proposed roadmap with bi-weekly impact tracking to monitor churn and signup improvements.                                                          |
                                                                                                                                                                            



## ▌ Business Problems

The primary goal of this project was to provide data-driven solutions to the following critical business challenges faced by a SaaS company:

* **Low Conversion Rates**

  * Subscriber acquisition through the mobile application was significantly lower compared to the web platform.

* **Growth Slowdown**

  * The company’s overall growth rate had been declining over the past six months.

* **Data Silos**

  * Key data sources—user behavior (GA4), customer information (CRM), and advertising performance—were isolated in separate systems, limiting integrated analysis.

**Focus for Resolution**:
The solution required unifying fragmented data sources and identifying potential bottlenecks within the conversion funnel.


## ▌ Technologies and Architecture

The core architecture of this project was designed to consolidate fragmented data and make it ready for analysis. The main technologies used are:

* **Data Ingestion**

  * *Airbyte*: Used to automatically load data from GA4 and other sources into Amazon S3.

* **Data Warehouse**

  * *Amazon S3*: Served as a scalable data lake to store both raw and processed data.
  * ![image](https://github.com/AtilaKzlts/SaaS/blob/main/assets/Dataset_diagram.png)

* **Data Processing and Transformation (ETL)**

  * *AWS Glue*: Performed ETL (Extract, Transform, Load) operations to transform raw data in S3 into analysis-ready tables.
    
###### *A section of the pipeline*
* ![image](https://github.com/AtilaKzlts/SaaS/blob/main/assets/glue_job_diagram.png)

* **Monitoring & Alerting**
  * *Amazon CloudWatch*: Configured automated monitoring for:
    - ETL job success/failure tracking
    - S3 data freshness validation (24-hour data arrival monitoring)
    - AWS cost control alerts for budget management
  * *Amazon SNS*: Email notification system for pipeline alerts and data quality issues

* **Data Analysis**

  * *Amazon Athena*: Enabled direct analysis of data stored in S3 using SQL queries.  [> Click for Full SQL Script](https://github.com/AtilaKzlts/SaaS/blob/main/assets/SaaSql-Athena.sql)
###### *A query example*

 ```sql
-- Page churn rates 
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
```


* **Business Intelligence (Visualization)**

  * *QuickSight*: Used to visualize analysis results and create interactive dashboards.


## ▌ Detailed Insights


![image](https://github.com/AtilaKzlts/SaaS/blob/main/assets/Mobile%20Funneal.png)

| **Analysis & Key Findings** | **Root Causes & Technical Focus** | **Action Plan & Targets** |
|------------------------------|-----------------------------------|----------------------------|
| **1. Technical Infrastructure Issues**<br>- Android users generate **2× more support tickets** than iOS users.<br>- iOS Chrome users face serious signup issues (**6.06%** success rate). | **Primary Root Causes**<br>- Platform inconsistencies between iOS & Android.<br>- UX issues in project creation flow.<br>- Onboarding process fails to retain users.<br>- Technical debt causing fragmented QA. | **Immediate Actions (0–1 month)**<br>- Fix iOS Chrome compatibility & WebKit form handling.<br>- Strengthen Android QA and error monitoring.<br>- Redesign onboarding to reduce 30s churn from **48% → <20%**. |
| **2. Churn Distribution**<br>- Technical issues cause **41%** of total churn.<br>- **48%** of users churn during first impression (session start + first page). | **User Experience Gaps**<br>- Complex project creation process.<br>- Poor mobile UI for traditional industries.<br>- Lack of context-based help or in-app guidance. | **Mid-Term Improvements (1–3 months)**<br>- Optimize project/team management for mobile.<br>- Improve touchscreen UX.<br>- Enhance onboarding flow with contextual hints. |
| **3. Subscription Type Insights**<br>- Premium (Enterprise) plan: **1.41% churn**, indicating high loyalty.<br>- Basic plan churn: **24%** (~$45K annual loss). | **Sector-Based Weaknesses**<br>- Traditional industries (Manufacturing): **33.88% churn**.<br>- Lower digital maturity leads to UX friction. | **Industry-Specific Strategy**<br>- Offer simplified UI


## ▌ Dashboard Snapshot  

![image](https://github.com/AtilaKzlts/SaaS/blob/main/assets/Dashboard_SS.png)

## ▌ Next Steps

### Hypotheses

1. iOS users may show higher conversion rates as they are less likely to experience technical issues.  
2. The Android funnel may face significant drop-offs at the billing stage.  
3. Technical issues in the early signup stages may lead to user churn.  


These points will serve as initial hypotheses for deeper analysis.  
In the upcoming stages, we will validate or reject them using funnel analysis, segmentation, and issue-tracking data.  
The goal is to transform these assumptions into testable hypotheses and derive actionable insights.
