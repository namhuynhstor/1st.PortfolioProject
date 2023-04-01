
select		*
from		PortfolioProject..deaths
where		continent is not NULL
order by	3,4

--select	*
--from		PortfolioProject..vaccinations
--order by	3,4


--SELECT DATA THAT I AM GOING TO BE USING

select		location, date, total_cases, new_cases, total_deaths, population
from		PortfolioProject..deaths
where		continent is not NULL
order by	1,2


--LOOKING AT TOTAL CASES V.S TOTAL DEATHS
--SHOWS LIKEHOOD OF DYING IF YOU CONTRACT COVID

select		location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathCase_Percentage
from		PortfolioProject..deaths
where		location like '%states%'
and			continent is not NULL
order by	1,2


-- LOOKING AT TOTAL CASES V.S POPULATION
-- SHOWS PERCENTAGES OF PP GOT COVID

select		location, date, total_cases, population, (total_cases/population)*100 as DeathPop_Percentage
from		PortfolioProject..deaths
--where		location like '%states%'
order by	1,2


-- LOOKING AT COUNTRY WITH HIGH INFECTION RATE COMPARED TO POPOLATION

select		location, population, MAX(total_cases) as HighInfectionCount, 
			MAX((total_cases/population))*100 as Percentage_PopInfected
from		PortfolioProject..deaths
--where		location like '%states%'
group by	location, population
order by	Percentage_PopInfected desc


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select		location, MAX(cast(Total_deaths as int)) as TotalDeathCount 
from		PortfolioProject..deaths
--where		location like '%states%'
where		continent is not NULL
group by	location
order by	TotalDeathCount desc


-- LET'S BREAK THING DOWN BY CONTINENT

-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

select		continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
from		PortfolioProject..deaths
--where		location like '%states%'
where		continent is not NULL
group by	continent
order by	TotalDeathCount desc


-- GLOBAL NUMBERS

-- RATE OF TOTAL NEW CASES PER TOTAL NEW DEATHS BY DATE

select		date
			, SUM(new_cases) as sum_new_cases
			, SUM(cast(new_deaths as int)) sum_new_deaths
			, case when SUM(new_cases) = '0' then '0'
			else SUM(cast(new_deaths as int))/ SUM(new_cases)*100 end as NewDeathCase_Rate

from		PortfolioProject..deaths
--where		location like '%states%'
where		continent is not NULL
group by	date
order by	4 desc


-- LOOKING TOTAL POPULATION VS VACCINATIONS

with pop_vs_vac 
as
(
select	dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from	PortfolioProject..deaths dea
join	PortfolioProject..vaccinations vac
	on		dea.location = vac.location
	and		dea.date = vac.date
where		dea.continent is not NULL
group by	dea.continent
			, dea.location
			, dea.date
			, dea.population
			, vac.new_vaccinations
)

select	*
		, (RollingPeopleVaccinated/ population)*100 as vac_per_pop
from	pop_vs_vac
--where	(RollingPeopleVaccinated/ population)*100 is not null


-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select	dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from	PortfolioProject..deaths dea
join	PortfolioProject..vaccinations vac
	on		dea.location = vac.location
	and		dea.date = vac.date
--where		dea.continent is not NULL
--order by	2,3


select	*
		, (RollingPeopleVaccinated/ population)*100 as vac_per_pop
from	#PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view PercentPopulationVaccinated as
select	dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from	PortfolioProject..deaths dea
join	PortfolioProject..vaccinations vac
	on		dea.location = vac.location
	and		dea.date = vac.date
where		dea.continent is not NULL
--order by	2,3




select	*
from	PercentPopulationVaccinated