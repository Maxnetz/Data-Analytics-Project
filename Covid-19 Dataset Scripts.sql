SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

SELECT * 
FROM CovidVaccinations
ORDER BY 3, 4;

------ Select Data that we are going to be using

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you cou contract covid in your country

SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS deathPercentage
FROM CovidDeaths
WHERE location LIKE '%Thailand%'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population

SELECT
	location,
	date,
	total_cases,
	population,
	total_deaths,
	(total_cases/population)*100 AS casesPercentage
FROM CovidDeaths
WHERE location LIKE '%Thailand%'
ORDER BY 1, 2;

-- Looking at countries with highest infection Rate Compared to Population

SELECT
	location,
	population,
	MAX(total_cases) AS highestInfectionCount,
	MAX((total_cases/population))*100 AS percentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY percentPopulationInfected desc;

-- Showing coutries with highest death count per population

SELECT
	location,
	population,
	MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY totalDeathCount desc;

SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount desc;

-- Let's Break things down by continent

SELECT
	continent,
	MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount desc;


-- Showing continents with highest deathcount

SELECT
	continent,
	MAX(CAST(total_deaths AS INT)) AS totalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount desc;


-- Global Number

SELECT 
	date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Total Population vs Vaccination

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- USE CTE

WITH PopvsVac (contient, 
				location, 
				date, 
				population, 
				new_vaccinations, 
				rollingPeopleVaccinated)
AS(SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, (rollingPeopleVaccinated/population)*100 AS vacPercentage
FROM PopvsVac;



-- TEMP TABLE

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rollingPeopleVaccinated numeric)

INSERT INTO PercentPopulationVaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinatedCount
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rollingPeopleVaccinated/population)*100 AS vacPercentage
FROM PercentPopulationVaccinated;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinatedCount
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated