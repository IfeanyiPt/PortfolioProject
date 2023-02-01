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
 
--2. Death numbers per continent 
SELECT continent, 
	MAX(CAST(total_deaths AS INT)) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--3.top 5 Countries with the highest death count per population
SELECT TOP 5 location , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC 

--4.Global Vaccination numbers 
SELECT SUM(New_vaccinations) AS total_vaccinations,
	(SUM(CAST(New_vaccinations AS BIGINT))/SUM(Population))*100 AS global_vacc_percentage
FROM percent_pop_vaccinated
WHERE continent IS NOT NULL

--5.GLOBAL CASES, DEATHS & DEATH PERCENTAGE
SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_Cases)*100 AS global_death_pecentage
From covid_deaths
WHERE continent is not null 
ORDER BY total_cases, total_deaths