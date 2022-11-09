-- Select Data that we are going to be starting with
select*
from Project..Vaccinations
select location, date, population, total_cases, total_deaths,new_cases
from Project..Deaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, population, total_cases, total_deaths,new_cases
, (total_deaths/total_cases)*100 as DeathRate
from Project..Deaths
where location like '%China%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select location, date, population, total_cases, total_deaths
, (total_cases/population)*100 as CaseRate
from Project..Deaths
where location like '%China%'
order by 1,2 desc
-- Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount
, max(total_cases/population)*100 as MaxInfectionRate
from Project..Deaths
where continent is not null
group by location,population
order by 4
-- Countries with Highest Death Count per Population
select location, population, max(total_deaths) as HighestDeathsCount
, max(total_deaths/population)*100 as MaxDeathsRate
from Project..Deaths
where continent is not null
group by location,population
order by 4 desc
-- ???BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project..Deaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc
-- GLOBAL NUMBERS(Total_cases, total_deaths, Proportion
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths
, sum(cast(new_deaths as int))/sum(new_cases) as DeathRate
from Project..Deaths
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


-- without order, only sum not adding up
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Deaths dea
Join Project..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Deaths dea
Join Project..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as Rate_PeopleVaccinated
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

Create Table PPC2
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations nvarchar(255),
RollingPeopleVaccinated nvarchar(255)
)
Insert into PPC2
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Deaths dea
Join Project..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select *, (RollingPeopleVaccinated/Population)*100 as Rate_PeopleVaccinated
From PPC2

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..Deaths dea
Join Project..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
select *
From PercentPopulationVaccinated1