/*
    Layoffs Dataset - Exploratory Data Analysis
    Database : MySQL
    Table    : layoffs_staging2 (output of layoffs_cleaning.sql)
    Based on : Alex the Analyst, "Exploratory Data Analysis in MySQL" tutorial
*/

SELECT * FROM layoffs_staging2;


-- ------------------------------------------------------------
-- Maximum layoffs
-- percentage_laid_off = 1 means 100% of the company.
-- ------------------------------------------------------------

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that laid off everyone, largest funding first
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- ------------------------------------------------------------
-- Layoffs by company
-- ORDER BY 2 sorts by the second column in the SELECT list.
-- ------------------------------------------------------------

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


-- ------------------------------------------------------------
-- Date range of the data
-- ------------------------------------------------------------

SELECT MAX(`date`), MIN(`date`)
FROM layoffs_staging2;


-- ------------------------------------------------------------
-- Layoffs by industry
-- ------------------------------------------------------------

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


-- ------------------------------------------------------------
-- Layoffs by country
-- ------------------------------------------------------------

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- ------------------------------------------------------------
-- Layoffs by year
-- ------------------------------------------------------------

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


-- ------------------------------------------------------------
-- Layoffs by company stage
-- ------------------------------------------------------------

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- ------------------------------------------------------------
-- Layoffs by month
-- SUBSTRING(date, 1, 7) gives 'YYYY-MM', so each month is kept
-- separate per year instead of merging, for example, every January.
-- ------------------------------------------------------------

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


-- ------------------------------------------------------------
-- Rolling total of layoffs by month
-- The CTE holds the monthly totals; the window function adds them
-- up month by month.
-- ------------------------------------------------------------

WITH Rolling_Total AS
(
    SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
    SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


-- ------------------------------------------------------------
-- Layoffs by company per year
-- ------------------------------------------------------------

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


-- ------------------------------------------------------------
-- Top 5 companies by layoffs in each year
-- Company_Year      : total layoffs per company per year
-- Company_Year_Rank : ranks companies within each year
-- DENSE_RANK gives tied companies the same rank and does not skip
-- the next one, so a year can return more than 5 rows.
-- ------------------------------------------------------------

WITH Company_Year (company, years, total_laid_off) AS
(
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


-- ------------------------------------------------------------
-- Total funds raised, counting each company once
-- funds_raised_millions repeats on every layoff row of a company,
-- so a plain SUM over the table would count it multiple times.
-- This is the figure used for the Power BI "Funds Raised" card.
-- ------------------------------------------------------------

SELECT SUM(max_funds) AS correct_total
FROM (
    SELECT company, MAX(funds_raised_millions) AS max_funds
    FROM layoffs_staging2
    GROUP BY company
) t;
