--https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8FE_XZ87vPPSfHqb6OcM0cF&index=21

SELECT *
FROM PortfolioProject1..CovidDeaths
order by 3,4

SELECT *
FROM PortfolioProject1..CovidVaccinations
order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS - how many cases and deaths in each country
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS death_percentage
FROM PortfolioProject1..CovidDeaths
order by 1,2

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%' 
order by 1,2

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS death_percentage
FROM PortfolioProject1..CovidDeaths
WHERE location = 'United States' AND total_deaths IS NOT NULL
order by 1,2

--LOOKING AT THE TOTAL CASES VS  POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
SELECT location, date, population, total_cases, ((total_cases/population)*100) AS covid_percentage
FROM PortfolioProject1..CovidDeaths
WHERE location = 'United States' AND total_cases IS NOT NULL
order by 1,2

-- WHAT COUNTRY HAS THE HIGHEST RATE VS POPULATION
-- Looking at Countries with Highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection, ((MAX(total_cases)/population)*100) AS percent_population_infected
FROM PortfolioProject1..CovidDeaths
--WHERE location = 'Mexico' 
Group by Location, population
order by percent_population_infected DESC

SELECT location, population, MAX(total_cases) AS highest_infection, ((MAX(total_cases)/population)*100) AS percent_population_infected
FROM PortfolioProject1..CovidDeaths
WHERE location = 'Mexico' 
Group by Location, population
order by percent_population_infected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
Group by Location
order by total_death_count DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
Group by continent
order by total_death_count DESC

---- MORE ACCURATE WITH LOCATION - THE RIGHT WAY
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL
Group by Location
order by total_death_count DESC

---- SHOWING CONTINENTS WITH THE HIGHEST COUNT
SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
Group by continent
order by total_death_count DESC

---- GLOBAL NUMBERS - death percentage across the world
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject1..CovidDeaths
--WHERE location = 'United States' AND total_deaths IS NOT NULL
WHERE continent IS NOT NULL
Group By date
order by 1,2

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject1..CovidDeaths
--WHERE location = 'United States' AND total_deaths IS NOT NULL
WHERE continent IS NOT NULL
--Group By date
order by 1

-- check the other table
SELECT *
FROM PortfolioProject1..CovidVaccinations

-- JOIN THE TWO TABLES
-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT *
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL
ORDER BY 2,3

-- to break into locations the number of vaccinations
---- you adding the new vaccinations, breaking it up by location (everytime it starts a new location, we need to start over)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location)
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL
ORDER BY 2,3

-- to do a rolling count of the sum of the new vaccinations per date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as rolling_vaccinations
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL
ORDER BY 2,3


--USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS 
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM 
	PortfolioProject1..CovidDeaths dea
JOIN 
	PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)

SELECT *
FROM PopvsVac

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS 
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM 
	PortfolioProject1..CovidDeaths dea
JOIN 
	PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)

SELECT *, ((rolling_vaccinations/population) * 100) as rolling_vac_percentage
FROM PopvsVac

---- TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM 
	PortfolioProject1..CovidDeaths dea
JOIN 
	PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *, ((rolling_vaccinations/population) * 100) as rolling_vac_percentage
FROM #PercentPopulationVaccinated

-- change 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM 
	PortfolioProject1..CovidDeaths dea
JOIN 
	PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *, ((rolling_vaccinations/population) * 100) as rolling_vac_percentage
FROM #PercentPopulationVaccinated

-- 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM 
	PortfolioProject1..CovidDeaths dea
JOIN 
	PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *, ((rolling_vaccinations/population) * 100) AS rolling_vac_percentage
FROM #PercentPopulationVaccinated

---- CREATE A VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(convert(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM 
	PortfolioProject1..CovidDeaths dea
JOIN 
	PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
