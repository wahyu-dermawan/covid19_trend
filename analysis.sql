
--- QUERIES FOR TABLEAU

-- 1. 
-- T0tal Case - Total Deaths - Death Percentage / International

use [Portofolio_Covid]

Select 
	SUM(new_cases) as Total_Cases, 
	SUM(cast(new_deaths as bigint)) as Total_Deaths, 
	SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100 as Death_Percentage
From 
	[dbo].[Death_Covid$]
--Where location like '%states%'
	where continent is not null 
--Group By date
	order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


Select 
	SUM(new_cases) as Total_Cases, 
	SUM(cast(new_deaths as int)) as Total_Deaths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From 
	[dbo].[Death_Covid$]
--Where location like '%states%'
where location = 'World'
--Group By date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select 
	location, 
	SUM(cast(new_deaths as bigint)) as Total_Death_Count
From 
	[dbo].[Death_Covid$]
--Where location like '%states%'
Where 
	continent is null 
and 
location not in ('European Union', 'International','High income','Lower middle income','Low income','Upper middle income')
Group by 
	location
order by 
	Total_Death_Count desc

-- 3.

Select 
	Location, 
	Population, 
	MAX(total_cases) as Highest_Infection_Count,  
	Max((total_cases/population))*100 as Percent_Population_Infected
From 
	[dbo].[Death_Covid$]
--Where location like '%states%'
Group by 
	Location, 
	Population
order by 
	Percent_Population_Infected desc


-- 4.


Select 
	Location, 
	Population,
	date as Date, 
	MAX(total_cases) as Highest_Infection_Count,  
	Max((total_cases/population))*100 as Percent_Population_Infected
From 
	[dbo].[Death_Covid$]
--Where location like '%states%'
Group by 
	Location, 
	Population, 
	date
order by 
	Percent_Population_Infected desc


-- VACCINATED_DATA

--- 1.
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population,
	MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From 
	Death_Covid$ dea
Join 
	VaccinationsCovid$ vac
	On dea.location = vac.location and dea.date = vac.date
where 
	dea.continent is not null 
group by 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population
order by 
	1,2,3;

---2.

Select 
	Location, 
	date, 
	total_cases,total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
From 
	Death_Covid$
--Where location like '%states%'
where continent is not null 
order by 1,2

-- took the above query and added population
Select 
	Location, 
	date, 
	population, 
	total_cases, 
	total_deaths
From 
	Death_Covid$
--Where location like '%states%'
where 
	continent is not null 
order by 1,2

-- 3. 


With 
	PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Peopple_Vaccinated_Gradually)
as
(
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Peopple_Vaccinated_Gradually
--, (RollingPeopleVaccinated/population)*100
From 
	Death_Covid$ dea
Join 
	VaccinationsCovid$ vac On dea.location = vac.location and dea.date = vac.date
where 
	dea.continent is not null and
	vac.location = 'indonesia'
--order by 2,3
)
Select*, 
	(Peopple_Vaccinated_Gradually/Population)*100 as PercentPeopleVaccinated
From 
	PopvsVac 
where Location = 'Indonesia'



-- 7. 

Select 
	Location, 
	Population,date, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From 
	Death_Covid$
--Where location like '%states%'
Group by 
	Location, 
	Population, 
	date
order by 
	PercentPopulationInfected desc

