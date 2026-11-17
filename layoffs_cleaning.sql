/*
    Layoffs Dataset - Data Cleaning
    Database : MySQL
    Table    : layoffs (raw) -> layoffs_staging -> layoffs_staging2 (cleaned)
    Based on : Alex the Analyst, "Data Cleaning in MySQL" tutorial

    Steps
        1. Remove duplicates
        2. Standardize the data
        3. Handle NULL and blank values
        4. Drop helper columns
        5. Verify the final table
*/


-- ------------------------------------------------------------
-- Setup: staging table
-- Cleaning is done on a copy so the raw table stays untouched.
-- ------------------------------------------------------------

SELECT * FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;


-- ------------------------------------------------------------
-- 1. Remove duplicates
-- ------------------------------------------------------------

-- Inspect duplicates: rows identical across every column get row_num > 1.
WITH duplicate_cte AS
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off,
                         percentage_laid_off, `date`, stage, country,
                         funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- MySQL cannot delete rows through a CTE, so row_num is stored in a
-- second staging table and the duplicates are deleted from there.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off,
                     percentage_laid_off, `date`, stage, country,
                     funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

-- Safe update mode must be off for the DELETE below to run.
SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Check: should return no rows.
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- ------------------------------------------------------------
-- 2. Standardize the data
-- ------------------------------------------------------------

-- company: trim leading and trailing whitespace
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- industry: ORDER BY 1 puts blanks first. Several spellings of
-- "Crypto" turned up, so they are merged into one value.
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- country: "United States" appeared with a trailing period
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- date: convert from text to a proper date.
-- STR_TO_DATE is case-sensitive: %Y is a four-digit year, %y is two
-- digits (using %y returned wrong values).
SELECT date,
    STR_TO_DATE(date, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y');

SELECT date
FROM layoffs_staging2;

-- The values are now dates, but the column type is still TEXT.
ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;


-- ------------------------------------------------------------
-- 3. NULL and blank values
-- ------------------------------------------------------------

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

-- Convert blanks to NULL so both cases are handled the same way.
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Self-join to find companies that have an industry on another row.
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Rows with no layoff figures at all.
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- These rows carry no layoff size, so they are removed before the EDA.
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ------------------------------------------------------------
-- 4. Drop helper columns
-- ------------------------------------------------------------

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- ------------------------------------------------------------
-- 5. Final check
-- ------------------------------------------------------------

SELECT * FROM layoffs_staging2;
