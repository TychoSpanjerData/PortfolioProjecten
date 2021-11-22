/*
Corona data onderzoek
Vaardigheden: joins, CTE, TEMP TABLE, filtring functions, aggregate functions, sorting/grouping functions, partition by, converting data types
*/

-- Corona doden sinds meting t/m 16-11-21
SELECT *
FROM CoronaSterfte
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Corona vaccinaties sinds meting t/m 16-11-21
SELECT *
FROM CoronaVaccinaties
WHERE continent IS NOT NULL
ORDER BY 3,4

--Algemene data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CoronaSterfte
WHERE continent IS NOT NULL
ORDER BY 1,2

--Besmettingspercentage: de mate van besmettelijkheid in Nederland
SELECT location, date, population, total_cases, (total_cases/population)*100 as [Besmettings Percentage]
FROM CoronaSterfte
WHERE location = 'Netherlands'
AND continent IS NOT NULL
ORDER BY 2

--Sterftepercentage: de mate van dodelijkheid in Nederland
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as [Sterfte Percentage]
FROM CoronaSterfte
WHERE location = 'Netherlands'
AND continent IS NOT NULL
ORDER BY 2

--Besmettingspercentages in Europa (TABLEAU)
SELECT continent, location, population as [Aantal inwoners], MAX(total_cases) as [Aantal corona gevallen], MAX((total_cases/population))*100 as [Besmettings Percentage]
FROM CoronaSterfte
WHERE continent = 'Europe'
AND total_cases IS NOT NULL
GROUP BY continent, location, population
ORDER BY 5 DESC

--Sterftepercentages in Europa (TABLEAU)
SELECT continent, location, population as [Aantal inwoners], MAX(CAST(total_deaths as int)) as [Aantal corona sterftegevallen], MAX((CAST(total_deaths as int))/population)*100 as [Sterfte percentage]
FROM CoronaSterfte
WHERE continent = 'Europe'
AND total_deaths IS NOT NULL
GROUP BY continent, location, population
ORDER BY [Sterfte percentage] DESC

-- Totaal aantal corona testen per land in Europa
SELECT CS.continent, CS.location, CS.date, CS.population, CV.new_tests,
SUM(CONVERT(int,CV.new_tests)) OVER (PARTITION BY CS.location ORDER BY CS.location) AS [Totaal aantal testen]
FROM CoronaSterfte AS CS
JOIN CoronaVaccinaties AS CV
	ON CS.location = CV.location
	AND CS.date = CV.date
WHERE CS.continent = 'Europe'
ORDER BY 2,3

-- Totaal aantal vaccinaties per land in Europa
SELECT DISTINCT CS.continent, CS.location, CS.population,
SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CS.location ORDER BY CS.location) AS [Totaal aantal vaccinaties]
FROM CoronaSterfte AS CS
JOIN CoronaVaccinaties AS CV
	ON CS.location = CV.location
WHERE CS.continent = 'Europe'
GROUP BY CS.continent, CS.location, CS.population,CS.location, CV.new_vaccinations
ORDER BY 2

-- Het percentage gevaccineerde mensen per land in Europa (d.m.v. CTE)
WITH BevolkingVsVaccinaties (continent, location, population, [Totaal aantal vaccinaties])
AS
(
SELECT DISTINCT CS.continent, CS.location, CS.population,
SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CS.location ORDER BY CS.location) AS [Totaal aantal vaccinaties]
FROM CoronaSterfte AS CS
JOIN CoronaVaccinaties AS CV
	ON CS.location = CV.location
WHERE CS.continent = 'Europe'
GROUP BY CS.continent, CS.location, CS.population,CS.location, CV.new_vaccinations
)
SELECT *,([Totaal aantal vaccinaties]/population)*100 AS [Percentage gevaccineerde]
FROM BevolkingVsVaccinaties

-- Het percentage geteste mensen per land in Europa (d.m.v. TEMP TABLE)
DROP TABLE IF EXISTS #PercentageGevaccineerde
CREATE TABLE #PercentageGevaccineerde
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
[Totaal aantal vaccinaties] numeric
)

INSERT INTO #PercentageGevaccineerde
SELECT DISTINCT CS.continent, CS.location, CS.population,
SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CS.location ORDER BY CS.location) AS [Totaal aantal vaccinaties]
FROM CoronaSterfte AS CS
JOIN CoronaVaccinaties AS CV
	ON CS.location = CV.location
WHERE CS.continent = 'Europe'
GROUP BY CS.continent, CS.location, CS.population,CS.location, CV.new_vaccinations


SELECT *,([Totaal aantal vaccinaties]/population)*100 AS [Percentage gevaccineerde]
FROM #PercentageGevaccineerde