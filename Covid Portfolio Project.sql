
-- To view CovidDeaths and CovidVaccination Tables
SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidVaccinations

SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
where continent is not null
ORDER BY 3,4

-- SELECT THE DATA THAT WE ARE GOING TO BE USING

SELECT location, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract coivd in your country
SELECT location, DATE, TOTAL_CASES, TOTAL_DEATHS, (total_deaths/total_cases)*100 as 'Death%'
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY 1,2

-- Looking at Total Cases VS Population
-- Shows what % of population got covid

SELECT location, DATE, TOTAL_CASES, Population, (total_cases/Population)*100 as 'PercentPopulatioInfected'
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to Population

SELECT location, Population, MAX(TOTAL_CASES) as HighestInfectionCount, MAX((total_cases/Population))*100 as 'PercentPopulatioInfected'
FROM PortfolioProject..CovidDeaths
--- where location like '%states%'
Group by location, population
ORDER BY PercentPopulatioInfected desc

-- Showing countries with highest death count per population

SELECT location, MAX(cast(TOTAL_DEATHS as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--- where location like '%states%'
where continent is not null
Group by location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENET

SELECT CONTINENT, MAX(cast(TOTAL_DEATHS as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--- where location like '%states%'
where continent is NOT null
Group by continent
ORDER BY TotalDeathCount desc

-- showing continents with highest death count per population

SELECT CONTINENT, MAX(cast(TOTAL_DEATHS as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--- where location like '%states%'
where continent is NOT null
Group by continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT DATE, TOTAL_CASES, TOTAL_DEATHS, (total_deaths/total_cases)*100 as 'Death%'
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
WHERE continent is not null
ORDER BY 1,2

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as 'DeathPercentage'
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
WHERE continent is not null
group by date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as 'DeathPercentage'
FROM PortfolioProject..CovidDeaths
-- where location like '%states%'
WHERE continent is not null
-- group by date
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT *
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
  ON  DEA.LOCATION=VAC.LOCATION
  AND DEA.DATE=VAC.DATE


  SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations
,  SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
  ON  DEA.LOCATION=VAC.LOCATION
  AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 1,2,3


-- USing CTE

with PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations
,  SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
  ON  DEA.LOCATION=VAC.LOCATION
  AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
-- ORDER BY 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

-- TEMP Table


create table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations
,  SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
  ON  DEA.LOCATION=VAC.LOCATION
  AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
-- ORDER BY 1,2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating Views to store date for later Visualizations

Create View PercentPopulationVaccinated as
SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.new_vaccinations
,  SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
  ON  DEA.LOCATION=VAC.LOCATION
  AND DEA.DATE=VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
-- ORDER BY 1,2,3