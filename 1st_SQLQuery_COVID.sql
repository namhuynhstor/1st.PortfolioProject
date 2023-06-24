-- Check CovidDeaths table
SELECT *
FROM CovidDeaths

-- Check CovidVaccinations table
SELECT *
FROM CovidVaccinations

--Create Temp Table that include only countries in Southeast Asia
DROP TABLE IF EXISTS CovidSEA
CREATE TABLE CovidSEA
			(
				location nvarchar(255), 
				region nvarchar(255),
				date datetime,
				population numeric,
				new_cases numeric,
				new_deaths numeric,
				doses_administered numeric,
				new_vaccinations numeric,
				people_vaccinated numeric,
				people_fully_vaccinated numeric
			)
INSERT INTO CovidSEA
SELECT	dea.location,
		CASE WHEN dea.location IN ('Cambodia', 'Laos','Myanmar','Thailand','Vietnam') THEN 'mainland'
			ELSE 'maritime'
			END AS region,
		dea.date_new,
		dea.population,
		dea.new_cases,
		dea.new_deaths,
		SUM(CAST(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) AS doses_administered,
		vac.new_vaccinations,
		vac.people_vaccinated,
		vac.people_fully_vaccinated
FROM	CovidDeaths dea
JOIN	CovidVaccinations vac
	ON	dea.location = vac.location
	AND	dea.date_new = vac.date_new
WHERE	dea.continent IS NOT NULL
	AND	dea.location IN ('Brunei','Cambodia','Indonesia','Laos','Malaysia','Myanmar','Philippines','Singapore','Thailand','Timor','Vietnam')

-- check the temp table
SELECT *
FROM CovidSEA
ORDER BY location, date

-- Overall Infection and Death Numbers in Southeast Asia
SELECT	SUM(DISTINCT(population)) as TotalPopulation,
		SUM(new_cases) as TotalCases,
		SUM(new_deaths) as TotalDeaths,
		SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage,
		SUM(new_cases)/SUM(DISTINCT(population))*100 as PercentPopulationInfected,
		SUM(new_deaths)/SUM(DISTINCT(population))*100 as PercentPopulationDeath
FROM	CovidSEA

-- Let’s break things down by countries
SELECT	location,
		MAX(DISTINCT(population)) as population,
		SUM(new_cases) as TotalCases,
		SUM(new_deaths) as TotalDeaths,
		SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage,
		SUM(new_cases)/SUM(DISTINCT(population))*100 as PercentPopulationInfected,
		SUM(new_deaths)/SUM(DISTINCT((population)))*100 as PercentPopulationDeath
FROM	CovidSEA
GROUP BY location
ORDER BY 1;

-- Let’s deep down to vaccinations in SEA
WITH VacSEA(TotalPopulation, TotalDoses, TotalPartlyVaccinated, TotalFullyVaccinated) AS
	(
	SELECT	SUM(DISTINCT population) AS TotalPopulation,
			SUM(new_vaccinations) AS TotalDoses,
			(
				SELECT SUM(val1)
				FROM (
						SELECT	MAX(people_vaccinated) AS val1
						FROM	CovidSEA
						GROUP BY location
					 ) a
			) AS TotalPartlyVaccinated,

			(
				SELECT SUM(val2)
				FROM (
						SELECT MAX(people_fully_vaccinated) AS val2
						FROM CovidSEA
						GROUP BY location
					) b
			) AS TotalFullyVaccinated
    FROM	CovidSEA
	)

SELECT	TotalPopulation,
		TotalPartlyVaccinated,
		TotalFullyVaccinated,
		TotalPartlyVaccinated / TotalPopulation * 100 AS PercentagePartlyVaccinated,
		TotalFullyVaccinated / TotalPopulation * 100 AS PercentageFullyVaccinated
FROM	VacSEA;


-- Break vaccinations down by countries
WITH VacSEAbyCountry (location, population, TotalDoses, PartlyVaccinated, FullyVaccinated, PartlyVaccinatedPercentage, FullyVaccinatedPercentage) AS
	(
	SELECT	location,
			MAX(DISTINCT(population)) as Population,
			SUM(new_vaccinations) as TotalDoses,
			MAX(people_vaccinated) as PartlyVaccinated,
			MAX(people_fully_vaccinated) as FullyVaccinated,
			MAX(people_vaccinated)/MAX(population)*100 as PartlyVaccinatedPercentage,
			MAX(people_fully_vaccinated)/MAX(population)*100 as FullyVaccinatedPercentage
	FROM	CovidSEA
	GROUP BY location
	)

SELECT	*
FROM	VacSEAbyCountry
ORDER BY location;

-- Comparison between Mainland SEA and Maritime SEA
SELECT	region,
		SUM(DISTINCT population) as TotalPopulation,
		SUM(new_cases) as TotalCases,
		SUM(new_deaths) as TotalDeaths,
		SUM(new_cases)/SUM(DISTINCT population)*100 as PercentPopulationInfected,
		SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM	CovidSEA
GROUP BY region;
