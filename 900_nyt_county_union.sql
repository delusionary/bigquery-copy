#standardSQL
-- Join together the synthetic counties we created to make a single
-- view of all the real and synthetic counties in the US.
-- We materialize this join because this table will not update except to correct errors.
create or replace view public.nyt_county_union as
    select *,
    st_togeojson(county_geom) as geojson
    from `covid-project-275201.public.county_area_acs`
union all
    select *,
    st_togeojson(county_geom) as geojson
    from `covid-project-275201.public.nyt_kc_county`
union all
    select *,
    st_togeojson(county_geom) as geojson
    from `covid-project-275201.public.nyt_kc_mo_trimmed_counties`
union all
    select *,
    st_togeojson(county_geom) as geojson
    from `covid-project-275201.public.nyt_nyc_county`
;