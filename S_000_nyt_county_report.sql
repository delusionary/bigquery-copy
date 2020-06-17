#standardSQL
create or replace table public.nyt_county_report as
select * from public.nyt_county_report_view;