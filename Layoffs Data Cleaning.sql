-- Data Cleaning


-- 1. Remove duplicates 
-- 2. standardize the data (remove any issues)
-- 3. Null values
-- 4. Remove any unnecessary data (columns or rows)

-- We can't mess with the original raw data so we will make a dummy one for us to work with.


-- 1. Remove duplicates 
CREATE TABLE layoffs_staging
LIKE layoffs;


INSERT layoffs_staging
SELECT *
FROM layoffs;



WITH duplicate_cte AS 
(
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company ,location,
industry, total_laid_off ,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
-- Note I used the Backticks in date in order to identify the column
FROM layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num >1 ;


-- So now we want to delete those duplicates unfortunatlity we can't do it directly
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


SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company ,location,
industry, total_laid_off ,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
-- Note I used the Backticks in date in order to identify the column
FROM layoffs_staging;

-- Inorder to disable safe mode 
SET SQL_SAFE_UPDATES = 0;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
 
-- 2. standardize the data (remove any issues)
SELECT  company , TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- As we can see we have mulitple entry for crypto which are : Crypto , Crypto Currency ,  CryptoCurrency
-- So we will change that 

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Cry%';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Cry%';

-- Make sure the issue is solved
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Look at Country columns 

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1 ;

-- there is an issue here there are 2 united states 

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Make sure the issue is solved
SELECT DISTINCT country
FROM layoffs_staging2;

-- We need to change the data type of date column from text to date 

SELECT `date` , STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');



ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. Null values
-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values except changing some null values which i know it's value
-- Also i will delete rows which it has total laid off and perentage laid off = to NULL as i won't need them

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry ='';

SELECT t1.industry , t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2
WHERE company ='Airbnb';


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

 -- 4 removing unnecessary columns 
 
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

SELECT COUNT(*)
FROM layoffs_staging2;