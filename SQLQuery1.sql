SELECT * FROM [1.0portflioproject]..['covid_vaccinations]
ORDER BY 3,4
SELECT * FROM [1.0portflioproject]..covid_deaths
WHERE continent is not NULL
ORDER BY 3,4

--Select data that we will be using

SELECT location,date,total_cases,total_deaths,population
FROM [1.0portflioproject]..covid_deaths
ORDER BY 1,2

--Looking at total cases vs total deaths in Kenya
--Shows likelihood of dying of covid if infected in Kenya

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentage_death
FROM [1.0portflioproject]..covid_deaths
WHERE location like '%Kenya'
ORDER BY 1,2

--Looking at total cases vs population
-- Shows the percentage of population has covid in Kenya

SELECT location,date,total_cases,population,(total_cases/population)*100 as case_load
FROM [1.0portflioproject]..covid_deaths
WHERE location like '%Kenya'
ORDER BY 1,2

--Looking at countries with the highest inffection rates compared to population size

SELECT continent, location, population, MAX (total_cases) as Highest_InfectionRate, Max((total_cases/population))*100 as case_load
FROM [1.0portflioproject]..covid_deaths
--WHERE location like '%Kenya'
GROUP BY continent, location, population
ORDER BY case_load DESC

--Showing countries with the highest death count as per population

SELECT continent, location, MAX (CAST (total_deaths as int)) as TotalDeathCount
FROM [1.0portflioproject]..covid_deaths
WHERE continent is not NULL
GROUP BY continent,location
ORDER BY TotalDeathCount DESC

-- Break down by CONTINENT
-- Highest eath count as per population

SELECT continent, MAX (CAST (total_deaths as int)) as TotalDeathCount
FROM [1.0portflioproject]..covid_deaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


SELECT location, MAX (CAST (total_deaths as int)) as TotalDeathCount
FROM [1.0portflioproject]..covid_deaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as percentage_death
FROM [1.0portflioproject]..covid_deaths
--WHERE location like '%Kenya'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2

--Overal death percentage numbers world wide to date

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as percentage_death
FROM [1.0portflioproject]..covid_deaths
--WHERE location like '%Kenya'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2


--VACCINATIONS

SELECT * FROM [1.0portflioproject]..['covid_vaccinations]
ORDER BY 3,4

SELECT continent,location, date,people_vaccinated,people_fully_vaccinated
FROM [1.0portflioproject]..['covid_vaccinations]

--Kenya's vaccination numbers

SELECT continent,location, date,people_vaccinated,people_fully_vaccinated
FROM [1.0portflioproject]..['covid_vaccinations]
WHERE location like '%Kenya'

--*AS most of the columns ase listed as (nvarchar(255),null) most had to be cast as intergers 

SELECT continent,location, date,MAX (CAST (people_vaccinated AS INT)) 
FROM [1.0portflioproject]..['covid_vaccinations]
--WHERE location like '%Kenya'
GROUP BY location
ORDER BY people_vaccinated


--SELECT continent, location, MAX (CAST (total_vaccinations AS INT)) as Highest_Vaccination, Max(CAST(total_vaccinations AS INT)/CAST(people_vaccinated AS INT))*100 as Vaccination_count
--FROM [1.0portflioproject]..['covid_vaccinations]
----WHERE location like '%Kenya'
--GROUP BY continent, location
--ORDER BY Vaccination_count DESC

SELECT * FROM [1.0portflioproject]..covid_vaccination
ORDER BY 3,4
SELECT * FROM [1.0portflioproject]..covid_deaths

--JOIN BOTH TABLES

SELECT *
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location

--Looking at population vs total vaccination

SELECT dae.continent,dae.date,dae.location,vac.new_vaccinations
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.continent is not NULL
ORDER BY 2,3

--Partition to show the sum of all new cases per day per location

SELECT dae.continent,dae.date,dae.location,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dae.location)
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.continent is not NULL
ORDER BY 2,3

--OR--

SELECT dae.continent,dae.date,dae.location,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dae.location)
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.continent is not NULL
ORDER BY 2,3

--Looking at Kenya's new vaccination numbers compared to the rest of the world

SELECT dae.continent,dae.date,dae.location,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dae.location)
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.location like '%Kenya' AND dae.continent is not NULL
ORDER BY 2,3


SELECT dae.continent,dae.date,dae.location,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dae.location ORDER BY dae.location,dae.date) AS Rolling_VaccinationNumbers
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.continent is not NULL

--Kenya as a case scenario--

SELECT dae.continent,dae.date,dae.location,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dae.location ORDER BY dae.location,dae.date) AS Rolling_VaccinationNumbers
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.location LIKE '%Kenya' and dae.continent is not NULL

--For better understanding of the population VERSUS vaccination we create a CTE

WITH popVSvac (continent, location, population, date, Rolling_VaccinationNumbers, new_vaccinations)
AS
(
SELECT dae.continent, dae.date, dae.location, dae.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dae.location ORDER BY dae.location,dae.date) AS Rolling_VaccinationNumbers
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.continent is not NULL
)
SELECT (Rolling_VaccinationNumbers/population)*100
FROM popVSvac

--**ERROR MESSAGE--Operand data type nvarchar is invalid for divide operator.

--CTE

WITH PopVSvacS (continent, location, population, date, Rolling_VaccinationNumbers, new_vaccinations)
AS
(
SELECT dae.continent, dae.date, dae.location, dae.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dae.location ORDER BY dae.location,dae.date) AS Rolling_VaccinationNumbers
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.continent is not NULL
)
SELECT *,( Rolling_VaccinationNumbers/population)*100
FROM PopVSvacS
 
 -- OR CREATE TABLE
  
 CREATE TABLE #percentage_population_vaccinated
  (
  Continent nvarchar(255),
  Location  nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  Rolling_VaccinationNumbers numeric
  )
  INSERT INTO #percentage_population_vaccinated

  SELECT dae.continent, dae.date, dae.location, dae.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER(PARTITION BY dae.location ORDER BY dae.location,dae.date) AS Rolling_VaccinationNumbers
FROM [1.0portflioproject]..['covid_vaccinations] vac
JOIN [1.0portflioproject]..covid_deaths dae
     ON dae.date = vac.date
	 AND dae.location = vac.location
WHERE dae.continent is not NULL

SELECT (Rolling_VaccinationNumbers/population)*100
FROM #percentage_population_vaccinated

--**error message states..Msg 2714, Level 16, State 6, Line 201
--There is already an object named '#percentage_population_vaccinated' in the database.


 