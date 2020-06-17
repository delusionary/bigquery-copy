#standardSQL

-- Materialize one big joined table.
create or replace table public.nyt_county_report as
select
  *
from
  public.nyt_county_acs_election_mobility_report_view;