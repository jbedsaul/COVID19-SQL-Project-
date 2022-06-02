/*
Covid 19 Data  
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Starting Data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Percentage of Population that Contracted COVID

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKDOWN BY CONTINENT

-- Contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Percentage of Population w/ at least one Covid shot

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null 
order by 2,3


-- Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Temp Table to perform Calculation on Partition By 

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

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data, visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null 