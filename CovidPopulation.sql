SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations$
--ORDER BY 3,4

--Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2


--Looking at total_cases vs total_deaths
--Shows the likelihood of dying if you contract covid in
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%Philippines%'
ORDER BY 1,2


--Looking at total_cases vs total_deaths
--Shows the likelihood of dying if you contract covid in
Select Location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location= 'Philippines'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population

Select Location, MAX(total_cases) as highest_infection_rate, population, MAX((total_cases/population))*100 AS infected_percentage
FROM PortfolioProject.dbo.CovidDeaths$
GROUP BY Location, Population
ORDER BY infected_percentage DESC


--Looking at countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as highest_death_count
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
GROUP BY Location
ORDER BY highest_death_count DESC


--LET'S GENERALIZE BY CONTINENT
--Showing the continents with the highest death count


Select continent, MAX(cast(total_deaths as bigint)) as highest_death_count
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
-- Where location like '%states%'
GROUP BY continent
ORDER BY highest_death_count DESC


--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by date
Order by 1,2 

--

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
Order by 1,2 


--Looking total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS Int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) AS rolling_vaccination
FROM PortfolioProject.dbo.CovidDeaths$ dea	
Join PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USING CTE


WITH PopVsVac (continent, location, date, population, new_vaccination, rolling_vaccination) 
AS
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS Int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) AS rolling_vaccination
FROM PortfolioProject.dbo.CovidDeaths$ dea	
Join PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
)
SELECT * ,(rolling_vaccination/population)*100 AS vaccination_percentage
FROM PopVsVac


--TEMP TABLE

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
rolling_vaccination numeric,
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS Int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) AS rolling_vaccination
FROM PortfolioProject.dbo.CovidDeaths$ dea	
Join PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
--WHERE dea.continent is not null

SELECT *, (rolling_vaccination/population)*100 --AS vaccination_percentage
FROM #PercentagePopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentagePopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS Int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) AS rolling_vaccination
FROM PortfolioProject.dbo.CovidDeaths$ dea	
Join PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentagePopulationVaccinated