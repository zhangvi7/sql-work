SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

create table q5 (
        countryName varchar(50),
        year int,
        participationRatio real
);

create view as election_full as 
select e.id, e.country_id, extract(YEAR from e.e_date) as e.year, e.electorate, e.votes_cast
from election e
group by e.country_id, e.e_date;

create view ratio as
select e.country_id, e.year, avg(e.votes_cast / e.electorate) as ratio
from election_full e
where e.e_date >= 2001 and e.e_date <= 2016
group by  e.country_id, e.year;

select e.country_id, e.year, avg(e.votes_cast / e.electorate) as ratio
from election_full e
where e.e_date >= 2001 and e.e_date <= 2016
group by  e.country_id, e.year;


-- countries whose average election participation ratios during
-- this period are monotonically non-decreasing (meaning that for Year Y and Year W, where at least
-- one election has happened in each of them, if Y < W, then the average participation in Year Y is
-- ≤ average participation in Year W)

--1) tuples only for countries with at least 1 election, 2) must be non-decreasing ratio over years
-- create view valid_countries as
select country_id
from ratio 
where not exist (
    select * 
    from ratio r
    where r.year > year and r.ratio <= ratio);

     