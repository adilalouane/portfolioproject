select *
from [dbo].[CovidDeaths$]
where continent is not null
order by 3,4
--select *
--from [dbo].[CovidVaccinations$]
--order by 3,4

--select data that we are going to use

select location ,date, total_cases,new_cases,total_deaths,population
from [dbo].[CovidDeaths$]
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country

select location ,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentPopulationInfected
from [dbo].[CovidDeaths$]
where location like '%morocco%'
and continent is not null
order by 1,2
--looking at  total cases vs population
--shows what percentage of population got Covid


select location ,date,population ,total_cases,(total_cases/population)*100 as DeathsPercentage
from [dbo].[CovidDeaths$]
where location like '%morocco%'
order by 1,2
--looking at countries with highest rate compared to population
select location ,population ,MAX(total_cases)as highestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from [dbo].[CovidDeaths$]
--where location like '%morocco%'
Group by location,population
order by PercentPopulationInfected desc
--Showing countries with highest death count per population

select location ,MAX(cast(total_deaths as int)) as totalDeathCount
from [dbo].[CovidDeaths$]
--where location like '%morocco%'
where continent is not null
Group by location
order by totalDeathCount  desc
--let's break things down by continent
--showing continent with the highest death count per population
select continent ,MAX(cast(total_deaths as int)) as totalDeathCount
from [dbo].[CovidDeaths$]
--where location like '%morocco%'
where continent is not null
Group by continent
order by totalDeathCount desc

--Global numbers

select  date,sum(new_cases) as total_cases,sum(cast(new_deaths as  int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathsPorcentage
from [dbo].[CovidDeaths$]
--where location like '%morocco%'
where continent is not null
group by date
order by 1,2
  

 --looking at total population vs vaccinations

select *
from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccinations
--use CTE
with PopvsVac(continent,location , date ,population ,new_vaccination, RollingPeopleVaccinated) as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)


select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac
--temp table
DROP table if exists #percentpopulationVaccinated

Create table #percentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentpopulationVaccinated  

   
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select*, (RollingPeopleVaccinated/Population)*100
from  #percentpopulationVaccinated
 
 --creating view to store data for later visualization
 create View percentpopulationVaccinated as

 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100

from [dbo].[CovidDeaths$] dea
join [dbo].[CovidVaccinations$] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *
from percentpopulationVaccinated
