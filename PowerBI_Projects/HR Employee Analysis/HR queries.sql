CREATE DATABASE projects;

USE projects;

SELECT * FROM hr;

-- Rename id column to emp_id

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

-- Check data types of all columns

DESCRIBE hr;

--Change birthdate values to date

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

-- Change birthdate column datatype

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

-- Convert hire_date values to date

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

-- Convert termdate values to date and remove time

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- Add age column

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

SELECT count(*) FROM hr WHERE age < 18;

-- Check Termdates in the future

SELECT COUNT(*) FROM hr WHERE termdate > CURDATE();
SELECT COUNT(*)
FROM hr
WHERE termdate = '0000-00-00';
SELECT location FROM hr;

-- EXPLORING DATA

-- gender breakdown of employees in the company

SELECT gender, COUNT(*) AS count
FROM hr
WHERE age >= 18
GROUP BY gender

-- race/ethnicity breakdown of employees in the company

SELECT race, COUNT(*) AS count
FROM hr
WHERE age >= 18
GROUP BY race
ORDER BY count DESC

-- age distribution of employees in the company

SELECT 
  MIN(age) AS youngest,
  MAX(age) AS oldest
FROM hr
WHERE age >= 18


SELECT 
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+' 
  END AS age_group, gender,
  COUNT(*) AS count
FROM 
  hr
WHERE 
  age >= 18
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- employees work at headquarters versus remote locations

SELECT location, COUNT(*) as count
FROM hr
WHERE age >= 18
GROUP BY location;

-- average length of employment for employees who have been terminated

SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_length_of_employment
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE() AND age >= 18;

-- gender distribution vary across departments

SELECT department, gender, COUNT(*) as count
FROM hr
WHERE age >= 18
GROUP BY department, gender
ORDER BY department;

-- distribution of job titles across the company

SELECT jobtitle, COUNT(*) as count
FROM hr
WHERE age >= 18
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- department that has the highest turnover rate

SELECT department, COUNT(*) as total_count, 
    SUM(CASE WHEN termdate <= CURDATE() AND termdate <> '0000-00-00' THEN 1 ELSE 0 END) as terminated_count, 
    SUM(CASE WHEN termdate = '0000-00-00' THEN 1 ELSE 0 END) as active_count,
    (SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*)) as termination_rate
FROM hr
WHERE age >= 18
GROUP BY department
ORDER BY termination_rate DESC;

-- distribution of employees across locations by state

SELECT location_state, COUNT(*) as count
FROM hr
WHERE age >= 18
GROUP BY location_state
ORDER BY count DESC;

-- How has the company's employee count changed over time based on hire and term dates?

SELECT 
    year, 
    hires, 
    terminations, 
    (hires - terminations) AS net_change,
    ROUND(((hires - terminations) / hires * 100), 2) AS net_change_percent
FROM (
    SELECT 
        YEAR(hire_date) AS year, 
        COUNT(*) AS hires, 
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM 
        hr
    WHERE age >= 18
    GROUP BY 
        YEAR(hire_date)
) subquery
ORDER BY 
    year ASC;

-- tenure distribution for each department

SELECT department, ROUND(AVG(DATEDIFF(CURDATE(), termdate)/365),0) as avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department

-- Visualization in PowerBI
