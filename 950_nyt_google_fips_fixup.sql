#standardSQL

-- Create a mapping table that maps from NYT fips codes, fixed up
-- with our synthetic counties, to google (country_region, sub_region_1, sub_region_2) tuples.
-- We will usea proxy county for NYC and KCMO
create or replace view public.nyt_google_fips_fixup as
  select * from `covid-project-275201.public.google_mobility_to_fips`
union all
  (select "US" as country_region, "Missouri" as sub_region_1, "Cass County" as sub_region_2, "29037" as combined_fips_code)
union all
  (select "US" as country_region, "Missouri" as sub_region_1, "Clay County" as sub_region_2, "29047" as combined_fips_code)
union all
  (select "US" as country_region, "Missouri" as sub_region_1, "Platte County" as sub_region_2, "29165" as combined_fips_code)
union all
  (select "US" as country_region, "Missouri" as sub_region_1, "Jackson County" as sub_region_2, "29095" as combined_fips_code)
union all
  -- Use New York County as a proxy for New York City
  (select "US" as country_region, "New York" as sub_region_1, "New York County" as sub_region_2, "1000000" as combined_fips_code)
union all
  -- Use Clay County as a proxy for Kansas City
  (select "US" as country_region, "Missouri" as sub_region_1, "Clay County" as sub_region_2, "29047" as combined_fips_code)
;
