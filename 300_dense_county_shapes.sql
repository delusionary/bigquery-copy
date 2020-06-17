select
  concat(state_fips_code, county_fips_code) as combined_fips_code,
  st_union_agg(blockgroup_geom) as county_geom
from
  `bigquery-public-data.census_bureau_acs.blockgroup_2018_5yr` acs
  left join `bigquery-public-data.geo_census_blockgroups.us_blockgroups_national` bg on acs.geo_id=bg.geo_id
where bg.area_land_meters > 0 and
      (acs.total_pop / (bg.area_land_meters / 2590000)) > 10
group by state_fips_code, county_fips_code
limit 100;
