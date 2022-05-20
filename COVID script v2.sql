SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

SELECT Location,date,total_cases,new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country
SELECT Location,date,total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location,date,population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death Count Per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Break things down by Continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--SHOWING continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not  null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/ SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2;
--looking at Totla Population vs Vaccinations
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) AS  RollingPeopleVaccinated, 
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location AND dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3;

 --USE CTE
 WITH PopsvsVac (Contintent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
 as (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) AS  RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location AND dea.date = vac.date
 WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentOfPopulationVaccinated
FROM PopsvsVac;

--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Contintent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
ROllingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) AS  RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location AND dea.date = vac.date
 WHERE dea.continent is not null

 SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentOfPopulationVaccinated
 FROM #PercentPopulationVaccinated;

 --Creating View to Store Data for later visualization
 CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) AS  RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location AND dea.date = vac.date
 WHERE dea.continent is not null;