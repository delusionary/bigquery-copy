#standardSQL
-- Create the final Kansas City "County" by joining in the election context data we estimated earlier.
create or replace view public.nyt_kc_county
as
select
  kc.*,
  ec.* except(state_fips_code, county_fips_code)
from `covid-project-275201`.public.nyt_kc_county_temp_1 kc
  left join `covid-project-275201`.public.kc_election_context ec on kc.state_fips_code=ec.state_fips_code and kc.county_fips_code=ec.county_fips_code;