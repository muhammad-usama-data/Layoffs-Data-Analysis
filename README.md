# Global Layoffs Data Analysis & Dashboard (MySQL & Power BI)

## Project Overview
Cleaned, explored, and visualized global tech layoff records using **MySQL** and **Power BI**. The project transforms raw, inconsistent layoff records into a structured dataset and an interactive dashboard highlighting industry trends, top affected companies, and year-over-year patterns.

## Tools & Skills Used
* **MySQL:** Data cleaning (removing duplicates with window functions, standardizing text/dates, handling null values) and exploratory data analysis (CTEs, rolling totals, aggregations).
* **Power BI:** Data modeling, KPI cards, interactive slicers, and trend visualizations (`Layoffs_dashboard.pbix`).

## Dashboard Preview
![Layoffs Dashboard](layoffs_dashboard.png)

## Key Findings
* **Overall Impact (2020–2023):** Across the dataset, **384K employees** were laid off across **1,628 companies**, representing companies that had raised over **$804B ($804,181M)** in total funding.
* **Layoffs Trend Over Time:** Following an initial spike in early 2020, layoffs remained relatively low throughout 2021 before surging dramatically in late 2022 and peaking sharply in **January 2023** (reaching nearly **85K** in a single month).
* **Top Impacted Industries:** **Consumer (45K)** and **Retail (44K)** experienced the highest job losses, followed by **Other (36K)**, **Transportation (34K)**, **Finance (28K)**, and **Healthcare (26K)**.
* **Geographic Concentration:** The **United States** accounted for the vast majority of global layoffs with **189K** employees affected—nearly half of the global total—followed by **India (22K)**, the **Netherlands (16K)**, and **Sweden (10K)**.

## Files Included
* `layoffs.csv` – Raw original dataset.
* `layoffs_cleaning.sql` – SQL queries used to clean, standardize, and deduplicate the raw data.
* `layoffs_staging2.csv` – Cleaned dataset exported for analysis and visualization.
* `layoffs_EDA.sql` – Exploratory SQL queries analyzing layoff trends by company, industry, country, and date.
* `Layoffs_dashboard.pbix` – Interactive Power BI dashboard file.
