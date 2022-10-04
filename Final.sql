SELECT *
FROM Covid_Portfolio..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM Covid_Portfolio..CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Portfolio..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2 -- BASED ON LOCATION AND DATES

-- Total Cases Vs Total Deaths
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathsPercent
FROM Covid_Portfolio..CovidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2 

-- Total Cases By Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PoplInfected
FROM Covid_Portfolio..CovidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2 

-- Countries with highest infection rate by popln
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPoplInfected
FROM Covid_Portfolio..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPoplInfected DESC


--Countries with the highest death count by popln
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Covid_Portfolio..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


----CONTINENTS with the highest death count by popln
SELECT continent, MAX(cast(total_deaths as int)) AS DeathCountConti
FROM Covid_Portfolio..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCountConti DESC


-- Global Numbers
SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 AS DeathPercentage
FROM Covid_Portfolio..CovidDeaths$
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2 


-- Looking at Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/
FROM Covid_Portfolio..CovidDeaths$ dea
JOIN Covid_Portfolio..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM Covid_Portfolio..CovidDeaths$ dea
JOIN Covid_Portfolio..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100 as VacPercent
from PopvsVac



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM Covid_Portfolio..CovidDeaths$ dea
JOIN Covid_Portfolio..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM Covid_Portfolio..CovidDeaths$ dea
JOIN Covid_Portfolio..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

	