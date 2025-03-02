SELECT * FROM world_life_expectancy;
##############################################################################
###   Removing Duplicates - First Task

Delete from world_life_expectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
    FROM (
			SELECT Row_ID,
            CONCAT(Country, YEAR),
            ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, YEAR) ORDER BY CONCAT(Country, YEAR)) as Row_Num
            FROM world_life_expectancy
            ) AS Row_table
		where Row_Num > 1
        )
        ;
        
SELECT country, concat(Country,Year), count(concat(Country,Year))
FROM world_life_expectancy
group by country, concat(Country,Year)
having count(concat(Country,Year)) > 1 
;

###  Duplicates have been removed.

##-----------------------------------------------------------------------------------------------------------------
###  TASK 2 - Filling null/missing values

### There are some missing values in Status Column

SELECT * FROM world_life_expectancy;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.status =''
AND t2.Status !=''
AND t2.Status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.status =''
AND t2.Status !=''
AND t2.Status = 'Developed'
;

Select * 
From world_life_expectancy
where Status = NULL
;

##  The same can be done for NULL also if present.


####  Doing now for Life Expectancy - Some rows are vacant  ----- 
#### We can fill them with the average of their preceding and succeeding values.
Select *
From world_life_expectancy
;

Select t1.country, t1.YEAR, t1.`Life expectancy`,
t2.country, t2.YEAR, t2.`Life expectancy`,
t3.country, t3.YEAR, t3.`Life expectancy`, 
round( (t2.`Life expectancy` + t3.`Life expectancy`)/2,1 )
 From world_life_expectancy t1
 join world_life_expectancy t2
      on t1.Country = t2.Country
      AND t1.YEAR = t2.YEAR -1
 join world_life_expectancy t3
      on t1.Country = t3.Country
      AND t1.YEAR = t3.YEAR +1
where t1.`Life expectancy` = ''
;

UPDATE world_life_expectancy t1
join world_life_expectancy t2
      on t1.Country = t2.Country
      AND t1.YEAR = t2.YEAR -1
 join world_life_expectancy t3
      on t1.Country = t3.Country
      AND t1.YEAR = t3.YEAR +1
SET  t1.`Life expectancy` = round( (t2.`Life expectancy` + t3.`Life expectancy`)/2,1 )
WHERE t1.`Life expectancy` = ''
;

Select *
From world_life_expectancy
;

#####  Thats all for the data cleaning. Rest of the data looks fine! Now we will proceed with EDA.


####  Exploratory Data Analysis ####

Select *
From world_life_expectancy
;
###------------------------------------------------------------------------------------------------------------------
###  Life Expectancy over the last 15 years  ####

Select Country, MIN(`Life expectancy`), MAX(`Life expectancy`),
round( MAX(`Life expectancy`) - MIN(`Life expectancy`),1 ) AS Life_Increase_15_Years
From world_life_expectancy
Group BY Country
Having MIN(`Life expectancy`) <> 0
and MAX(`Life expectancy`) <> 0
Order by Life_Increase_15_Years ASC
;

###------------------------------------------------------------------------------------------------------------------

##  Average life Expectancy for each year  ####

Select Year, round(Avg(`Life expectancy`),2)
From world_life_expectancy
where (`Life expectancy`) <> 0
and (`Life expectancy`) <> 0
Group by Year
Order by Year
;

###------------------------------------------------------------------------------------------------------------------

Select *
From world_life_expectancy
;
###------------------------------------------------------------------------------------------------------------------

## Relation between life expectancy vs GDP


Select  Country, round(Avg(`Life expectancy`),1) AS Life_Exp, round(AVg(GDP),1) as GDP
From world_life_expectancy
Group BY Country
Having Life_Exp > 0
and GDP > 0
ORDER BY GDP DESC
;

SELECT
SUM(CASE WHEN GDP >=1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END ) High_GDP_Expectancy,
SUM(CASE WHEN GDP <=1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END ) Low_GDP_Expectancy
From world_life_expectancy
;

## ----------------------------------------------------------------------------------------------------------------------------------

## Status Developing Vs Developed ##

Select Status, round(Avg(`Life expectancy`),1)
From world_life_expectancy
Group by Status
;

Select Status, round(Avg(`Life expectancy`),1), count(DISTINCT Country)
From world_life_expectancy
Group by Status
;

##---------------------------------------------------------------------------------------------------------------------------

##  BMI vs Life Expectancy ####

Select Country, round(Avg(`Life expectancy`),1) as Life_Exp, ROUND(AVG(BMI),1) as BMI
From world_life_expectancy
Group by Country
having Life_Exp > 0
and BMI > 0
order by BMI  ASC
;

##-------------------------------------------------------------------------------------------------------------------------

### Adult Mortality and Life expectancy #############

Select Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY year) AS Rolling_Total
From world_life_expectancy
Where Country like '%UNITED%'
;


