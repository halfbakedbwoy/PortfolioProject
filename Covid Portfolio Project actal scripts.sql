select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

----select *
----from PortfolioProject..CovidVaccinations
----order by 3,4

--select Data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths
--shows likelihood of dying if you contract covid
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%states%'
and continent is not null
order by 1,2

--looking at Total Cases vs Population
--shows what percentage of population got covid
select Location, date, population, total_cases,  (total_cases/population)*100 as percentpopulationinfected
from PortfolioProject..CovidDeaths
--where Location like '%states%'
order by 1,2

--looking at countries with highest infection rate  compared to population

select Location, population, max(total_cases) as highestinfectioncount,  max((total_cases/population))*100 as percentpopulationinfected
from PortfolioProject..CovidDeaths
--where Location like '%states%'
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count per population

select Location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where Location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where Location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2



--looking at total population vs vaccinatons

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Using CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac



--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated