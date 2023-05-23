
SELECT *
FROM PortfolioprojectCovid.dbo.deaths; 

SELECT *
FROM PortfolioprojectCovid.dbo.vaccinations;

--percentage of new_cases--
SELECT LOCATION,DATE,TOTAL_CASES,new_cases,ROUND((NEW_CASES/TOTAL_CASES)*100,2) AS PERCENTAGE_NEW_CASES,POPULATION
from PortfolioprojectCovid.dbo.deaths
WHERE LOCATION IS NOT NULL
order by location;

--maximum cases among all the countries--
SELECT MAX(LOCATION),MAX(TOTAL_CASES)
FROM PortfolioprojectCovid.dbo.deaths;

--PERCENTAGE OF DEATH
SELECT LOCATION,POPULATION,TOTAL_DEATHS,NEW_DEATHS,cast(ROUND((NEW_DEATHS/TOTAL_DEATHS)*100,2) as float) AS PERCENTAGE_DEATHS
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS
where location is not null
order by location;

--DEATH PERCENTAGE 
SELECT LOCATION,POPULATION,TOTAL_DEATHS,TOTAL_CASES, ROUND(CAST(TOTAL_DEATHS AS FLOAT)/ CAST(TOTAL_CASES AS FLOAT)*100,2) AS percentage_deaths
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS
WHERE LOCATION IS NOT NULL AND LOCATION = 'UNITED STATES'
ORDER BY location;

--diagonsed covid vs population.
Select LOCATION,population,total_deaths,ROUND((total_deaths/population)*100,4) AS percentage_death_population
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS
WHERE LOCATION IS NOT NULL AND LOCATION = 'CHINA'
ORDER BY LOCATION;

--COVID INFECTION AT HIGHEST LEVEL AMONG COUNTRIES.
SELECT date,LOCATION, total_cases, population, MAX(total_cases/population) AS percentage_highest_level
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS
WHERE location IS NOT NULL AND location != 'asia' -- north america,south america, europe,australia
GROUP BY date,location, population,total_cases
ORDER BY percentage_highest_level DESC;

--covid deaths with compared to population
SELECT date,population,location,total_deaths,max(total_deaths/population)*100 as max_percentage_death_population
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS
group by date,population,location,total_deaths 
order by max_percentage_death_population desc;

--total_deaths compared to continent
SELECT CONTINENT,MAX(CAST(TOTAL_DEATHS AS INT)) AS totaldeathcontinent
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcontinent DESC;

--total number of fatalities throughout a continent's nations.
SELECT date,continent,location,total_deaths
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS
WHERE continent is not null --and location = 'united states'
group by date,continent,location,total_deaths
order by continent;

--sum of total_deaths in the world
SELECT SUM(CAST(COALESCE(TOTAL_DEATHS,0) AS bigint)) AS sumoftotaldeaths
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS;  -- USING COLAESCE

--percentage of sum of total deaths with population in the world
SELECT 
	SUM(cast(coalesce(total_deaths,0)as bigint)) sumoftotaldeaths,
	sum(cast(coalesce(population,0)as bigint)) as sumofpopulation,
	(SUM(cast(coalesce(total_deaths,0)as bigint)) * 100.0)/sum(cast(coalesce(population,0)as bigint)) AS PERCENTOFDEATHS 
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS;

--SELECT 
--    SUM(CAST(COALESCE(total_deaths,0) AS BIGINT)) AS sumoftotaldeaths,
--    SUM(CAST(COALESCE(population,0) AS BIGINT)) AS sumofpopulation,
--    (SUM(CAST(COALESCE(total_deaths,0) AS BIGINT)) * 100.0) / NULLIF(SUM(CAST(COALESCE(population,0) AS BIGINT)),0) AS percentage
--FROM 
--    PORTFOLIOPROJECTCOVID.DBO.DEATHS;


--SELECT 
--    SUM(CAST(COALESCE(total_deaths,0) AS BIGINT)) AS sumoftotaldeaths,
--    SUM(CAST(COALESCE(population,0) AS BIGINT)) AS sumofpopulation,
--    CASE
--        WHEN SUM(CAST(COALESCE(population,0) AS BIGINT)) > 0 
--            THEN (SUM(CAST(COALESCE(total_deaths,0) AS BIGINT)) * 100.0) / SUM(CAST(COALESCE(population,0) AS BIGINT))
--        ELSE 0
--    END AS percentage
--FROM 
--    PORTFOLIOPROJECTCOVID.DBO.DEATHS;

--TOTAL_cases AND total_tests  --JOIN
SELECT D.date,D.location,D.total_cases,V.total_tests
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS AS D
join portfolioprojectcovid.dbo.vaccinations AS V
on D.location = V.location
WHERE d.location = 'united states'
order by d.date, D.location;

--total_population vs total_cases, total_tests and total_vaccination --- JOIN
SELECT d.date,d.continent,d.population,d.total_cases,v.total_tests,v.total_vaccinations
FROM PORTFOLIOPROJECTCOVID.DBO.DEATHS AS d
JOIN portfolioprojectcovid.dbo.vaccinations AS v
ON d.continent = v.continent
AND d.date = v.date
order by d.continent;

--total populations of countries vs total vaccinations -- join

SELECT d.date,d.location,d.population,v.total_vaccinations
	FROM PortfolioprojectCovid.DBO.DEATHS AS d
	JOIN portfolioprojectcovid.dbo.vaccinations AS v
		ON d.location = v.location
			AND d.date = v.date
				AND total_vaccinations is not null 
				ORDER BY d.location;

--total population vs. new vaccinations

SELECT d.date,d.location,d.population,v.new_vaccinations
	FROM PortfolioprojectCovid.DBO.DEATHS AS d
	JOIN portfolioprojectcovid.dbo.vaccinations AS v
		ON d.location = v.location
			AND d.date = v.date
				AND new_vaccinations is not null 
					AND d.location NOT IN ( 'AFRICA','ASIA','NORTH AMERICA','SOUTH AMERICA','EUROPE')
				ORDER BY d.location;

--VERY IMPORTANT--CUMULATIVE OF NEW VACCINATIONS
SELECT d.date,d.location,d.population,v.new_vaccinations,
		SUM(cast(v.new_vaccinations as bigint)) OVER( partition by d.location ORDER BY d.location,d.date) AS cumulative_new_vaccinations
	FROM PortfolioprojectCovid.DBO.DEATHS AS d
	JOIN portfolioprojectcovid.dbo.vaccinations AS v
		ON d.location = v.location
			AND d.date = v.date
				AND new_vaccinations is not null 
					AND d.location NOT IN ( 'AFRICA','ASIA','NORTH AMERICA','SOUTH AMERICA','EUROPE')
				ORDER BY d.location;

--CUMULATIVE NEW VACCINATIONS VS POPULATION ORDER BY LOCATION.
WITH cumulative (date,location,populations,new_vaccinations,cumulative_new_vaccinations) as
(
SELECT d.date,d.location,d.population,v.new_vaccinations,
		SUM(cast(v.new_vaccinations as bigint)) OVER( partition by d.location ORDER BY d.location,d.date) AS cumulative_new_vaccinations
	FROM PortfolioprojectCovid.DBO.DEATHS AS d
	JOIN portfolioprojectcovid.dbo.vaccinations AS v
		ON d.location = v.location
			AND d.date = v.date
				AND new_vaccinations is not null 
					AND d.location NOT IN ( 'AFRICA','ASIA','NORTH AMERICA','SOUTH AMERICA','EUROPE')
				--ORDER BY d.location
)
SELECT *,(cumulative_new_vaccinations * 100/ populations)
FROM cumulative;


--temporary table
CREATE table #percentage_vac_populations
(
[date] nvarchar(255)
[location] nvarchar(255)
populations nvarchar(255)
new_vaccinations nvarchar(255)
cumulative_new_vaccinations nvarchar(255)
)

Insert into percentage_vac_populations
SELECT d.date,d.location,d.population,v.new_vaccinations,
		SUM(cast(v.new_vaccinations as bigint)) OVER( partition by d.location ORDER BY d.location,d.date) AS cumulative_new_vaccinations
	FROM PortfolioprojectCovid.DBO.DEATHS AS d
	JOIN portfolioprojectcovid.dbo.vaccinations AS v
		ON d.location = v.location
			AND d.date = v.date
				AND new_vaccinations is not null 
					AND d.location NOT IN ( 'AFRICA','ASIA','NORTH AMERICA','SOUTH AMERICA','EUROPE')
				--ORDER BY d.location
SELECT *,(cumulative_new_vaccinations * 100/ populations)
FROM percentage_vac_populations;





