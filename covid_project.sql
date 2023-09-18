SELECT TOP(100) * FROM [sql project covid].dbo.CovidDeaths$

--changing NULL new_cases into 0 new_cases, it helps me with the next query
UPDATE [sql project covid].dbo.CovidDeaths$
SET new_cases = 0
WHERE new_cases IS NULL

-- new tests vs new cases per country
SELECT continent, location, date, new_cases, new_tests, (new_cases/new_tests)*100 as positive_tests_percentage
FROM [sql project covid].dbo.CovidDeaths$
WHERE new_tests IS NOT NULL

--avg percentage of positive tests and avg percentage of deaths per country
SELECT location, (SUM(new_cases)/SUM(CONVERT(int, new_tests)))*100 as positive_tests_percentage,
(SUM(CONVERT(int, new_deaths))/SUM(new_cases))*100 as deaths_percentage
FROM [sql project covid].dbo.CovidDeaths$
WHERE new_tests IS NOT NULL
GROUP BY location
ORDER BY 3 DESC;

--total vaccinations vs population of each country

WITH vac_per_day (location, date, population, vac_sum) AS (
SELECT dea.location, dea.date, dea.population, SUM(CONVERT(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM [sql project covid].dbo.CovidDeaths$ dea
JOIN [sql project covid].dbo.CovidVacc vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
)
SELECT location, date, population, (vac_sum/population)*100 AS "vac_percentage" FROM vac_per_day
WHERE vac_sum IS NOT NULL AND location LIKE '%state%';
