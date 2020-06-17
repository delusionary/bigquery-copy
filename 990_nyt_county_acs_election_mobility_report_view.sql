#standardSQL

-- Create a grand unified reporting view that includes fields from all the data sources:
-- NYT case data, ACS community survey, and Google mobility data.
create or replace view public.nyt_county_acs_election_mobility_report_view as
select
  nyt.*,
  county.* except(county_fips_code, state_name, county),
  mobility.* except(date)
from
  public.nyt_acceleration nyt
  left join public.nyt_county_acs_election county on nyt.county_fips_code=county.combined_fips_code
  left join public.nyt_google_fips_fixup map on county.combined_fips_code=map.combined_fips_code
  left join `bigquery-public-data.covid19_google_mobility.mobility_report` mobility on mobility.country_region_code=map.country_region_code and mobility.date=nyt.date and
    mobility.sub_region_1=map.sub_region_1 and mobility.sub_region_2=map.sub_region_2