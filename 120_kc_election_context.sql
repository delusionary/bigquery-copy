#standardSQL
-- Now that we have determined the fraction of the population, multiply the values in the
-- Election data table by those values to estimate the number of each kind of voter in the
-- portion of each county that are  part of KC
CREATE OR REPLACE VIEW public.kc_election_context AS
SELECT
    ANY_VALUE(fraction.state_fips_code) as state_fips_code,
    '2000000' as county_fips_code,
    'Missouri' as state,
    'Kansas City' as county,
    2000000 as fips,
    SUM(election.trump16*fraction.fraction_kc_pop) as trump16,
    SUM(election.clinton16*fraction.fraction_kc_pop) as clinton16,
    SUM(election.otherpres16*fraction.fraction_kc_pop) as otherpres16,
    SUM(election.romney12*fraction.fraction_kc_pop) as romney12,
    SUM(election.obama12*fraction.fraction_kc_pop) as obama12,
    SUM(election.otherpres12*fraction.fraction_kc_pop) as otherpres12,
    SUM(election.demsen16*fraction.fraction_kc_pop) as demsen16,
    SUM(election.repsen16*fraction.fraction_kc_pop) as repsen16,
    SUM(election.othersen16*fraction.fraction_kc_pop) as othersen16,
    SUM(election.demhouse16*fraction.fraction_kc_pop) as demhouse16,
    SUM(election.rephouse16*fraction.fraction_kc_pop) as rephouse16,
    SUM(election.otherhouse16*fraction.fraction_kc_pop) as otherhouse16,
    SUM(election.demgov16*fraction.fraction_kc_pop) as demgov16,
    SUM(election.repgov16*fraction.fraction_kc_pop) as repgov16,
    SUM(election.othergov16*fraction.fraction_kc_pop) as othergov16,
    SUM(election.repgov14*fraction.fraction_kc_pop) as repgov14,
    SUM(election.demgov14*fraction.fraction_kc_pop) as demgov14,
    SUM(election.othergov14*fraction.fraction_kc_pop) as othergov14,
    SUM(election.total_population*fraction.fraction_kc_pop) as total_population,
    SUM(election.cvap*fraction.fraction_kc_pop) as cvap,
    -- Take the average of the percentages weighted by the portion of the population estimated to be in KC
    SUM(election.white_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as white_pct,
    SUM(election.black_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as black_pct,
    SUM(election.hispanic_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as hispanic_pct,
    SUM(election.nonwhite_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as nonwhite_pct,
    SUM(election.foreignborn_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as foreignborn_pct,
    SUM(election.female_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as female_pct,
    SUM(election.age29andunder_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as age29andunder_pct,
    SUM(election.age65andolder_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as age65andolder_pct,
    SUM(election.median_hh_inc * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as median_hh_inc,
    SUM(election.clf_unemploy_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as clf_unemploy_pct,
    SUM(election.lesshs_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as lesshs_pct,
    SUM(election.lesscollege_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as lesscollege_pct,
    SUM(election.lesshs_whites_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as lesshs_whites_pct,
    SUM(election.lesscollege_whites_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as lesscollege_whites_pct,
    SUM(election.rural_pct * fraction.kc_total_pop) / SUM(fraction.kc_total_pop) as rural_pct,
    MIN(election.ruralurban_cc) as ruralurban_cc
FROM
    `covid-project-275201`.public.nyt_kcmo_county_fractions fraction
    LEFT JOIN `covid-project-275201`.public.election_context_2018 election ON CONCAT(fraction.state_fips_code, fraction.county_fips_code) = CAST(election.fips as STRING);
