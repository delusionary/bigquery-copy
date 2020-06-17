#standardSQL

-- Create a report view that joins the NYT data to the ACS county data.

create or replace view public.nyt_county_report_view as
select
  nyt.*,
  acs.* except(county_fips_code, state_name, county)
from `covid-project-275201.public.nyt_acceleration` nyt
  left join `covid-project-275201.public.nyt_county_union` acs on nyt.county_fips_code=acs.combined_fips_code;