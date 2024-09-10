/*
Covid 19 Data Exploration

Skills Used: Joins, CTE's, Temp Tables. Window Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
From [Portfolio Project]..CovidDeaths 
where continent is not null
order by 3,4

--Select Data we will be Starting With

Select Location, date, total_cases, new_cases, total_deaths, population 
From [Portfolio Project]..CovidDeaths 
where continent is not null
order by 3,4

--Total Cases vs Total Deaths
--Showing Likelihood of Dying if You Contract Covid in Your Country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases )*100 as PercentDead 
From [Portfolio Project]..CovidDeaths 
Where not (total_cases = 0) and location like '%states%'
order by 1,2   

--Total Cases vs Population
--Shows what Percentage of the Population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentDead 
From [Portfolio Project]..CovidDeaths 
Where not (total_cases = 0) and location like '%states%'
order by 1,2   

--Countries with Highest Infection Rates Compared to Population

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected 
From [Portfolio Project]..CovidDeaths 
Group by location, population, date
order by PercentPopulationInfected desc  

--Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) TotalDeathCount
From [Portfolio Project]..CovidDeaths 
where continent is not null
Group by location
order by TotalDeathCount desc  

--Break Things Down by Continent
--Showing Continent with the Highest Death Count Per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths 
where continent is null and location not in ('World', 'Low-income countries', 'Lower-middle-income countries', 'High-income countries', 'Upper-middle-income countries', 'European Union (27)')
group by location
order by TotalDeathCount desc  

--GLOBAL NUMBERS

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as PercentDead
From [Portfolio Project]..CovidDeaths 
Where continent is not null
--group by date
order by 1,2   


--Total Population vs Vaccinations
--Shows Percentage of Populationthat has Recieved at Least one Covid Vaccine

Select dea.continent, dea.location, dea.date, population, new_vaccinations,
sum(cast(new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidVaccines dea 
join [Portfolio Project]..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Uing CTE to perform Calculation on Partition By in Previous Query 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, population, new_vaccinations,
sum(convert(bigint,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidVaccines dea 
join [Portfolio Project]..CovidDeaths vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

--Using TEMP TABLE to perform Calculations on Partition By in Previous Query

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, new_vaccinations,
sum(convert(bigint,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea 
join [Portfolio Project]..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

--CREATE A VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, new_vaccinations,
sum(convert(bigint,new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea 
join [Portfolio Project]..CovidVaccines vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * from PercentPopulationVaccinated