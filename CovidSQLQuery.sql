Select *
From PortfolioProject..CovidDeaths

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths int;
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases int;
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases Vs Total Deaths

SELECT Location, date, total_cases, total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN NULL 
        ELSE CAST(total_deaths AS float) / CAST(total_cases AS float) * 100
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
Order by 1,2

-- Total Cases VS Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT Location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--COuntries with highest Death count per popn
SELECT continent, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(INT,vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated     
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3

With PopVsVac (Continent, Location,Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(INT,vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated     
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--Creating view

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   SUM(CONVERT(INT,vac.new_vaccinations))
OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated     
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated