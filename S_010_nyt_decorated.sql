#standardSQL

-- Materialize the result of the NYT acceleration view.
create or replace table public.nyt_decorated as
select * from public.nyt_acceleration;
