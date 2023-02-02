/*
John Benson
COVID-19 Data Exploration 
Skills Used: JOINS, CTE, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS.
*/

USE PortfolioProject;
-- Let's start with the covid death table analysis
SELECT * 
FROM covid_deaths
WHERE continent is not null


--Looking at the total cases vs total deaths percentage in Nigeria since i'm from Nigeria 
SELECT  location , date, total_cases , total_deaths, ( total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE continent is not null AND location like'%nigeria%'
ORDER BY date DESC

-- How is the likelyhood of contracting the virus if you live in the US
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_in_usa
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY date DESC
---From the results , as of january 2023 the US had a total death of 1096503 and a death percentage of 1.08%.

/* What percentage of the US population contracted the virus */
SELECT location, date,total_cases, total_deaths, (total_deaths/population)*100 AS percent_population_infected
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY date DESC

-- 0.34 % of the US population contracted the virus

  
/*Which countries have a  higher infection rate */
SELECT location ,population , MAX(total_cases) AS HighestInfection ,MAX(( total_cases/population))*100 AS PercentPopulationInfected
FROM covid_deaths
WHERE continent is not null
GROUP BY location , population 
ORDER BY PercentPopulationInfected DESC

--Let's take the top 5 
SELECT TOP 5 location ,population , MAX(total_cases) AS HighestInfection ,MAX(( total_cases/population))*100 AS PercentPopulationInfected 
FROM covid_deaths
WHERE continent is not null
GROUP BY location , population 
ORDER BY PercentPopulationInfected DESC

--The country with the higher infection rate is Cyprus located in Europe .
-- How far is the USA from Cyprus ?

SELECT location ,population , MAX(total_cases) AS HighestInfection ,MAX(( total_cases/population))*100 AS PercentPopulationInfected
FROM covid_deaths
WHERE location ='United States'
GROUP BY location , population 
-- Cyprus has a 71% infection rate whereas the US only has 29% , according to the output of this analysis , the US is 56th.


/* How many people were hospitalized in the US ?*/
SELECT location,date,total_cases,hosp_patients,(hosp_patients/total_cases)*100 AS hosp_count
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY date DESC

/* How many in the ICU ?*/
SELECT location,date,total_cases,icu_patients,(icu_patients/total_cases)*100 AS icu_count
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY date DESC 


-- top 5 Countries with the highest death count per population
SELECT TOP 5 location , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC 
---The USA tops the list with 1,096,503 total deaths. 


--Which continent has the higher death count 
SELECT continent , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covid_deaths
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 
---North America is the continent with the highest death count.

--What is the overall global death percentage and how many deaths ?
SELECT 
SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS global_death_pecentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths
---As of today , there are 662,415,626 cases and 6,667,623 deaths. The global death percentage is 1.01%.

--Let's continue  with the covid vaccine table analysis
SELECT * 
FROM covid_vaccine
WHERE continent is not null

--Show the percentage of population that received a vaccine
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as BIGINT)) 
OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingVaccinated
FROM covid_deaths dea
Join covid_vaccine vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 WHERE dea.continent is not null
Order by dea.location ,dea.date 

--USE CTE (Common Table Expression) to perform calculation on the Partition by we did earlier
With PopvsVac ( Continent, location ,date ,population, new_vaccinations,RollingVaccinated)
AS
(
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.Date) AS RollingVaccinated
FROM covid_deaths dea
Join covid_vaccine  vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 WHERE dea.continent is not null
)
--Percentage of population vaccinated by country 
SELECT * , (RollingVaccinated/population)*100 AS percent_vaccinated
FROM PopvsVac

---By doing the CTE we can have daily vaccination counts for each country 

--Let's create a temp table to store our previous modification
DROP TABLE IF EXISTS percent_pop_vaccinated
CREATE TABLE percent_pop_vaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingVaccinated NUMERIC
)

INSERT INTO percent_pop_vaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinated
FROM covid_deaths dea
        JOIN covid_vaccine vac ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, 
	(RollingVaccinated/Population)*100 AS percent_vaccinated
FROM percent_pop_vaccinated


--Which country have the highest vaccination rate ?
SELECT *, (RollingVaccinated/Population)*100 AS percent_vaccinated
FROM percent_pop_vaccinated 

SELECT Location,Continent,Population,
	MAX(New_vaccinations) as highest_vac_count,
	MAX((New_vaccinations/Population))*100 AS percent_vac_count
FROM percent_pop_vaccinated
GROUP BY Location, Continent, Population
ORDER BY percent_vac_count DESC 
---From this analysis , Mongolia has the highest vaccination rate 
