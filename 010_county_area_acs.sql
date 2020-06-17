#standardSQL
-- Join US county area and geometry data together with American Community Survey 2017 5-year data set.
CREATE
OR REPLACE VIEW public.county_area_acs AS
SELECT
    county.state_fips_code,
    county.county_fips_code,
    CONCAT(county.state_fips_code, county.county_fips_code) as combined_fips_code,
    county.county_gnis_code,
    county.aff_geo_code,
    county.geo_id,
    county.county_name,
    states.state_name,
    states.state_abbreviation,
    county.area_land_meters,
    county.area_water_meters,
    ST_X(ST_CENTROID(county.county_geom)) AS longitude,
    ST_Y(ST_CENTROID(county.county_geom)) AS latitude,
    county.county_geom,
    acs.* except(geo_id),
    election.*
FROM
    `bigquery-public-data.census_bureau_acs.county_2017_5yr` acs
    LEFT JOIN `bigquery-public-data.utility_us.us_county_area` county ON county.geo_id = acs.geo_id
    LEFT JOIN `bigquery-public-data.utility_us.us_states_area` states ON county.state_fips_code = states.state_fips_code
    LEFT JOIN `covid-project-275201.public.election_context_2018` election ON
        safe_cast(county.state_fips_code AS int64) * 1000 + safe_cast(county.county_fips_code AS int64) = election.fips;