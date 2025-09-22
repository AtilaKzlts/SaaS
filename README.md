<div align="center">
  <h1>SaaS

</h1>
 </p>
</div>


## Table of Contents

* Introduction
* Executive Summary
* Business Problems
* Technologies and Architecture
* Solution and Recommendations (Action Plan)
* Dashboard Snapshot
* Next Steps



## Introduction

This project presents an end-to-end solution that combines data collection (ETL) and analysis (BI) processes to address a core business problem. The main objective was to identify the underlying reasons for low conversion rates in a SaaS company’s mobile application. To achieve this, I consolidated fragmented data from multiple sources (GA4, CRM, ADS) into Amazon S3 using Airbyte, making it ready for analysis. The infrastructure I built not only solved the immediate problem but also established a continuous data pipeline, providing a solid foundation for future analyses.


##  Executive Summary

XXXXXXXX
XXXXXXXX
XXXXXXXX

## Business Problems

The primary goal of this project was to provide data-driven solutions to the following critical business challenges faced by a SaaS company:

* **Low Conversion Rates**

  * Subscriber acquisition through the mobile application was significantly lower compared to the web platform.

* **Growth Slowdown**

  * The company’s overall growth rate had been declining over the past six months.

* **Data Silos**

  * Key data sources—user behavior (GA4), customer information (CRM), and advertising performance—were isolated in separate systems, limiting integrated analysis.

**Focus for Resolution**:
The solution required unifying fragmented data sources and identifying potential bottlenecks within the conversion funnel.


## Technologies and Architecture

The core architecture of this project was designed to consolidate fragmented data and make it ready for analysis. The main technologies used are:

* **Data Ingestion**

  * *Airbyte*: Used to automatically load data from GA4 and other sources into Amazon S3.

* **Data Warehouse**

  * *Amazon S3*: Served as a scalable data lake to store both raw and processed data.

* **Data Processing and Transformation (ETL)**

  * *AWS Glue*: Performed ETL (Extract, Transform, Load) operations to transform raw data in S3 into analysis-ready tables.

* **Data Analysis**

  * *Amazon Athena*: Enabled direct analysis of data stored in S3 using SQL queries.

* **Business Intelligence (Visualization)**

  * *QuickSight*: Used to visualize analysis results and create interactive dashboards.


## Analysis & Key Findings
birkac onemli sql ciktisi grafik seklinde olsun

## Solution and Recommendations (Action Plan)

## Dashboard Snapshot  

![image]()

## Gelecek Adımlar
