-- Creating Table COVIDDEATHS.
CREATE TABLE CovidDeaths (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population BIGINT,
    total_cases BIGINT,
    new_cases INT,
    new_cases_smoothed INT,
    total_deaths BIGINT,
    new_deaths INT,
    new_deaths_smoothed INT,
    total_cases_per_million FLOAT,
    new_cases_per_million FLOAT,
    new_cases_smoothed_per_million FLOAT,
    total_deaths_per_million FLOAT,
    new_deaths_per_million FLOAT,
    new_deaths_smoothed_per_million FLOAT,
    reproduction_rate FLOAT,
    icu_patients INT,
    icu_patients_per_million FLOAT,
    hosp_patients INT,
    hosp_patients_per_million FLOAT,
    weekly_icu_admissions INT,
    weekly_icu_admissions_per_million FLOAT,
    weekly_hosp_admissions INT,
    weekly_hosp_admissions_per_million FLOAT
);


-- Creating Table COVIDDATA
CREATE TABLE CovidData (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    new_tests INT,
    total_tests BIGINT,
    total_tests_per_thousand FLOAT,
    new_tests_per_thousand FLOAT,
    new_tests_smoothed INT,
    new_tests_smoothed_per_thousand FLOAT,
    positive_rate FLOAT,
    tests_per_case FLOAT,
    tests_units VARCHAR(50),
    total_vaccinations BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations INT,
    new_vaccinations_smoothed INT,
    total_vaccinations_per_hundred FLOAT,
    people_vaccinated_per_hundred FLOAT,
    people_fully_vaccinated_per_hundred FLOAT,
    new_vaccinations_smoothed_per_million FLOAT,
    stringency_index FLOAT,
    population_density FLOAT,
    median_age FLOAT,
    aged_65_older FLOAT,
    aged_70_older FLOAT,
    gdp_per_capita FLOAT,
    extreme_poverty FLOAT,
    cardiovasc_death_rate FLOAT,
    diabetes_prevalence FLOAT,
    female_smokers FLOAT,
    male_smokers FLOAT,
    handwashing_facilities FLOAT,
    hospital_beds_per_thousand FLOAT,
    life_expectancy FLOAT,
    human_development_index FLOAT
);


-- Selecting the data  that we are going to use
SELECT location, DATE, total_cases, new_cases, Total_deaths, Population
FROM Coviddeaths
ORDER BY 1,2


-- Shows likelihood of dying if you contract with covid in united states
-- Looking at total cases vs total deaths
-- Used where func to put the condition
-- used LIKE func to pull out the information for a specific region  i.e unitied states
SELECT location, total_cases, new_cases, Total_deaths, 
       (total_deaths/total_cases)*100 AS Deathpercentage
FROM Coviddeaths
WHERE location LIKE '%STATES%'
ORDER BY 1,2


-- looking at total_cases v/s population	
-- Shows what percent of population got covid
SELECT location, date, total_cases, total_deaths, population,
       (CAST(total_cases AS FLOAT) / population) * 100 AS percentagepop_infected 
FROM coviddeaths
WHERE location LIKE '%States%'
ORDER BY 1, 2;


-- looking at countries at highest infection rate compared to population
SELECT location, 
       date, 
       MAX(total_cases) AS Highestinfectedcount, 
       population,
       (CAST(MAX(total_cases) AS FLOAT) / population) * 100 AS Deathpercentage
FROM Coviddeaths
GROUP BY location, date, population
ORDER BY location, date;


-- showing countries with the highest death count per population
SELECT location, 
       CAST(MAX(total_deaths) AS INT) AS totaldeathcount
FROM Coviddeaths
-- WHERE location LIKE '%russia%'
GROUP BY location
ORDER BY totaldeathcount desc;


-- Showing continents with the highest death count per population 
SELECT Continent, 
       CAST(MAX(total_deaths) AS INT) AS totaldeathcount
FROM Coviddeaths
-- WHERE location LIKE '%russia%'
GROUP BY continent 
ORDER BY totaldeathcount desc;


--Global Numbers 
SELECT date, SUM(new_cases) AS TOTALNEWCASES,
       SUM(new_deaths) AS TOTALNEWDEATHS,
	   (SUM(CAST(new_deaths as INT))/SUM(New_cases))*100 AS DeathPercentage
FROM Coviddeaths
WHERE CONTINENT IS NOT NULL
GROUP BY Date
ORDER BY 1,2

-- Looking for total population VS Vaccination
SELECT D.continent, 
       D.location, 
       D.date, 
       D.population, 
       V.new_vaccinations,
       SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS rollingpeoplevaccinated
FROM Coviddeaths D
JOIN Coviddata V
  ON D.location = V.location
  AND D.date = V.date
WHERE D.continent IS NOT NULL 
ORDER BY 1, 2, 3;


-- Creating CTE
WITH CovidVaccinationData AS (
    SELECT D.continent, 
           D.location, 
           D.date, 
           D.population, 
           V.new_vaccinations
    FROM Coviddeaths D
    JOIN Coviddata V
      ON D.location = V.location
      AND D.date = V.date
    WHERE D.continent IS NOT NULL
)
SELECT continent, 
       location, 
       date, 
       population, 
       new_vaccinations,
       SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS rollingpeoplevaccinated
FROM CovidVaccinationData
ORDER BY 1, 2, 3;

  
-- Creating Temp table
-- Step 1: Create the temporary table
CREATE TABLE percentpopulationvaccinated (
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population BIGINT,
    new_vaccination BIGINT,
    rollingpeoplevaccinated BIGINT
);

-- Step 2: Insert data into the temporary table
INSERT INTO percentpopulationvaccinated (continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
WITH CovidVaccinationData AS (
    SELECT D.continent, 
           D.location, 
           D.date, 
           D.population, 
           V.new_vaccinations
    FROM Coviddeaths D
    JOIN Coviddata V
      ON D.location = V.location
      AND D.date = V.date
    WHERE D.continent IS NOT NULL
)
SELECT continent, 
       location, 
       date, 
       population, 
       new_vaccinations,
       SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS rollingpeoplevaccinated
FROM CovidVaccinationData
ORDER BY 1, 2, 3;


-- Creating view to store data for visualization later
CREATE VIEW percentvaccinated AS
SELECT D.continent, 
       D.location, 
       D.date, 
       D.population, 
       V.new_vaccinations,
       SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS rollingpeoplevaccinated
FROM Coviddeaths D
JOIN Coviddata V
  ON D.location = V.location
  AND D.date = V.date
WHERE D.continent IS NOT NULL 
ORDER BY 1, 2, 3;

-- VIEW view
SELECT*
FROM PERCENTVACCINATED


