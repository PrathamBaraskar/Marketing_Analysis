# 📊 End-to-End Marketing Analytics & Customer Intelligence Project

[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://microsoft.com/power-bi)
[![Python](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)
[![NLTK VADER](https://img.shields.io/badge/NLTK-VADER_NLP-green?style=for-the-badge&logo=nltk&logoColor=white)](https://www.nltk.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🚀 Executive Summary

Welcome to the **Marketing Analysis & Customer Intelligence Portfolio Project**. This repository showcases an enterprise-grade, end-to-end data analytics solution designed to evaluate multi-channel marketing performance, track customer conversion funnels, measure social media campaign ROI, and decode customer sentiment using Natural Language Processing (NLP).

By bridging raw relational databases, advanced SQL data engineering, Python-based sentiment analysis (NLTK VADER), and an interactive Power BI dashboard, this project delivers actionable business intelligence to optimize marketing spend, elevate customer satisfaction, and drive conversion rates.

📥 **Download & Explore**: 
- [Download Power BI Dashboard (`.pbix`)](./Marketing%20Analysis%20Dashboard.pbix)
- [View Executive Presentation PDF (`.pdf`)](./Marketing%20Analysis%20Dashboard.pdf)
- [Project Business Requirements (`.pptx`)](./Problem%20Statement.pptx)

---

## 🎥 Dashboard Preview

Below is a live walkthrough of the interactive Power BI Marketing Analysis Dashboard, demonstrating executive KPIs, customer segmentation, funnel conversion, and sentiment drill-downs:

![Dashboard Video Walkthrough](./GIF%20file%20of%20the%20Dashboard%20Video.gif)

---

## 🛠️ Project Architecture & Tech Stack

```
[Raw SQL / CSV Data] 
       │
       ├──> [SQL Server ETL & Data Cleaning] ──> Dim & Fact Tables
       │
       ├──> [Python NLP Sentiment Analysis (VADER)] ──> Sentiment Scores & Buckets
       │
       └──> [Power BI Data Modeling & DAX] ──> Enterprise Star-Schema Dashboard
```

- **Database & ETL**: Microsoft SQL Server (T-SQL views, window functions, data cleaning, deduplication, and imputation).
- **Sentiment Engineering**: Python, Pandas, PyODBC, NLTK (VADER Sentiment Intensity Analyzer).
- **Data Visualization**: Power BI Desktop (`.pbix`), DAX measures, relational star schema.
- **Presentation & Strategy**: PowerPoint executive briefs & video demonstration.

---

## 🗄️ Data Modeling & Relational Schema

The project is structured around a robust Star Schema designed for high-performance analytical queries and efficient Power BI rendering. It integrates customer demographics, geographic locations, product catalog tiers, digital engagement tracking, customer journey clickstreams, and NLP-enriched product reviews.

![Semantic Model & Table Relationships](./Images%20of%20the%20project/Semantic%20Table.png)

### 📌 Explanation of Semantic Model & Relationships:
The entity-relationship diagram above illustrates the dimensional data model underlying the marketing warehouse:
- **`dim_customers`** (connected to geography) serves as the core customer dimension, linking customer profiles with geographic dimensions (City, Country).
- **`fact_customer_reviews`** bridges customers and products, augmented with sentiment scoring metrics.
- **`fact_engagement`** tracks marketing campaign interactions across various content types and channels.
- **`fact_customer_journey`** records multi-stage web funnel interactions, enabling advanced drop-off and conversion analysis.
- **`products`** categorizes inventory items into dynamic pricing tiers (`low`, `medium`, `high`) for margin and revenue analysis.

---

## 💻 SQL Data Engineering & Transformation

Data hygiene and transformation scripts were engineered in T-SQL to clean raw relational inputs before ingestion into the BI model.

### 1. Customer Demographics & Geography Integration
[`dim_customers.sql`](./dim_customers.sql) merges customer records with geographic data using a left join to establish regional segmentation.
```sql
select 
    c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Gender,
    c.Age,
    g.Country,
    g.City
from 
    dbo.customers as c 
left join 
    dbo.geography as g
on 
    c.GeographyID = g.GeographyID;
```

### 2. Social Media Engagement Cleaning & Parsing
[`fact_engagement.sql`](./fact_engagement.sql) cleans marketing campaign data by filtering out non-campaign newsletters, standardizing content type nomenclature, parsing combined metrics (`ViewsClicksCombined`) into discrete numeric metrics using string manipulation (`CHARINDEX`, `LEFT`, `RIGHT`), and formatting dates.
```sql
select 
    EngagementID,
    ContentID, 
    CampaignID,
    ProductID, 
    upper(replace(ContentType, 'Socialmedia' , 'Social Media')) as ContentType,
    left(ViewsClicksCombined, Charindex('-', ViewsClicksCombined) - 1 ) as Views,
    right(ViewsClicksCombined, len(ViewsClicksCombined) - Charindex('-', ViewsClicksCombined)) as Clicks,
    Likes, 
    format(convert(date,EngagementDate), 'dd.MM.yyyy') as EngagementDate
from 
    dbo.engagement_data
where 
    ContentType != 'newsletter';
```

### 3. Customer Journey Deduplication & Imputation
[`fact_customer_journey.sql`](./fact_customer_journey.sql) handles data quality issues in web funnel tracking. It identifies and eliminates duplicate user actions using window functions (`ROW_NUMBER()`) and imputes missing session durations using partition-level daily averages (`AVG(Duration) OVER (PARTITION BY VisitDate)`).
```sql
with DuplicateRecords as ( 
    select 
        JourneyID, CustomerID, ProductID, VisitDate, Stage, Action, 
        row_number() over(
            partition by CustomerID, ProductID, VisitDate, Stage, Action
            order by JourneyID
        ) as row_num 
    from dbo.customer_journey
)
select JourneyID, CustomerID, ProductID, VisitDate, Stage, Action, 
    Coalesce(Duration, avg_duration, 0) as Duration
from (
    select 
        JourneyID, CustomerID, ProductID, VisitDate,
        upper(Stage) as Stage, Action, Duration, 
        Avg(Duration) over (partition by VisitDate) as avg_duration,
        row_number() over (
            partition by CustomerID, ProductID, VisitDate, upper(Stage), Action
            order by JourneyID
        ) as row_num
    from dbo.customer_journey
) as subquery
where row_num = 1;
```

### 4. Review Text Standardization & Product Pricing Segmentation
- [`CustomerReview.sql`](./CustomerReview.sql): Standardizes review text by removing erratic double spacing (`REPLACE(ReviewText, '  ', ' ')`).
- [`SQLQuery1.sql`](./SQLQuery1.sql): Creates dynamic product price tier classifications (`low` <50, `medium` 51-200, `high` >200) for cross-tabulation analysis.

---

## 🐍 Python NLP Sentiment Analysis

To extract deep qualitative insights from customer feedback, an NLP sentiment analysis pipeline was built using Python, NLTK, and VADER (`SentimentIntensityAnalyzer`).

- **Code Script**: [`This py sentiment has comments to understandwhat is happening.py`](./This%20py%20sentiment%20has%20comments%20to%20understandwhat%20happening.py)
- **Jupyter Notebook**: [`customer_reviews_enrichment.ipynb`](./customer_reviews_enrichment.ipynb)
- **Enriched Dataset**: [`fact_customer_reviews_with_sentiment.csv`](./fact_customer_reviews_with_sentiment.csv)

### Methodology:
1. **Data Extraction**: Connects to SQL Server via `pyodbc` to extract raw customer reviews.
2. **Polarity Scoring**: Computes VADER compound sentiment scores (ranging from -1.0 to +1.0).
3. **Hybrid Categorization**: Combines the textual VADER sentiment score with numerical star ratings (`Rating`) to classify reviews into refined categories: `Positive`, `Negative`, `Neutral`, `Mixed Positive`, and `Mixed Negative`.
4. **Sentiment Bucketing**: Groups sentiment scores into granular ranges (`0.5 to 1.0`, `0.0 to 0.49`, `-0.49 to 0.0`, `-1.0 to -0.5`).

---

## 📈 Power BI Dashboard & Visual Insights

The Power BI dashboard translates complex data pipelines into intuitive, decision-ready executive views.

### 1. Customer Reviews & Sentiment Analysis View
![Customer Reviews & Sentiment Breakdown](./Images%20of%20the%20project/Customer%20Reviews.png)

### 📌 Explanation of Customer Reviews Analysis:
This dashboard page evaluates customer sentiment dynamics across products and review ratings:
- **Sentiment Distribution Matrix**: Correlates numerical ratings (1 to 5 stars) with NLP sentiment categories (Positive, Mixed, Negative), exposing discrepancies where customers left high ratings with neutral/negative text or vice versa.
- **Volume by Sentiment Bucket**: Highlights the concentration of strongly positive vs. mildly negative reviews, helping product teams isolate immediate quality defects.
- **Time-Series Sentiment Trends**: Tracks sentiment shifts over time to measure the impact of recent product updates or customer service interventions.

---

### 2. Executive Overview Page
![Executive Overview Dashboard](./Images%20of%20the%20project/overview.png)

### 📌 Explanation of Executive Overview:
The Overview page serves as the C-suite command center for marketing operations:
- **High-Level KPIs**: Aggregates total revenue, customer acquisition count, total website traffic, and overall campaign ROI.
- **Geographic Performance**: Visualizes regional sales and engagement distribution across cities and countries, highlighting top-performing markets.
- **Channel Contribution**: Provides a comparative breakdown of revenue and conversion contribution across digital marketing channels.

---

### 3. Conversion Funnel Details
![Conversion Funnel Details](./Images%20of%20the%20project/Conversion%20Details.png)

### 📌 Explanation of Conversion Details:
This view dissects the customer journey from initial discovery to final purchase:
- **Funnel Stage Analysis**: Tracks drop-off rates across website visits, product views, cart additions, and checkouts.
- **Drop-off Bottlenecks**: Identifies friction points where prospective buyers abandon the funnel, allowing marketing teams to optimize retargeting campaigns.
- **Duration & Session Analytics**: Analyzes average session duration per stage to understand user engagement depth.

---

### 4. Social Media Campaign Details
![Social Media Campaign Details](./Images%20of%20the%20project/Social%20Media%20Details.png)

### 📌 Explanation of Social Media Details:
The social media performance page analyzes multi-channel marketing campaigns:
- **Engagement Metrics**: Breaks down Views, Clicks, Likes, and Click-Through Rates (CTR) across different social media platforms and campaign IDs.
- **Content Type Efficiency**: Compares video, image, and text content formats to determine which medium yields the highest user interaction.
- **Campaign ROI Tracking**: Correlates social ad spend and engagement with downstream conversions and product purchases.

---

## 📂 Repository File Structure

```tree
Marketing_Analysis/
├── README.md                                     # Comprehensive project documentation
├── LICENSE                                       # MIT Open Source License
├── Marketing Analysis Dashboard.pbix             # Interactive Power BI Report
├── Marketing Analysis Dashboard.pdf              # Executive PDF export of dashboard
├── Problem Statement.pptx                        # Business requirements & presentation deck
├── Vedio of the Dashboard Presentation.mp4       # Video presentation recording
├── GIF file of the Dashboard Video.gif           # Animated dashboard preview GIF
├── customer_reviews_enrichment.ipynb             # Jupyter notebook for NLP sentiment pipeline
├── This py sentiment has comments to understandwhat is happening.py # Python sentiment analysis script
├── fact_customer_reviews_with_sentiment.csv      # Enriched NLP customer reviews dataset
├── CustomerReview.sql                            # SQL script for customer reviews cleaning
├── dim_customers.sql                             # SQL script for customer dimension modeling
├── fact_engagement.sql                           # SQL script for social media engagement ETL
├── fact_customer_journey.sql                     # SQL script for customer journey cleaning & imputation
├── SQLQuery1.sql                                 # SQL script for product pricing segmentation
└── Images of the project/
    ├── Semantic Table.png                        # ER Diagram & Data Model
    ├── Customer Reviews.png                      # Customer Reviews & Sentiment dashboard view
    ├── overview.png                              # Executive Overview dashboard view
    ├── Conversion Details.png                    # Conversion Funnel dashboard view
    └── Social Media Details.png                  # Social Media Campaign dashboard view
```

---

## 👨‍💻 Author & Professional Context

This project demonstrates proficiency in:
- **Data Engineering**: Advanced T-SQL (Window Functions, CTEs, Data Cleaning, Imputation).
- **Data Science & NLP**: Python, NLTK (VADER Sentiment Analysis), Pandas pipelines.
- **Business Intelligence**: Power BI Star Schema architecture, DAX modeling, and Executive Storytelling.

---
⭐ *If you found this project insightful, feel free to give it a star!*
