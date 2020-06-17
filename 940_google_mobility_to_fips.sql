#standardSQL
-- Google Mobility data does not include FIPS codes; instead it gives state and county names.
-- Here we create a table that maps sub_region_1 and sub_region_2 values to county FIPS codes.
-- We do some ad hoc patches to deal with exceptions to county naming conventions.
create or replace view public.google_mobility_to_fips as
select distinct country_region, sub_region_1, sub_region_2, combined_fips_code from `bigquery-public-data.covid19_google_mobility.mobility_report`
  left join public.county_area_acs county on
    -- Mostly we try to join by adding (County|Parish|Borough) to the GIS/ACS/Election county_name to match the Google data.
    -- We disallow St. Louis, MO, though, because there are two county_names 'St. Louis' in Missouri.
    --
    -- There are 11 values for sub_region_2, consisting of rows in Maryland (Baltimore) and Virginia (Several) where Google data
    -- has both "X" and "X County". I join only on the "X County" rows, leaving the "X" rows unmatched.
    country_region_code='US' and
    (sub_region_1=county.state_name and sub_region_2
      in (concat(county_name, ' County'), concat(county_name, ' Parish'), concat(county_name, ' Borough'))
      #and (not state_name='Missouri' and county_name='St. Louis')
    )
    or
    -- Match up some Alaskan jurisdictions that don't end in "County"
    (sub_region_1=state_name and state_name='Alaska' and county_name=sub_region_2 and sub_region_2 in (
      'Ketchikan Gateway', 'Juneau', 'Kodiak Island', 'Matanuska-Susitna', 'North Slope', 'Sitka', 'Southeast Fairbanks', 'Valdez-Cordova',
      'Bethel', 'Fairbanks North Star', 'Anchorage')
    )
    or
    -- Match up some Virginia jurisdictions that don't end in "County"
    (sub_region_1=state_name and state_name='Virginia' and county_name=sub_region_2 and sub_region_2 in (
      'Portsmouth', 'Alexandria', 'Charlottesville', 'Chesapeake', 'Colonial Heights', 'Danville', 'Bristol',
      'Buena Vista', 'Covington', 'Emporia', 'Falls Church', 'Galax', 'Hampton', 'Hopewell', 'Lexington',
      'Lynchberg', 'Manassas', 'Manassas Park', 'Martinsville', 'Norfolk', 'Norton', 'Petersburg', 'Poquoson',
      'Radford', 'Salem', 'Staunton', 'Suffolk', 'Virginia Beach', 'Waynesboro', 'Williamsburg', 'Winchester')
    )
    or
    -- Deal with St. Louis manually.
    -- Visit https://bigquerygeoviz.appspot.com?shareid=EEmbMx8FvKq9LB34ATJq to look at why I matched it this way.
    -- Match 'St. Louis' in MO to FIPS code 29510
    (sub_region_1=state_name and state_name='Missouri' and sub_region_2='St. Louis' and combined_fips_code='29510')
    or
    -- Match 'St. Louis County'
    (sub_region_1=state_name and state_name='Missouri' and sub_region_2='St. Louis County' and combined_fips_code='29189')

where combined_fips_code is not null;