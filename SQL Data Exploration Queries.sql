--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM covidDeaths
--ORDER BY 1,2

-- Total cases vs total deaths
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases)*100 as deathPercentage
FROM covidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Total cases vs population
SELECT location, date, total_cases, population, (total_cases / population)*100 as infectedPercentage
FROM covidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Countries with highest infection rate
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases / population)*100 as HighestInfectedPercentage
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY HighestInfectedPercentage DESC

-- Countries with highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY date

-- CTE TABLE

WITH PopulationVSVaccination(location, date, population, new_vaccinations, RollingCountVaccination)
AS
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccination
FROM covidDeaths dea
INNER JOIN covidVaccinations vac
ON dea.location=vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingCountVaccination / population ) * 100
FROM PopulationVSVaccination

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
location VARCHAR(255),
date TIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingCountVaccination NUMERIC
)
INSERT INTO "#PercentVaccinated"
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccination
FROM covidDeaths dea
INNER JOIN covidVaccinations vac
ON dea.location=vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * , (RollingCountVaccination / population ) * 100
FROM #PercentVaccinated
ORDER BY location

-- Creating view to store data for visualisation
CREATE VIEW PercentVaccinated AS
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccination
FROM covidDeaths dea
INNER JOIN covidVaccinations vac
ON dea.location=vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
