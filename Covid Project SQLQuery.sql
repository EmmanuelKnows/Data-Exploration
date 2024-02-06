Select * 
from [PortfolioProject]..CovidDeaths
order by 3,4 

--Select * 
--from [PortfolioProject]..CovidVaccinations
--order by 3,4 

--select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population 
from [PortfolioProject]..CovidDeaths
order by 1,2 

--looking at total cases vs total death as Death Percentage (likely hood of dying)
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [PortfolioProject]..CovidDeaths
order by 1,2


--shows the likely hood of dying if you have Covid in my country Nigeria
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [PortfolioProject]..CovidDeaths
Where location like '%nigeria%'
order by 1,2


--shows percentage of population got Covid in my country Nigeria
select location, date, population, total_cases, new_cases, (total_cases/population)*100 as InfectedPercentage 
from [PortfolioProject]..CovidDeaths
Where location like '%nigeria%'
order by 1,2


--countries with the highest infection rate compared to population ***3
select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectedPopulationPercentage 
from [PortfolioProject]..CovidDeaths
Group by location, population 
order by InfectedPopulationPercentage desc

--lets th above query including the date in the select statement and group by ***4

select location, population, date, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as InfectedPopulationPercentage 
from [PortfolioProject]..CovidDeaths
Group by location, population, date
order by InfectedPopulationPercentage desc

--Countries with the highest death count
select location, Max(cast(total_deaths as int)) as TotalDeathCount  
from [PortfolioProject]..CovidDeaths
where continent is not null
Group by location 
order by TotalDeathCount desc

-- lets check this out by continent
select location, Max(cast(total_deaths as int)) as TotalDeathCount  
from [PortfolioProject]..CovidDeaths
where continent is null
Group by location 
order by TotalDeathCount desc 

--from result of the above query the continent are not properly grouped by location 
--lets try using continent

select continent, Max(cast(total_deaths as int)) as TotalDeathCount  
from [PortfolioProject]..CovidDeaths
where continent is not null
Group by continent 
order by TotalDeathCount desc

--from result of the above query the numbers of the total death count are not adding up 
--looking at the data closely 
-- lets rewrite this code again another way ***2

select location, sum(cast(total_deaths as int)) as TotalDeathCount  
from [PortfolioProject]..CovidDeaths
where continent is null
and location not in ('world', 'European Union', 'International')
Group by location 
order by TotalDeathCount desc

-- Lets check Global numbers 

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from [PortfolioProject]..CovidDeaths
where continent is not null
group by date
order by 1,2 

-- total cases, total death and death percentage around the world ***1
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from [PortfolioProject]..CovidDeaths
where continent is not null
order by 1,2 


-- Joining two tables together (coviddeath and covidvaccination)
select *
from [PortfolioProject]..CovidDeaths dea
join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 

-- looking at total population vs vacinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from [PortfolioProject]..CovidDeaths dea
join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date  
where dea.continent is not null 
order by 2, 3 


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingpeopleVaccinated
from [PortfolioProject]..CovidDeaths dea
join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date  
where dea.continent is not null 
order by 2, 3 


-- USE CTE 

with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from [PortfolioProject]..CovidDeaths dea
join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date  
where dea.continent is not null 
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageRollingPeopleVacc
from PopvsVac


-- TEM TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingpeopleVaccinated
from [PortfolioProject]..CovidDeaths dea
join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date  
where dea.continent is not null 
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100 as PercentageRollingPeopleVacc
from #PercentPopulationVaccinated


-- Create view to Store data to aviod writing long queries again 


Create View PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from [PortfolioProject]..CovidDeaths dea
join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date  
where dea.continent is not null 
--order by 2, 3


Create View PercentPopulationVaccinated as
with PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from [PortfolioProject]..CovidDeaths dea
join [PortfolioProject]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date  
where dea.continent is not null 
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 as PercentageRollingPeopleVacc
from PopvsVac


--View the Newly Created views
select *
from PopulationVaccinated

select * 
from PercentPopulationVaccinated