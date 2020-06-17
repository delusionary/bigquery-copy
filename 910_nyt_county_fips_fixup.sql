#standardSQL

-- Patch the county_fips_code on the NYT county report to join
-- to our aggregate counties.
create or replace view public.nyt_county_fips_fixup as
select
  * except(county_fips_code),
  case
    when state_name='New York' and county='New York City' then '1000000'
    when state_name='Missouri' and county='Kansas City' then '2000000'
    when county_fips_code in ('29037', '29165', '29095', '29047') then CONCAT(county_fips_code,'000000')
    else county_fips_code
    end as county_fips_code
from `bigquery-public-data.covid19_nyt.us_counties`;