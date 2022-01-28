-- Covid 19 Data Exploration

-- Used Skills: JOIN's, CTE, Creating view, Windows Functions, Aggregate Functions, Converting Data Types


SELECT *
FROM Portfolio.dbo.corona_death


-- Select Data 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio.dbo.corona_death
WHERE continent is not null
order by 1,2


--Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio.dbo.corona_death
WHERE location like '%kaz%' and continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT Location, date, total_cases, population,  (total_cases/population)*100 as PercentPopulationInfected
FROM Portfolio.dbo.corona_death
WHERE location like '%kaz%' and continent is not null
order by 1,2



-- Countries with Highest Infection Rate compared to Population
SELECT population, location, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM Portfolio.dbo.corona_death
GROUP BY location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio.dbo.corona_death
Where continent is not null
GROUP BY location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio.dbo.corona_death
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc



-- GLOBAL numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM Portfolio.dbo.corona_death
WHERE continent is not null
order by 1,2



-- Total Population vs Vaccination
-- Percentage of population that has received at least one Covid Vaccine
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
   dea.Date) as RollingPeopleVaccinated
FROM Portfolio.dbo.corona_death dea
JOIN Portfolio.dbo.corona_vaccination vac
   ON dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio.dbo.corona_death dea
Join Portfolio.dbo.corona_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Creating view to store data
CREATE view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio.dbo.corona_death dea
Join Portfolio.dbo.corona_vaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
