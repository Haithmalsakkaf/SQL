select
           RECORD_YEAR::varchar
         , RECORD_MONTH
         , ROUND(AVG_TEMP,2) AS TEMP_EACH_YEAR
from (
SELECT  avg(DAILYTEMPRATURE) AS AVG_TEMP
        , MONTHNAME(RECORDDATE) AS RECORD_MONTH
        ,YEAR(RECORDDATE) AS RECORD_YEAR
        , ROW_NUMBER () over ( partition by year(recorddate) order by avg(DAILYTEMPRATURE) desc ) as rnk
FROM GOLD.DAILYTEMPRATURE
    WHERE MONTH(RECORDDATE)  BETWEEN 6 AND 8
GROUP BY RECORD_MONTH, RECORD_YEAR
ORDER BY RECORD_YEAR DESC
     )
where rnk = 1 
;
-----  2 Q - WHICH WAS THE HOTTEST DAY IN SUMMER MONTH
----- using rnk and subqueris
select
           RECORD_YEAR::varchar
         , RECORDDATE
         , ROUND(AVG_TEMP,2) AS TEMP_EACH_YEAR
from (
SELECT  avg(DAILYTEMPRATURE) AS AVG_TEMP
        ,RECORDDATE                          --MONTHNAME(RECORD_DATE) AS RECORD_MONTH
        ,YEAR(RECORDDATE) AS RECORD_YEAR
        , ROW_NUMBER () over ( partition by year(recorddate) order by avg(DAILYTEMPRATURE) desc ) as rnk
FROM GOLD.DAILYTEMPRATURE
    WHERE MONTH(RECORDDATE)  BETWEEN 6 AND 8
GROUP BY RECORDDATE
ORDER BY RECORD_YEAR DESC
     )
where rnk = 1
;
----------------------------------
-- Q3  WHICH WAS THE COLDEST MONTH
select
           RECORD_YEAR::varchar
         , RECORD_MONTH
         , ROUND(AVG_TEMP,2) AS TEMP_EACH_YEAR
from (
SELECT  avg(DAILYTEMPRATURE) AS AVG_TEMP
        , MONTHNAME(RECORDDATE) AS RECORD_MONTH
        ,YEAR(RECORDDATE) AS RECORD_YEAR
        , ROW_NUMBER () over ( partition by year(recorddate) order by avg(DAILYTEMPRATURE) ) as rnk
FROM GOLD.DAILYTEMPRATURE
    WHERE MONTH(RECORDDATE)  IN (9,10,11,12,1,2)
GROUP BY RECORD_MONTH, RECORD_YEAR
ORDER BY RECORD_YEAR DESC
     )
where rnk = 1
;
-------------------------------
---- Q 4 COLDEST DAY IN WINTER
select
           RECORD_YEAR::varchar
         , RECORDDATE
         , ROUND(AVG_TEMP,2) AS TEMP_EACH_YEAR
from (
SELECT  avg(DAILYTEMPRATURE) AS AVG_TEMP
        ,RECORDDATE                          --MONTHNAME(RECORD_DATE) AS RECORD_MONTH
        ,YEAR(RECORDDATE) AS RECORD_YEAR
        , ROW_NUMBER () over ( partition by year(recorddate) order by avg(DAILYTEMPRATURE) ) as rnk
FROM GOLD.DAILYTEMPRATURE
    WHERE MONTH(RECORDDATE) IN (9,10,11,12,1,2)
GROUP BY RECORDDATE
ORDER BY RECORD_YEAR DESC
     )
where rnk = 1
;
-------------------------------------------------------------
------ Q5 THE WINDIEST MONTH EACH YEAR


WITH Windiest_month AS
(
    SELECT
        EXTRACT(YEAR FROM recorddate) AS year,
        EXTRACT(MONTH FROM recorddate) AS month,
        ROUND(AVG(DAILYWINDSPEED), 2) AS avg_windspeed,
        ROW_NUMBER () OVER (PARTITION BY EXTRACT(YEAR FROM recorddate) ORDER BY
        ROUND(AVG(DAILYWINDSPEED)) DESC) AS rank
    FROM DAILYWINDSPEED
    GROUP BY EXTRACT(YEAR FROM recorddate), EXTRACT(MONTH FROM recorddate)
    ORDER BY year, month
),
Avq_windspeed_year AS
(
    SELECT
         EXTRACT(YEAR FROM recorddate) AS year,
         ROUND(AVG(DAILYWINDSPEED), 2) AS avg_yearly_windspeed
    FROM DAILYWINDSPEED
    GROUP BY EXTRACT(YEAR FROM recorddate)
)
SELECT w.year:: varchar AS year, w.month, w.avg_windspeed AS windiest_month, a.avg_yearly_windspeed
FROM Windiest_month AS w
INNER JOIN Avq_windspeed_year AS a
USING (year)
WHERE rank = 1
ORDER BY year, month
;







--Q6



WITH Windiest_day AS
(
    SELECT
        EXTRACT(YEAR FROM recorddate) AS year,
        EXTRACT(MONTH FROM recorddate) AS month,
        EXTRACT(DAY FROM recorddate) AS day,
        ROUND(AVG(DAILYWINDSPEED), 2) AS avg_windspeed,
        ROW_NUMBER () OVER (PARTITION BY EXTRACT(YEAR FROM recorddate) ORDER BY ROUND(AVG(DAILYWINDSPEED)) DESC) AS rank
    FROM DAILYWINDSPEED
      GROUP BY EXTRACT(YEAR FROM recorddate), EXTRACT(MONTH FROM recorddate),EXTRACT(DAY FROM recorddate)
    ORDER BY year, month, day
),
Avq_windspeed_year AS
(
    SELECT
         EXTRACT(YEAR FROM recorddate) AS year,
         ROUND(AVG(DAILYWINDSPEED), 2) AS avg_yearly_windspeed
    FROM DAILYWINDSPEED
    GROUP BY EXTRACT(YEAR FROM recorddate)
)
SELECT year:: varchar AS year, w.month, w.day, w.avg_windspeed AS windiest_day, a.avg_yearly_windspeed
FROM Windiest_day AS w
INNER JOIN Avq_windspeed_year AS a
USING (year)
WHERE rank = 1
ORDER BY year, month, day
;



--Q7 
---- Q7 WHICH MONTH HAD THE MOST RAINFALL EACH YEAR
select  
           RECORD_YEAR
         , RECORD_MONTH
         , ROUND(rain_fall,2) AS rain_EACH_YEAR 
from (
SELECT  sum(DAILYRAINFALL) AS rain_fall
        , MONTHNAME(RECORDDATE) AS RECORD_MONTH
        ,YEAR(RECORDDATE) AS RECORD_YEAR
        , ROW_NUMBER () over ( partition by year(recorddate) order by sum(DAILYRAINFALL) DESC ) as rnk
FROM GOLD.DAILYRAINFALL
GROUP BY 3,2
--ORDER BY YEAR(RECORD_DATE) 
     )    
where rnk = 1
--GROUP BY 1,2
--order by RECORD_YEAR
;





--Q8
select  
           RECORD_YEAR
         , month
         , SNOW_FALL AS SNOW_EACH_YEAR 
from (
SELECT  sum(DAILYSNOWFALL) AS SNOW_FALL
        ,month(RECORDDATE)  as month                        --MONTHNAME(RECORD_DATE) AS RECORD_MONTH
        ,YEAR(RECORDDATE) AS RECORD_YEAR
        , ROW_NUMBER () over ( partition by year(recorddate) order by sum(DAILYSNOWFALL) DESC ) as rnk
FROM GOLD.DAILYSNOWFALL
       
GROUP BY 3,2
ORDER BY 3
     ) 
where rnk = 1
;



--Q9


with SPRING_DATES as (
    select  
             
              RECORDDATE
              , ROW_NUMBER () OVER ( PARTITION BY YEAR(RECORDDATE) ORDER BY RECORDDATE ) AS spring_start_date
              , temp_spring
             
    from (
            SELECT  
                    RECORDDATE ,DAILYTEMPRATURE  ,                       
                    
                     min(DAILYTEMPRATURE) over ( order by RECORDDATE  ROWS BETWEEN 7 preceding and CURRENT ROW) as temp_spring
            FROM GOLD.DAILYTEMPRATURE
            order by recorddate
    
         ) 
         where  to_char(recorddate, 'MM-DD' ) between '02-15' and '07-31' 
 and temp_spring > 0.0
)

select recorddate AS SPRING_START_DATE
from SPRING_DATES
where spring_start_date=1 ;




-- to delet the NAN valuve 

delete from SRC_WEATHER_DATA.WEATHER_DATA.WEATHER_TABLE_SRC where TEMPERATURE_2M= 'NaN';





--- Q10  
with rainn as (
select year(recorddate) as rain_year, count(*) as rain_count
from SRC_WEATHER_DATA.GOLD.DAILYRAINFALL
where dailyrainfall >10
group by rain_year order by rain_count desc ----2012= 15, 2011 = 8
),

 snoww as (
select year(recorddate) as snow_year, count(*) as snow_count
from SRC_WEATHER_DATA.GOLD.DAILYSNOWFALL
where dailysnowfall >30
group by snow_year order by snow_count desc -- 2012, 2011=1, 2010, 2003
),

 windd as (
select year(recorddate) wind_year, count(*) as wind_count
from SRC_WEATHER_DATA.WEATHER_DATA.HOURLYWINNSPEED
where HOURLYTEMPRATURE >60
group by wind_year order by wind_count desc ), ---- 2007,2011= 5

 years as (
 select distinct year (recorddate) as year_anomaly  from SRC_WEATHER_DATA.GOLD.DAILYRAINFALL
 )

select   year_anomaly
        ,coalesce (rainn.rain_count,0) as rain
        ,coalesce(windd.wind_count,0) as wind
        ,coalesce(snoww.snow_count,0) as snow
       , sum(coalesce (rainn.rain_count,0) + coalesce(windd.wind_count,0) + coalesce(snoww.snow_count,0)) as summm
         
from years
left join rainn
on year_anomaly=rainn.rain_year
left join snoww
on year_anomaly = snoww.snow_year
left join windd SRC_WEATHER_DATA.GOLD.DAILYRAINFALL
on  year_anomaly=windd.wind_year
group by 1,2,3,4
order by summm desc
limit 1
 ;

