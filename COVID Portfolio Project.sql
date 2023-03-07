select *
from PortfolioProject..Coviddeathsclean
where continent is not null
order by 3,4

select * 
from PortfolioProject..Covidvaccinationsclean
order by 3,4

--select the data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddeathsclean
order by 1,2


--Looking at Total Cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeathsclean
where location like '%states%'
order by 1,2


--looking at the Total Cases vs Population
--shows what percentage of population got covid


select location, date, Population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..Coviddeathsclean
--where location like '%states%'
order by 1,2


--looking at countries with Highest Infection Rate compared to Population

select location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..Coviddeathsclean
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--showing Countries with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Coviddeathsclean
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--showing continents with the highest death counts

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..Coviddeathsclean
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeathsclean
--where location like '%states%'
where continent is not null
Group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..Coviddeathsclean
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

select *
from PortfolioProject..Coviddeathsclean dea
join PortfolioProject..Covidvaccinationsclean vac
    on dea.location = vac.location
	and dea.date = vac.date



--Looking at the Total Population vs Vaccinations
--you can use castor convert 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Coviddeathsclean dea
join PortfolioProject..Covidvaccinationsclean vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3



	--USE CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..Coviddeathsclean dea
join PortfolioProject..Covidvaccinationsclean vac
    on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	select *, (RollingPeopleVaccinated/Population)*100
	from PopVsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..Coviddeathsclean dea
join PortfolioProject..Covidvaccinationsclean vac
    on dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

	select *, (RollingPeopleVaccinated/Population)*100
	from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..Coviddeathsclean dea
join PortfolioProject..Covidvaccinationsclean vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated