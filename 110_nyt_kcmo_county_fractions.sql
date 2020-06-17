#standardSQL

-- Now that we have aggregated KCMO blockgroups on a per-county basis,
-- Create a small table that gives the portion of the population/land that is in/out of Kansas City for each county.
CREATE
OR REPLACE TABLE public.nyt_kcmo_county_fractions AS
SELECT
  ANY_VALUE(county.state_fips_code) as state_fips_code,
  ANY_VALUE(county.county_fips_code) as county_fips_code,
  sum(agg_bg.total_pop) as kc_total_pop,
  sum(agg_bg.total_pop) / sum(county_acs.total_pop) as fraction_kc_pop,
  1 - sum(agg_bg.total_pop) / sum(county_acs.total_pop) as fraction_non_kc_pop,
  sum(agg_bg.area_land_meters) / sum(county.area_land_meters) as fraction_kc_land,
  1 - sum(agg_bg.area_land_meters) / sum(county.area_land_meters) as fraction_non_kc_land,
FROM `covid-project-275201`.public.nyt_kcmo_agg_bg_by_county agg_bg
    LEFT JOIN `bigquery-public-data.utility_us.us_county_area` county on agg_bg.state_fips_code=county.state_fips_code and agg_bg.county_fips_code=county.county_fips_code
    LEFT JOIN `bigquery-public-data.census_bureau_acs.county_2018_5yr` county_acs on county.geo_id=county_acs.geo_id
GROUP BY county.county_fips_code;