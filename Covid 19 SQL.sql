#Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
#/

--select *
--from portfolioprojectaug..covidvaccination$

Select *
From portfolioprojectaug..coviddeath$
Where continent is not null 
order by 3,4

#1. Select Data for project# 

Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
From portfolioprojectaug..coviddeath$
Where Continent is not null 
order by 1,2

#2.Total Cases vs Total Deaths#
#Shows likelihood of dying if one contracts covid in United Stated#

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioprojectaug..coviddeath$
Where location like '%states%'
and continent is not null 
order by 1,2

#3.Total Cases vs Population#
#Shows the percentage of population infected with Covid#

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
order by 1,2

#4.Countries with Highest Infection Rate compared to Population#
#focus on US#

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

#5.Countries with Highest Death Count per Population#

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

#BREAKING THINGS DOWN BY CONTINENT#

#6.Showing contintents with the highest death count per population#

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

#7.Showing total new cases per continent#

Select continent, MAX(cast(Total_cases as int)) as TotalCasesPerContinent
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalCasesPerContinent desc

#GLOBAL NUMBERS#

#8.Percentage of new death per new cases in US#

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as NewDeathPercentage
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

#9.Total Population vs Vaccinations#
#Shows Percentage of Population with at least one Covid Vaccine#

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioprojectaug..coviddeath$ dea
Join portfolioprojectaug..covidvaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


#10.Using CTE to perform Calculation on Partition By in previous query#

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioprojectaug..coviddeath$ dea
Join portfolioprojectaug..covidvaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

#11.Using Temp Table to perform Calculation on Partition By in previous query#

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

#12.Insert into #PercentPopulationVaccinated#

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioprojectaug..CovidDeath$ dea
Join portfolioprojectaug..covidvaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

#13.
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

14.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as NewDeathPercentage
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

15.
select  location, SUM(cast(new_deaths as int)) as TotalDeathCount
from portfolioprojectaug..coviddeath$
----Where location like '%states%'
where continent is null
and location not in ('world', 'European Union', 'International', 
'Upper middle income', 'High income', 'Lower middle income', 'low income')
Group By location
order by TotalDeathCount desc

16.
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

17.
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Group by Location, Population,date
order by PercentPopulationInfected

#18.Creating View to store data for visualizations#

Create View PercentofPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioprojectaug..coviddeath$ dea
Join portfolioprojectaug..covidvaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Create View CaeSummaryPerCountry AS
Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
From portfolioprojectaug..coviddeath$
Where Continent is not null 
--order by 1,2

Create View PercentageofpopulationInfected AS 
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
--order by 1,2

Create View CountrywithHighestInfection AS 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Group by Location, Population
--order by PercentPopulationInfected desc

create View CountrieswithHighestDeathCount AS

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

Create View ContintentwithHighestDeathCount AS

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Where continent is not null 
Group by continent
--order by TotalDeathCount desc

Create View TotalNewCasesperCountry AS

Select continent, MAX(cast(Total_cases as int)) as TotalCasesPerContinent
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Where continent is not null 
Group by continent
--order by TotalCasesPerContinent desc

Create View PercentageofNewCasesUS AS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as NewDeathPercentage
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
where continent is not null 
--Group By date
--order by 1,2

Create View PercentagePopulationwithOneVaccine AS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioprojectaug..coviddeath$ dea
Join portfolioprojectaug..covidvaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Create View NewDeathPercentage AS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as NewDeathPercentage
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
where continent is not null 
--Group By date
--order by 1,2

Create View TotalDeathCountbyContinent AS

select  location, SUM(cast(new_deaths as int)) as TotalDeathCount
from portfolioprojectaug..coviddeath$
----Where location like '%states%'
where continent is null
and location not in ('world', 'European Union', 'International', 
'Upper middle income', 'High income', 'Lower middle income', 'low income')
Group By location
--order by TotalDeathCount desc

Create View PercentagePopulationInfected AS

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Group by Location, Population
--order by PercentPopulationInfected desc

Create View PercentagePopulationInfectedbyDate AS

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioprojectaug..coviddeath$
--Where location like '%states%'
Group by Location, Population,date
--order by PercentPopulationInfected
