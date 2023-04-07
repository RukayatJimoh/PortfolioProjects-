Select*
from OPeyemi..CovidDeaths
order by 3,4

Select*
from OPeyemi..CovidVaccinations
--Where continent is not Null
order by 1,2

Select location, date, total_cases,new_cases,total_deaths,population
from OPeyemi..CovidDeaths

--looking at Total cases Vs Total Deaths
--Shows the likelihood of dying if you contract covid
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from OPeyemi..CovidDeaths
Where location like '%states%'
order by 1,2

--looking at total cases VS Population
--shows what percentage of population got covid

Select location, date,population, total_cases, (total_cases/population)*100 as DeathPercentage
from OPeyemi..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to population
Select location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from OPeyemi..CovidDeaths
Where location like '%states%'
order by 1,2

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from OPeyemi..CovidDeaths
--Where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc

--showing countries with Highest death count population
--Cast to change total_death datatype
Select location,population, MAX(cast (total_deaths as int)) as HighestDeathsCount, MAX((total_deaths/population))*100 as PercentPopulationdeaths
from OPeyemi..CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group by location,population
order by HighestDeathsCount desc


Select  location, MAX(cast (total_deaths as int)) as TotalDeathsCount 
from OPeyemi..CovidDeaths
--Where location like '%states%'
Where continent is Null
Group by location
Order by TotalDeathsCount desc


--Let's break things down by continent

Select  continent,population, MAX(cast (total_deaths as int)) as HighestDeathsCount, MAX((total_deaths/population))*100 as PercentPopulationdeaths
from OPeyemi..CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group by continent,population
order by continent,HighestDeathsCount desc

--Showing continent with the highest death count per population
Select  continent, MAX(cast (total_deaths as int)) as TotalDeathsCount 
from OPeyemi..CovidDeaths
--Where location like '%states%'
Where continent is not Null
Group by continent
Order by TotalDeathsCount desc


--Global numbers
Select date,SUM(new_cases) as TotalNewCases,SUM(cast (new_deaths as int)) TotalNewDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as NewdeathPercentage
from OPeyemi..CovidDeaths
where continent is not null
Group By date

Select SUM(new_cases) as TotalNewCases,SUM(cast (new_deaths as int)) TotalNewDeaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as NewdeathPercentage
from OPeyemi..CovidDeaths
where continent is not null
--Group By date

--- Looking at Total population vs Vaccinations
Select*
from OPeyemi..CovidDeaths dea
Inner join OPeyemi..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
from OPeyemi..CovidDeaths dea
Inner join OPeyemi..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum (Convert (int,vac.new_vaccinations)) Over (Partition by dea.location)
from OPeyemi..CovidDeaths dea
Inner join OPeyemi..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum (Convert (int,vac.new_vaccinations)) Over (Partition by dea.location order by  dea.location,dea.date) as RollingPeopleVaccinated
from OPeyemi..CovidDeaths dea
Inner join OPeyemi..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--create a CTE to use RollingPeOpleVaccinated to calculate Percent of population daily vaccinated

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum (Convert (int,vac.new_vaccinations)) Over (Partition by dea.location order by  dea.location,dea.date) as RollingPeopleVaccinated
from OPeyemi..CovidDeaths dea
Inner join OPeyemi..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100 as PercentageOfDailyvacPerPopulation
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent Nvarchar(255), 
Location Nvarchar(255),
Date datetime, 
Population Numeric,
new_vaccinations Numeric, 
RollingPeopleVaccinated Numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum (Convert (int,vac.new_vaccinations)) Over (Partition by dea.location order by  dea.location,dea.date) as RollingPeopleVaccinated
from OPeyemi..CovidDeaths dea
Inner join OPeyemi..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100 as PercentageOfDailyvacPerPopulation
From #PercentPopulationVaccinated

--Creating view to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum (Convert (int,vac.new_vaccinations)) Over (Partition by dea.location order by  dea.location,dea.date) as RollingPeopleVaccinated
from OPeyemi..CovidDeaths dea
Inner join OPeyemi..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3