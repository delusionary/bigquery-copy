# Enhanced NYT COVID-19 Data

## Overview

These are scripts that populate my reporting schema for county-level COVID-19 from the New York Times. This data set is publicly available through [BigQuery](https://console.cloud.google.com/bigquery?project=covid-project-275201&page=project); this repository exists largely to document how it is built.

There is a more narrative description of how the schema was created at insert link here.

If you wish to recreate the schema in your own project, you will need to replace ```covid-project-275201`.public`` with your own project and data set, except for:

 * ```covid-project-275201`.public.mit_election_context_2018 election`` I uploaded this from the CSV below. You can make a copy or upload your own.
 * ```covid-project-275201`.public.kansas_city_blockgroups`` I created from a long-lost custom query in BigQueryGeoViz. The only way to get this is to copy it.

The reporting schema joins together several data sources:

### New York Times COVID-19 Data

[New York Times Covid confirmed cases and deaths county-level data](http://https://github.com/nytimes/covid-19-data)

Google hosts a public version of this data that you can access with ``SELECT * FROM `bigquery-public-data.covid19_nyt.us_counties` LIMIT 10``

### Census Bureau American Community Survey.

The Census Bureau's [American Community Survey](https://www.census.gov/programs-surveys/acs) provides very local demographic data on 40 different topics. I use 5-year estimates from 2017 at the county and blockgroup levels.

Google hosts a public version of this data that you can access with ``SELECT * FROM `bigquery-public-data.census_bureau_acs.county_2017_5yr` LIMIT 10`` and at ``SELECT * FROM `bigquery-public-data.census_bureau_acs.blockgroup_2017_5yr` LIMIT 10``

### MIT Election Context

[MIT 2018 Election Context](https://github.com/MEDSL/2018-elections-unoffical/blob/master/election-context-2018.md)

I uploaded this via CSV to BigQuery. You can access my copy with ``SELECT * FROM `covid-project-275201.public.election_context_2018` LIMIT 10`` or upload your own copy.

### Google Mobility Report

[Google Mobility Report](https://www.google.com/covid19/mobility/)

Google hosts a public version of this data that you can access with ``SELECT * FROM `bigquery-public-data`.covid19_google_mobility.mobility_report LIMIT 10``.

## Run-once scripts

The scripts below create views on top of public data sets. To recreate the reporting schema, you should run each of these scripts in order, as each builds on a view from the previous script. The name of each file is the name of the view it creates, prepended with a sequence number.

### 000_election_context_2018.sql

Create a view that slightly transforms MIT's election data, replacing the string "NA" with NULL values.

### 010_county_area_acs.sql

Joins US county area and geometry data together with American Community Survey 2017 5-year data set.

### 100_nyt_kcmo_agg_bg_by_county.sql

Given a list of blockgroups that approximately capture the municipality of Kansas City, MO, this views groups them by county and aggregates their ACS 2018 5-year data, geometry, and land/water area.

This view depends on a table of blockgroup IDs that I created myself in BigQuery. For this view to work, you must either copy `covid-project-275201.public.kansas_city_blockgroups` to your own dataset, or leave the reference unchanged.

### 110_nyt_kcmo_county_fractions.sql

This view gives the portion of the population and people that are in KC, MO, and outside KC, MO for each of the counties that intersect the city. It will be used later for apportioning counted items between one or the other when we have no better guide to how they are distributed--i.e., for MIT election results.

### 120_kc_election_context.sql

Multiply the values in the election data table by values in nyt_kmcmo_county_fgo/tions to estimate the number of each kind of voter that lives in Kansas City. We don't have MIT numbers for the city itself, so this estimate will have to do.

### 130_nyt_kc_county_temp_1.sql

Aggregate blockgroups to approximately capture the municipality of Kansas City, MO. Join in in blockgroup geometry, land/water area, and ACS 2018 5-year data.

### 140_nyt_kc_county.sql

Create the final Kansas City "County" by joining in the election context data we estimated earlier.

### 150_nyt_kc_mo_trimmed_counties.sql

Subtract the portions of each county that comprises Kansas City from the values for the county as a whole. Where medians or percentages are considered, we leave those values untouched, assuming that aggregates for the whole county are representative enough of the values for the non-KC portions.

### 200_nyt_counties.sql

Aggregate Kings, Queens, Bronx, Richmond, and New York counties into a single county. Joins in county geometry and land/water area, ACS 2018 5-year data, and MIT election context data.

### 900_nyt_county_union.sql

Join together the synthetic counties we created to make a single view of all the real and synthetic counties in the US. We materialize this join because this table will not update except to correct errors.

### 910_nyt_county_fips_fixup.sql

Patch the county_fips_code on the NYT county report to join to our synthetic counties.

### 920_nyt_7_day_averages.sql

Calculates daily increments and trailing 7-day totals for NYT county data over several weeks.

### 930_nyt_acceleration.sql

Use 7-day totals for successive weeks to calculate week-over-week acceleration metrics.

### 940_google_mobility_to_fips.sql

Google Mobility data does not include FIPS codes; instead it gives state and county names.
Here we create a table that maps sub_region_1 and sub_region_2 values to county FIPS codes.
We do some ad hoc patches to deal with exceptions to county naming conventions.

### 950_nyt_google_fips_fixup.sql

Create a mapping from NYT fips codes, fixed up with our synthetic counties, to google (country_region, sub_region_1, sub_region_2) tuples. I don't try to do any complex estimation here. Instead, I just use a proxy county for each of our aggregate counties. For KC trimmed counties I use the values for the actual counties. For Kansas City, I use Clay county, the densest of the four counties comprising the city, and for New York City I use New York County.

### 980_nyt_county_report_view.sql

Create a report view that joins the NYT data to the ACS county and MIT election context data using the combined_fips_field.

### 990_nyt_county_acs_election_mobility_report_view.sql

Create a grand unified reporting view that includes fields from all the data sources: NYT case data, ACS community survey, and Google mobility data.

## Scheduled Scripts

These scripts materialize results from views defined above, and can be run on a regular basis to keep tables up to date.

### S030_nyt_county_acs_election_mobility_report.sql

Materializes nyt_county_acs_election_mobility_report_view. I run this every 6 hours.

### S_000_nyt_county_report.sql
### S_010_nyt_decorated.sql
### S_020_nyt_county_acs_election.sql
