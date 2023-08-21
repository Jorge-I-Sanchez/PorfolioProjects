-- Grab data from ourworldindata.org/covid-deaths
--Create two tables CovidDeaths and CovidVaccinations
--Import excel tables


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like'%state%'
order by 1,2 desc

--Recevied error message 'Operand data type nvarchar is invalid for divide operator.' Changing total_deaths and total_cases to int. 
-- ALTER TABLE table_name
--ALTER COLUMN column_name datatype;

Alter table CovidDeaths
Alter Column total_deaths int

-- DeathPercentage returned a 0 value. Going to instead use float as data type. * FIXED THE ISSUE

Alter table CovidDeaths
Alter Column total_cases float
Alter Column total_deaths float

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid


Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like'%state%'
order by 1,2 desc


--Looking at countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like'%state%'
group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%state%'
Where continent is not null
group by Location
order by TotalDeathCount desc

-- Break things down by Continent
--Showing continents with the Highest Death count per Population

Select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers
--Use cast function for new_cases and new_deaths column to change into float

Select Sum(cast(new_cases as float)) total_cases, sum(cast(new_deaths as float)) total_deaths, Sum(new_deaths)/ sum(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null AND new_cases <> 0 AND new_deaths <> 0
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	
)
Select*, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac
--Where Location like '%State%'
Order by 2,3 desc

-- TEMP TABLE w/ drop table if function to make easy alterations

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert INTO #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From #PercentPopulationVaccinated

--Creating view to store date for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null

	Select *
	From PercentPopulationVaccinated