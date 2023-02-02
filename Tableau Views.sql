/*
John Benson
COVID-19 Data Exploration Tableau queries 
*/

USE PortfolioProject;

--1-Which continent has the higher death count 
SELECT continent , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 
 

--2-Which continent has the higher death count 
SELECT continent , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 



--3.GLOBAL CASES, DEATHS & DEATH PERCENTAGE
SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_Cases)*100 AS global_death_pecentage
From covid_deaths
WHERE continent is not null 
ORDER BY total_cases, total_deaths

--4./*Which countries have a  higher infection rate */
SELECT location ,population , date ,MAX(total_cases) AS HighestInfection ,MAX(( total_cases/population))*100 AS PercentPopulationInfected
FROM covid_deaths
--WHERE continent is not null
GROUP BY location , population, date  
ORDER BY PercentPopulationInfected DESC
