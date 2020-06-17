#standardSQL

-- Use 7-day totals for successive weeks to calculate week-over-week acceleration metrics.
CREATE OR REPLACE view public.nyt_acceleration AS
SELECT
  *,
  cast(county_fips_code as string) as combined_fips_code,
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