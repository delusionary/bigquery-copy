#standardSQL

-- Create a view that calculates daily increments and
-- trailing 7-day totals over several weeks
create or replace view public.nyt_7_day_counts as
select
    nyt.*,
    confirmed_cases - LAG(confirmed_cases)
      OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS new_confirmed_cases,

    confirmed_cases - LAG(confirmed_cases, 7)
      OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_0_7_days_confirmed_cases,
    LAG(confirmed_cases, 7)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC)
      - LAG(confirmed_cases, 14)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_7_14_days_confirmed_cases,
   LAG(confirmed_cases, 14)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC)
      - LAG(confirmed_cases, 21)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_14_21_days_confirmed_cases,
   LAG(confirmed_cases, 21)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC)
      - LAG(confirmed_cases, 28)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_21_28_days_confirmed_cases,

    deaths - LAG(deaths)
      OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS new_deaths,
    deaths - LAG(deaths, 7)
      OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_0_7_days_deaths,
    LAG(deaths, 7)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC)
      - LAG(deaths, 14)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_7_14_days_deaths,
   LAG(confirmed_cases, 14)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC)
      - LAG(confirmed_cases, 21)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_14_21_days_deaths,
   LAG(deaths, 21)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC)
      - LAG(deaths, 28)
        OVER (PARTITION BY nyt.state_name, county ORDER BY date ASC) AS trailing_21_28_days_deaths
FROM
  `covid-project-275201.public.nyt_county_fips_fixup` nyt;

CREATE OR REPLACE view public.nyt_acceleration AS
SELECT
  *,
  safe_divide(trailing_0_7_days_confirmed_cases, trailing_7_14_days_confirmed_cases) as trailing_0_14_cases_acceleration,
  safe_divide(trailing_7_14_days_confirmed_cases, trailing_14_21_days_confirmed_cases) as trailing_7_21_cases_acceleration,
  safe_divide(trailing_14_21_days_confirmed_cases, trailing_21_28_days_confirmed_cases) as trailing_14_28_cases_acceleration,
  safe_divide(trailing_0_7_days_deaths, trailing_7_14_days_deaths) as trailing_0_14_deaths_acceleration,
  safe_divide(trailing_7_14_days_deaths, trailing_14_21_days_deaths) as trailing_7_21_deaths_acceleration,
  safe_divide(trailing_14_21_days_deaths, trailing_21_28_days_deaths) as trailing_14_28_deaths_acceleration,
  rank() over (partition by date order by confirmed_cases desc) as rank_total_cases,
  rank() over (partition by date order by new_confirmed_cases desc) as rank_new_cases,
  rank() over (partition by date order by deaths desc) as rank_total_deaths,
  rank() over (partition by date order by new_deaths desc) as rank_new_deaths,
#  rank() over (partition by date order by total_pop asc) as rank_total_pop,
#  rank() over (order by area_land_meters asc) as rank_land_area,
FROM `covid-project-275201.public.nyt_7_day_counts`;