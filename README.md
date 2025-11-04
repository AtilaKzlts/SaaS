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

The Problem: Growth Pains and Critical Revenue Loss
Following last year’s rapid growth, Orbit has slowed down over the last 6 months.
The Most Critical Issue: Mobile app conversion rates are DISASTROUSLY low compared to the website.

The Solution: A Continuous Growth Infrastructure, Not a One-Time Answer
Instead of providing a one-off answer to the CEO’s question **(“Why did we slow down?”),** I built a system that allows us to **continuously monitor** the problem and track the root cause at all times.
Project Goal: Uniting Data Silos for Continuity and Efficiency Savings.
+ Bridging the Data Silos:
Dispersed data (GA4, CRM/PG, ADS) was consolidated into a single central repository (Amazon S3 Data Lake).
+ Saving Manpower Through Automation:
This data flow was automated using Airbyte. The team no longer spends hours on data gathering; their time is dedicated to analysis and action.
+ The Result: The Growth team can now analyze live data, not just the past, allowing for fast, data-driven decisions and instant identification of the real cause of the slowdown.
This Infrastructure is the Permanent Solution to Ensure the Problem Never Recurs.

---

## ▌ Executive Summary
##### [Click for Detailed PDF > ](https://github.com/AtilaKzlts/SaaS/blob/main/assets/Orbit%20SaaS-Report.pdf)

Mobile conversion rates are underperforming, with **48% of users abandoning the app within the first 2 minutes** due to technical and UX differences between iOS and Android. Key findings:

* **Technical Issues:**

  * Android users generate **2x more support tickets** than iOS users.
  * iOS Chrome signup rate is only **6%**, causing significant early churn.

* **Financial Impact:**

  * **Basic plan churn is 24%**, representing \~\$45,000 annual revenue loss.
  * Resolving technical issues could recover up to **50% of this segment’s revenue**.

* **Channel Insights:**

  * Referral channel churn is **34%**, while direct traffic is healthiest at **26%**.

**Root Causes:**

1. Technical debt between iOS and Android.
2. UX issues in complex features (e.g., project creation).
3. Ineffective mobile onboarding.

**Recommended Actions:**

* **Immediate (this month):** Fix iOS Chrome compatibility; redesign mobile onboarding.
* **Mid-term (3 months):** Strengthen Android app QA; develop mobile-friendly project creation feature.

**Targets:**

* Increase iOS Chrome signup from **6% → 15%**.
* Reduce first-impression churn from **48% → 25%**.

**Outcome:**
Implementing these actions can drive measurable revenue growth and significantly improve mobile conversion within 6 months.

----

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

---

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

----

## ▌ Analysis & Key Findings


1. **Technical Infrastructure Issues**
    * Android users generated twice as many support tickets as iOS users.
    * iOS Chrome users experience severe signup difficulties due to compatibility issues (6.06% signup rate).
      
2. **Root Causes of Customer Churn**
    * Technical issues: 66 churns (41% share) – the largest factor.
    * 48% of churn occurs during the first impression stage (session start + page view).
      
3. **Subscription Type Analysis**
    * Premium plan users show stronger retention (Enterprise: 1.41% churn rate) on mobile.

5. **Sector Performance Differences**
    * Traditional industries experience higher churn on mobile (Manufacturing: 33.88% churn rate).

6. **Marketing Channel Analysis**
    * Referral (34.35% churn rate) and Email (34.02% churn rate) channels show unexpectedly high churn.

7. **Page and Feature Analysis**
    * /projects (26.97% churn rate) and Project creation (27 churn users) are the most problematic.

---

## ▌ Solution and Recommendations (Action Plan)

**Immediate Action Areas**

1. **iOS Chrome Compatibility Issue**
   * Severe compatibility and form handling issues must be resolved.
   * WebKit restrictions should be addressed.

2. **Android Technical Stability**
   * High volume of Android support tickets must be reduced.
   * Strengthen Android-specific QA processes.

3. **First Impression Experience**
   * Redesign the mobile onboarding process.
   * Reduce first 30-second churn from 48% to below 20%.

**Mid-Term Improvements**

1. **Project and Team Management Mobile Optimization**
   * Develop mobile-friendly versions of complex features.
   * Improve touchscreen interaction.

2. **Industry-Specific Solutions**
   * Provide desktop-like mobile interfaces for traditional industries.
   * Apply technology sector best practices to other industries.

3. **Marketing Channel Optimization**
   * Improve referral program quality control.
   * Segment and clean email lists.


The current mobile conversion problem is multi-dimensional. Technical infrastructure issues, user experience gaps, and marketing channel quality challenges collectively drive poor performance.

**Priority Targets**:
* Increase iOS Chrome signup rate from 6% to 15%.
* Reduce first impression churn from 48% to 25%.
* Cut Android support tickets by 50%.
* Reduce Basic plan churn rate from 24% to 15%.

**Expected Outcome**:
These improvements will significantly increase mobile platform conversion rates.

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
