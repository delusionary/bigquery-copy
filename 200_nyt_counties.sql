#standardSQL

-- Aggregate Kings, Queens, Bronx, Richmond, and New York counties into a single county;
-- joins in county geometry and land/water area, ACS 2018 5-year data, and
-- MIT election context data uploaded via CSV from:
-- https://github.com/MEDSL/2018-elections-unoffical/blob/master/election-context-2018.csv
CREATE OR REPLACE VIEW public.nyt_nyc_county AS
SELECT
    ANY_VALUE(state_fips_code) as state_fips_code,
    "1000000" AS county_fips_code,
    "1000000" AS combined_fips_code,
    -- Invalid FIPS code should make a good join key.
    STRING_AGG(county_gnis_code) AS county_gnis_code,
    STRING_AGG(aff_geo_code) AS aff_geo_code,
    STRING_AGG(geo_id) AS geo_id,
    "New York City" AS county_name,
    "New York" AS state_name,
    "NY" AS state_abbreviation,
    SUM(area_land_meters) AS area_land_meters,
    SUM(area_water_meters) AS area_water_meters,
    ST_X(ST_CENTROID_AGG(county_geom)) AS longitude,
    ST_Y(ST_CENTROID_AGG(county_geom)) AS latitude,
    ST_UNION_AGG(county_geom) AS county_geom,
    SUM(nonfamily_households) AS nonfamily_households,
    SUM(family_households) AS family_households,
    SUM(median_year_structure_built * total_pop) / SUM(total_pop) AS median_year_structure_built,
    SUM(rent_burden_not_computed) AS rent_burden_not_computed,
    SUM(rent_over_50_percent) AS rent_over_50_percent,
    SUM(rent_40_to_50_percent) AS rent_40_to_50_percent,
    SUM(rent_35_to_40_percent) AS rent_35_to_40_percent,
    SUM(rent_30_to_35_percent) AS rent_30_to_35_percent,
    SUM(rent_25_to_30_percent) AS rent_25_to_30_percent,
    SUM(rent_20_to_25_percent) AS rent_20_to_25_percent,
    SUM(rent_15_to_20_percent) AS rent_15_to_20_percent,
    SUM(rent_10_to_15_percent) AS rent_10_to_15_percent,
    SUM(rent_under_10_percent) AS rent_under_10_percent,
    SUM(total_pop) AS total_pop,
    SUM(male_pop) AS male_pop,
    SUM(female_pop) AS female_pop,
    SUM(median_age) AS median_age,
    SUM(white_pop) AS white_pop,
    SUM(black_pop) AS black_pop,
    SUM(asian_pop) AS asian_pop,
    SUM(hispanic_pop) AS hispanic_pop,
    SUM(amerindian_pop) AS amerindian_pop,
    SUM(other_race_pop) AS other_race_pop,
    SUM(two_or_more_races_pop) AS two_or_more_races_pop,
    SUM(not_hispanic_pop) AS not_hispanic_pop,
    SUM(commuters_by_public_transportation) AS commuters_by_public_transportation,
    SUM(households) AS households,
    SUM(median_income * total_pop) / SUM(total_pop) AS median_income,
    SUM(income_per_capita * total_pop) / SUM(total_pop) / SUM(total_pop) AS income_per_capita,
    SUM(housing_units) AS housing_units,
    SUM(vacant_housing_units) AS vacant_housing_units,
    SUM(vacant_housing_units_for_rent) AS vacant_housing_units_for_rent,
    SUM(vacant_housing_units_for_sale) AS vacant_housing_units_for_sale,
    SUM(median_rent) AS median_rent,
    SUM(percent_income_spent_on_rent * total_pop) / SUM(total_pop) AS percent_income_spent_on_rent,
    SUM(owner_occupied_housing_units) AS owner_occupied_housing_units,
    SUM(million_dollar_housing_units) AS million_dollar_housing_units,
    SUM(mortgaged_housing_units) AS mortgaged_housing_units,
    SUM(families_with_young_children) AS families_with_young_children,
    SUM(two_parent_families_with_young_children) AS two_parent_families_with_young_children,
    SUM(
        two_parents_in_labor_force_families_with_young_children
    ) AS two_parents_in_labor_force_families_with_young_children,
    SUM(
        two_parents_father_in_labor_force_families_with_young_children
    ) AS two_parents_father_in_labor_force_families_with_young_children,
    SUM(
        two_parents_mother_in_labor_force_families_with_young_children
    ) AS two_parents_mother_in_labor_force_families_with_young_children,
    SUM(
        two_parents_not_in_labor_force_families_with_young_children
    ) AS two_parents_not_in_labor_force_families_with_young_children,
    SUM(one_parent_families_with_young_children) AS one_parent_families_with_young_children,
    SUM(
        father_one_parent_families_with_young_children
    ) AS father_one_parent_families_with_young_children,
    SUM(
        father_in_labor_force_one_parent_families_with_young_children
    ) AS father_in_labor_force_one_parent_families_with_young_children,
    SUM(commute_10_14_mins) AS commute_10_14_mins,
    SUM(commute_15_19_mins) AS commute_15_19_mins,
    SUM(commute_20_24_mins) AS commute_20_24_mins,
    SUM(commute_25_29_mins) AS commute_25_29_mins,
    SUM(commute_30_34_mins) AS commute_30_34_mins,
    SUM(commute_45_59_mins) AS commute_45_59_mins,
    SUM(aggregate_travel_time_to_work) AS aggregate_travel_time_to_work,
    SUM(income_less_10000) AS income_less_10000,
    SUM(income_10000_14999) AS income_10000_14999,
    SUM(income_15000_19999) AS income_15000_19999,
    SUM(income_20000_24999) AS income_20000_24999,
    SUM(income_25000_29999) AS income_25000_29999,
    SUM(income_30000_34999) AS income_30000_34999,
    SUM(income_35000_39999) AS income_35000_39999,
    SUM(income_40000_44999) AS income_40000_44999,
    SUM(income_45000_49999) AS income_45000_49999,
    SUM(income_50000_59999) AS income_50000_59999,
    SUM(income_60000_74999) AS income_60000_74999,
    SUM(income_75000_99999) AS income_75000_99999,
    SUM(income_100000_124999) AS income_100000_124999,
    SUM(income_125000_149999) AS income_125000_149999,
    SUM(income_150000_199999) AS income_150000_199999,
    SUM(income_200000_or_more) AS income_200000_or_more,
    SUM(
        renter_occupied_housing_units_paying_cash_median_gross_rent * total_pop
    ) / SUM(total_pop) AS renter_occupied_housing_units_paying_cash_median_gross_rent,
    SUM(
        owner_occupied_housing_units_lower_value_quartile * total_pop
    ) / SUM(total_pop) AS owner_occupied_housing_units_lower_value_quartile,
    SUM(
        owner_occupied_housing_units_median_value * total_pop
    ) / SUM(total_pop) AS owner_occupied_housing_units_median_value,
    SUM(
        owner_occupied_housing_units_upper_value_quartile * total_pop
    ) / SUM(total_pop) AS owner_occupied_housing_units_upper_value_quartile,
    SUM(married_households) AS married_households,
    SUM(occupied_housing_units) AS occupied_housing_units,
    SUM(housing_units_renter_occupied) AS housing_units_renter_occupied,
    SUM(dwellings_1_units_detached) AS dwellings_1_units_detached,
    SUM(dwellings_1_units_attached) AS dwellings_1_units_attached,
    SUM(dwellings_2_units) AS dwellings_2_units,
    SUM(dwellings_3_to_4_units) AS dwellings_3_to_4_units,
    SUM(dwellings_5_to_9_units) AS dwellings_5_to_9_units,
    SUM(dwellings_10_to_19_units) AS dwellings_10_to_19_units,
    SUM(dwellings_20_to_49_units) AS dwellings_20_to_49_units,
    SUM(dwellings_50_or_more_units) AS dwellings_50_or_more_units,
    SUM(mobile_homes) AS mobile_homes,
    SUM(housing_built_2005_or_later) AS housing_built_2005_or_later,
    SUM(housing_built_2000_to_2004) AS housing_built_2000_to_2004,
    SUM(housing_built_1939_or_earlier) AS housing_built_1939_or_earlier,
    SUM(male_under_5) AS male_under_5,
    SUM(male_5_to_9) AS male_5_to_9,
    SUM(male_10_to_14) AS male_10_to_14,
    SUM(male_15_to_17) AS male_15_to_17,
    SUM(male_18_to_19) AS male_18_to_19,
    SUM(male_20) AS male_20,
    SUM(male_21) AS male_21,
    SUM(male_22_to_24) AS male_22_to_24,
    SUM(male_25_to_29) AS male_25_to_29,
    SUM(male_30_to_34) AS male_30_to_34,
    SUM(male_35_to_39) AS male_35_to_39,
    SUM(male_40_to_44) AS male_40_to_44,
    SUM(male_45_to_49) AS male_45_to_49,
    SUM(male_50_to_54) AS male_50_to_54,
    SUM(male_55_to_59) AS male_55_to_59,
    SUM(male_60_61) AS male_60_61,
    SUM(male_62_64) AS male_62_64,
    SUM(male_65_to_66) AS male_65_to_66,
    SUM(male_67_to_69) AS male_67_to_69,
    SUM(male_70_to_74) AS male_70_to_74,
    SUM(male_75_to_79) AS male_75_to_79,
    SUM(male_80_to_84) AS male_80_to_84,
    SUM(male_85_and_over) AS male_85_and_over,
    SUM(female_under_5) AS female_under_5,
    SUM(female_5_to_9) AS female_5_to_9,
    SUM(female_10_to_14) AS female_10_to_14,
    SUM(female_15_to_17) AS female_15_to_17,
    SUM(female_18_to_19) AS female_18_to_19,
    SUM(female_20) AS female_20,
    SUM(female_21) AS female_21,
    SUM(female_22_to_24) AS female_22_to_24,
    SUM(female_25_to_29) AS female_25_to_29,
    SUM(female_30_to_34) AS female_30_to_34,
    SUM(female_35_to_39) AS female_35_to_39,
    SUM(female_40_to_44) AS female_40_to_44,
    SUM(female_45_to_49) AS female_45_to_49,
    SUM(female_50_to_54) AS female_50_to_54,
    SUM(female_55_to_59) AS female_55_to_59,
    SUM(female_60_to_61) AS female_60_to_61,
    SUM(female_62_to_64) AS female_62_to_64,
    SUM(female_65_to_66) AS female_65_to_66,
    SUM(female_67_to_69) AS female_67_to_69,
    SUM(female_70_to_74) AS female_70_to_74,
    SUM(female_75_to_79) AS female_75_to_79,
    SUM(female_80_to_84) AS female_80_to_84,
    SUM(female_85_and_over) AS female_85_and_over,
    SUM(white_including_hispanic) AS white_including_hispanic,
    SUM(black_including_hispanic) AS black_including_hispanic,
    SUM(amerindian_including_hispanic) AS amerindian_including_hispanic,
    SUM(asian_including_hispanic) AS asian_including_hispanic,
    SUM(commute_5_9_mins) AS commute_5_9_mins,
    SUM(commute_35_39_mins) AS commute_35_39_mins,
    SUM(commute_40_44_mins) AS commute_40_44_mins,
    SUM(commute_60_89_mins) AS commute_60_89_mins,
    SUM(commute_90_more_mins) AS commute_90_more_mins,
    SUM(households_retirement_income) AS households_retirement_income,
    SUM(armed_forces) AS armed_forces,
    SUM(civilian_labor_force) AS civilian_labor_force,
    SUM(employed_pop) AS employed_pop,
    SUM(unemployed_pop) AS unemployed_pop,
    SUM(not_in_labor_force) AS not_in_labor_force,
    SUM(pop_16_over) AS pop_16_over,
    SUM(pop_in_labor_force) AS pop_in_labor_force,
    SUM(asian_male_45_54) AS asian_male_45_54,
    SUM(asian_male_55_64) AS asian_male_55_64,
    SUM(black_male_45_54) AS black_male_45_54,
    SUM(black_male_55_64) AS black_male_55_64,
    SUM(hispanic_male_45_54) AS hispanic_male_45_54,
    SUM(hispanic_male_55_64) AS hispanic_male_55_64,
    SUM(white_male_45_54) AS white_male_45_54,
    SUM(white_male_55_64) AS white_male_55_64,
    SUM(bachelors_degree_2) AS bachelors_degree_2,
    SUM(bachelors_degree_or_higher_25_64) AS bachelors_degree_or_higher_25_64,
    SUM(children) AS children,
    SUM(children_in_single_female_hh) AS children_in_single_female_hh,
    SUM(commuters_by_bus) AS commuters_by_bus,
    SUM(commuters_by_car_truck_van) AS commuters_by_car_truck_van,
    SUM(commuters_by_carpool) AS commuters_by_carpool,
    SUM(commuters_by_subway_or_elevated) AS commuters_by_subway_or_elevated,
    SUM(commuters_drove_alone) AS commuters_drove_alone,
    SUM(different_house_year_ago_different_city) AS different_house_year_ago_different_city,
    SUM(different_house_year_ago_same_city) AS different_house_year_ago_same_city,
    SUM(
        employed_agriculture_forestry_fishing_hunting_mining
    ) AS employed_agriculture_forestry_fishing_hunting_mining,
    SUM(
        employed_arts_entertainment_recreation_accommodation_food
    ) AS employed_arts_entertainment_recreation_accommodation_food,
    SUM(employed_construction) AS employed_construction,
    SUM(employed_education_health_social) AS employed_education_health_social,
    SUM(employed_finance_insurance_real_estate) AS employed_finance_insurance_real_estate,
    SUM(employed_information) AS employed_information,
    SUM(employed_manufacturing) AS employed_manufacturing,
    SUM(employed_other_services_not_public_admin) AS employed_other_services_not_public_admin,
    SUM(employed_public_administration) AS employed_public_administration,
    SUM(employed_retail_trade) AS employed_retail_trade,
    SUM(employed_science_management_admin_waste) AS employed_science_management_admin_waste,
    SUM(
        employed_transportation_warehousing_utilities
    ) AS employed_transportation_warehousing_utilities,
    SUM(employed_wholesale_trade) AS employed_wholesale_trade,
    SUM(female_female_households) AS female_female_households,
    SUM(four_more_cars) AS four_more_cars,
    SUM(gini_index) AS gini_index,
    SUM(graduate_professional_degree) AS graduate_professional_degree,
    SUM(group_quarters) AS group_quarters,
    SUM(high_school_including_ged) AS high_school_including_ged,
    SUM(households_public_asst_or_food_stamps) AS households_public_asst_or_food_stamps,
    SUM(in_grades_1_to_4) AS in_grades_1_to_4,
    SUM(in_grades_5_to_8) AS in_grades_5_to_8,
    SUM(in_grades_9_to_12) AS in_grades_9_to_12,
    SUM(in_school) AS in_school,
    SUM(in_undergrad_college) AS in_undergrad_college,
    SUM(less_than_high_school_graduate) AS less_than_high_school_graduate,
    SUM(male_45_64_associates_degree) AS male_45_64_associates_degree,
    SUM(male_45_64_bachelors_degree) AS male_45_64_bachelors_degree,
    SUM(male_45_64_graduate_degree) AS male_45_64_graduate_degree,
    SUM(male_45_64_less_than_9_grade) AS male_45_64_less_than_9_grade,
    SUM(male_45_64_grade_9_12) AS male_45_64_grade_9_12,
    SUM(male_45_64_high_school) AS male_45_64_high_school,
    SUM(male_45_64_some_college) AS male_45_64_some_college,
    SUM(male_45_to_64) AS male_45_to_64,
    SUM(male_male_households) AS male_male_households,
    SUM(management_business_sci_arts_employed) AS management_business_sci_arts_employed,
    SUM(no_car) AS no_car,
    SUM(no_cars) AS no_cars,
    SUM(not_us_citizen_pop) AS not_us_citizen_pop,
    SUM(occupation_management_arts) AS occupation_management_arts,
    SUM(
        occupation_natural_resources_construction_maintenance
    ) AS occupation_natural_resources_construction_maintenance,
    SUM(
        occupation_production_transportation_material
    ) AS occupation_production_transportation_material,
    SUM(occupation_sales_office) AS occupation_sales_office,
    SUM(occupation_services) AS occupation_services,
    SUM(one_car) AS one_car,
    SUM(two_cars) AS two_cars,
    SUM(three_cars) AS three_cars,
    SUM(pop_25_64) AS pop_25_64,
    SUM(pop_determined_poverty_status) AS pop_determined_poverty_status,
    SUM(population_1_year_and_over) AS population_1_year_and_over,
    SUM(population_3_years_over) AS population_3_years_over,
    SUM(poverty) AS poverty,
    SUM(sales_office_employed) AS sales_office_employed,
    SUM(some_college_and_associates_degree) AS some_college_and_associates_degree,
    SUM(walked_to_work) AS walked_to_work,
    SUM(worked_at_home) AS worked_at_home,
    SUM(workers_16_and_over) AS workers_16_and_over,
    SUM(associates_degree) AS associates_degree,
    SUM(bachelors_degree) AS bachelors_degree,
    SUM(high_school_diploma) AS high_school_diploma,
    SUM(less_one_year_college) AS less_one_year_college,
    SUM(masters_degree) AS masters_degree,
    SUM(one_year_more_college) AS one_year_more_college,
    SUM(pop_25_years_over) AS pop_25_years_over,
    SUM(commute_35_44_mins) AS commute_35_44_mins,
    SUM(commute_60_more_mins) AS commute_60_more_mins,
    SUM(commute_less_10_mins) AS commute_less_10_mins,
    SUM(commuters_16_over) AS commuters_16_over,
    SUM(hispanic_any_race) AS hispanic_any_race,
    SUM(pop_5_years_over) AS pop_5_years_over,
    SUM(speak_only_english_at_home) AS speak_only_english_at_home,
    SUM(speak_spanish_at_home) AS speak_spanish_at_home,
    SUM(speak_spanish_at_home_low_english) AS speak_spanish_at_home_low_english,
    SUM(pop_15_and_over) AS pop_15_and_over,
    SUM(pop_never_married) AS pop_never_married,
    SUM(pop_now_married) AS pop_now_married,
    SUM(pop_separated) AS pop_separated,
    SUM(pop_widowed) AS pop_widowed,
    SUM(pop_divorced) AS pop_divorced,
    MIN(do_date) AS do_date,
    "New York" as state,
    "New York City" as county,
    1000000 as fips,
    SUM(trump16) AS trump16,
    SUM(clinton16) AS clinton16,
    SUM(otherpres16) AS otherpres16,
    SUM(romney12) AS romney12,
    SUM(obama12) AS obama12,
    SUM(otherpres12) AS otherpres12,
    SUM(demsen16) AS demsen16,
    SUM(repsen16) AS repsen16,
    SUM(othersen16) AS othersen16,
    SUM(demhouse16) AS demhouse16,
    SUM(rephouse16) AS rephouse16,
    SUM(otherhouse16) AS otherhouse16,
    SUM(demgov16) AS demgov16,
    SUM(repgov16) AS repgov16,
    SUM(othergov16) AS othergov16,
    SUM(repgov14) AS repgov14,
    SUM(demgov14) AS demgov14,
    SUM(othergov14) AS othergov14,
    SUM(total_population) AS total_population,
    SUM(cvap) AS cvap,
    SUM(white_pct * total_pop) / SUM(total_pop) AS white_pct,
    SUM(black_pct * total_pop) / SUM(total_pop) AS black_pct,
    SUM(hispanic_pct * total_pop) / SUM(total_pop) AS hispanic_pct,
    SUM(nonwhite_pct * total_pop) / SUM(total_pop) AS nonwhite_pct,
    SUM(
        foreignborn_pct * total_pop
    ) / SUM(total_pop) AS foreignborn_pct,
    SUM(female_pct * total_pop) / SUM(total_pop) AS female_pct,
    SUM(
        age29andunder_pct * total_pop
    ) / SUM(total_pop) AS age29andunder_pct,
    SUM(
        age65andolder_pct * total_pop
    ) / SUM(total_pop) AS age65andolder_pct,
    SUM(median_hh_inc * total_pop) / SUM(total_pop) AS median_hh_inc,
    SUM(
        clf_unemploy_pct * total_pop
    ) / SUM(total_pop) AS clf_unemploy_pct,
    SUM(lesshs_pct * total_pop) / SUM(total_pop) AS lesshs_pct,
    SUM(
        lesscollege_pct * total_pop
    ) / SUM(total_pop) AS lesscollege_pct,
    SUM(
        lesshs_whites_pct * total_pop
    ) / SUM(total_pop) AS lesshs_whites_pct,
    SUM(
        lesscollege_whites_pct * total_pop
    ) / SUM(total_pop) AS lesscollege_whites_pct,
    SUM(rural_pct * total_pop) / SUM(total_pop) AS rural_pct,
    "1" AS ruralurban_cc
FROM `covid-project-275201.public.county_area_acs` county
#    LEFT JOIN `covid-project-275201.public.nyt_kcmo_county_fractions` fraction ON county_fips_code=fraction.county_fips_code;
#    `bigquery-public-data.census_bureau_county_2017_5yr` acs
#    LEFT JOIN `bigquery-public-data.utility_us.us_county_area` county ON geo_id = geo_id
#    LEFT JOIN `bigquery-public-data.utility_us.us_states_area` states ON state_fips_code = states.state_fips_code
#    LEFT JOIN public.election_context_2018 election ON safe_cast(state_fips_code AS int64) * 1000 + safe_cast(county_fips_code AS int64) = fips
WHERE
    state_abbreviation IN ("NY")
    AND county_name IN (
        "New York",
        "Kings",
        "Queens",
        "Bronx",
        "Richmond"
    )
;