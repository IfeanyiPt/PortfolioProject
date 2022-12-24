SELECT * 
FROM PortoflioProject..covid_death1
WHERE continent is not null

SELECT location , date, total_cases ,new_cases, total_deaths,population
FROM PortoflioProject..covid_death1
WHERE continent is not null
ORDER BY 1,2


--Looking at the total cases vs total deaths percentage in Nigeria
SELECT location , date, total_cases , total_deaths, ( total_deaths/total_cases)*100 AS DeathPercentage
FROM PortoflioProject..covid_death1
WHERE continent is not null
--Where location like'%nigeria%'
ORDER BY 1,2


--total cases vs population
-- Show what percentage of population that has Covid
SELECT location , date, population total_cases , ( total_deaths/population)*100 AS PercentPopulatIoninfected
FROM PortoflioProject..covid_death1
WHERE continent is not null
--Where location like'%nigeria%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location ,population , MAX(total_cases) AS HighestInfection ,MAX(( total_cases/population))*100 AS PercentPopulationInfected
FROM PortoflioProject..covid_death1
WHERE continent is not null
--Where location like'%nigeria%'
GROUP BY location , population 
ORDER BY PercentPopulationInfected DESC 

-- Countries with the highest death count per population
SELECT location , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortoflioProject..covid_death1
WHERE continent is not null
--Where location like'%nigeria%'
GROUP BY location 
ORDER BY TotalDeathCount DESC 

-- BY CONTINENT 
SELECT continent , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortoflioProject..covid_death1
WHERE continent is  not null
--Where location like'%nigeria%'
GROUP BY continent
ORDER BY TotalDeathCount DESC 

--GLOBAL NUMBERS
SELECT   SUM(new_cases) AS total_cases  , SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortoflioProject..covid_death1
WHERE continent is not null
--Where location like'%nigeria%' 
ORDER BY 1,2

--COVID VACCINE
--Total population vaccinated 
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
AS RollingVaccinated--,(RollingVaccinated/population)*100
FROM PortoflioProject..covid_death1 dea
Join PortoflioProject..covid_vaccine  vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 WHERE dea.continent is not null
Order by 2,3

-- USE CTE
With PopvsVac ( Continent, location ,date ,population, new_vaccinations,RollingVaccinated)
AS
(
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
AS RollingVaccinated
FROM PortoflioProject..covid_death1 dea
Join PortoflioProject..covid_vaccine  vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 WHERE dea.continent is not null
--Order by 2,3
)
-- Percentage of population vaccinated by country 
SELECT * , (RollingVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE 
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
AS RollingVaccinated
FROM PortoflioProject..covid_death1 dea
Join PortoflioProject..covid_vaccine  vac
     On dea.location = vac.location
	 and dea.date = vac.date
--WHERE dea.continent is not null
--Order by 2,3

Select * , (RollingVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Create view for tableau 

Create View PercentPopulationVaccinated AS
SELECT dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) 
AS RollingVaccinated
FROM PortoflioProject..covid_death1 dea
Join PortoflioProject..covid_vaccine  vac
     On dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3










