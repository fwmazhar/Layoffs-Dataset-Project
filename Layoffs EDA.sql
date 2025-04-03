-- Explatory data analysis 



SELECT MAX(total_laid_off) , MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off =1;


SELECT company ,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1  
ORDER BY 2 DESC;

SELECT MIN(`date`) , MAX(`date`)
FROM layoffs_staging2;

SELECT industry ,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1  
ORDER BY 2 DESC;

SELECT country ,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1  
ORDER BY 2 DESC;

SELECT YEAR(`date`) ,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1  
ORDER BY 2 DESC;


SELECT MONTH(`date`) AS month,YEAR(`date`) AS year ,SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE MONTH(`date`) IS NOT NULL
GROUP BY 1,2  
ORDER BY 2 ASC , 1 ASC;

-- For making rolling sum 

WITH rolling_sum AS (
SELECT MONTH(`date`) AS month ,YEAR(`date`) AS year ,SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE MONTH(`date`) IS NOT NULL
GROUP BY 1,2  
ORDER BY 2 ASC , 1 ASC
)

SELECT month,year,total_off,SUM(total_off) OVER (ORDER BY year,month) AS rolling_total
FROM rolling_sum;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1,2
ORDER BY 3 DESC;

WITH company_year (company,years,total_laid_off) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1,2
), company_year_rank AS 
(
SELECT *,
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL 
)
SELECT * FROM company_year_rank
WHERE ranking <=5 ;


SELECT COUNT(DISTINCT company)
FROM layoffs_staging2;
