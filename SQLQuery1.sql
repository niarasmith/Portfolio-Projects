--start
Select location, date, total_cases, new_cases, total_deaths, population
From [PORTFOLIO PROJECT]..CovidDeaths$
order by 1,2

--Total cases vs total deaths percentage
--SHOWS CHANCES OF DYING after contracting covid in US in 2021

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PORTFOLIO PROJECT]..CovidDeaths$
where location like '%states%' and date like '%2021%'
order by 1,2 DESC

--total cases vs population
--shows what percentage of population infected with covid in 2021

Select location, date, total_cases, population, (total_cases/population)*100 as population_infected
From [PORTFOLIO PROJECT]..CovidDeaths$
where location like '%states%' and date like '%2021%'
order by 1,2 DESC

--countries with highest infection rate vs population

Select location, population, MAX(total_cases) AS highest_count, MAX((total_cases/population))*100 as population_infected
From [PORTFOLIO PROJECT]..CovidDeaths$
GROUP BY LOCATION, POPULATION
order by population_infected DESC

--countries with highest death count

Select location, population, MAX(cast(total_deaths as int)) AS Highestdeathcount
From [PORTFOLIO PROJECT]..CovidDeaths$
GROUP BY LOCATION, POPULATION
order by Highestdeathcount DESC

--check locations column
select distinct location
from [PORTFOLIO PROJECT]..CovidDeaths$
order by 1

--return countries with highest death count (only not continents)

Select location, MAX(cast(total_deaths as int)) AS Highestdeathcount
From [PORTFOLIO PROJECT]..CovidDeaths$
where continent is not null
GROUP BY LOCATION
order by Highestdeathcount DESC



--CONTINENTS with highest death count

Select continent, MAX(cast(total_deaths as int)) AS Highestdeathcount
From [PORTFOLIO PROJECT]..CovidDeaths$
where continent is NOT null
GROUP BY continent
order by Highestdeathcount DESC

-------------------------------------------------------------------------------

--GLOBAL

--DAILY Total cases vs total deaths percentage GLOBALLY

SELECT date, SUM(total_cases) AS total_cases_sum, SUM(CAST(total_deaths AS INT)) AS total_deaths_sum, (SUM(CAST(total_deaths AS INT))/SUM(total_cases))*100 AS DeathPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
WHERE continent IS NOT NULL
group by date
ORDER BY 1

--Total cases vs total deaths percentage GLOBALLY

SELECT SUM(total_cases) AS total_cases_sum, SUM(CAST(total_deaths AS INT)) AS total_deaths_sum, (SUM(CAST(total_deaths AS INT))/SUM(total_cases))*100 AS DeathPercentage
FROM [PORTFOLIO PROJECT]..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--TOTAL POP VS VACC

select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations, SUM(CONVERT(INT, CovidVaccinations$.new_vaccinations)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS VACC_SUMMATION
FROM [PORTFOLIO PROJECT]..CovidDeaths$
join [PORTFOLIO PROJECT]..CovidVaccinations$
	on CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
WHERE CovidDeaths$.continent IS NOT NULL
ORDER BY 2,3

--TEMP TABLE for percent vaccinated vs population

drop table if exists #PERCENTPOPVACCINATED
CREATE TABLE #PERCENTPOPVACCINATED
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
vacc_summation numeric
)
insert into #PERCENTPOPVACCINATED
select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations, SUM(CONVERT(INT, CovidVaccinations$.new_vaccinations)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS VACC_SUMMATION
FROM [PORTFOLIO PROJECT]..CovidDeaths$
join [PORTFOLIO PROJECT]..CovidVaccinations$
	on CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
WHERE CovidDeaths$.continent IS NOT NULL

select *, (vacc_summation/population)*100
from #PERCENTPOPVACCINATED


--view for visualizations--


create view PERCENTPOPVACCINATED as
select CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population, CovidVaccinations$.new_vaccinations, SUM(CONVERT(INT, CovidVaccinations$.new_vaccinations)) OVER (PARTITION BY CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.date) AS VACC_SUMMATION
FROM [PORTFOLIO PROJECT]..CovidDeaths$
join [PORTFOLIO PROJECT]..CovidVaccinations$
	on CovidDeaths$.location = CovidVaccinations$.location
	and CovidDeaths$.date = CovidVaccinations$.date
WHERE CovidDeaths$.continent IS NOT NULL

select *
from PERCENTPOPVACCINATED
