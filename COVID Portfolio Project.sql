select *
from PortfolioProject.dbo.CovidDeaths
where continent is not null

--select *
--from PortfolioProject.dbo.CovidVaccinations

-- Data Using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1, 2

--Total Cases v Total Deaths
select location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1, 2

--Total Cases v Pop - % of pop that got Covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
order by 1, 2

--Highest Infect Rate
select location, max(total_cases) as HighestInfectionCount, population, max((cast(total_cases as float)/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
group by population, location
order by PercentPopulationInfected desc

--Highest Death Rate
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Continents w/ highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
having sum(new_cases) > 0
order by 1, 2

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
having sum(new_cases) > 0
order by 1, 2


--Total Pop v Vax
select dea.continent, dea.location, dea.date, population, new_vaccinations
, sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVax
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
order by 2, 3


--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingVax)
as
(
select dea.continent, dea.location, dea.date, population, new_vaccinations
, sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVax
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
--order by 2, 3
)

select *, (RollingVax/population)*100
from PopvsVac


-- TEMP TABLE
drop table if exists #percentpopulationvaxed
create table #percentpopulationvaxed
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVax numeric
)


INSERT INTO #percentpopulationvaxed

select dea.continent, dea.location, dea.date, population, new_vaccinations
, sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVax
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null and new_vaccinations is not null
--order by 2, 3


select *, (RollingVax/population)*100
from #percentpopulationvaxed


--CREATING VIEW

create view percentpopulationvaxed as
select dea.continent, dea.location, dea.date, population, new_vaccinations
, sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingVax
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
--order by 2, 3

select *
from percentpopulationvaxed