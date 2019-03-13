SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

create table q5 (
        countryName varchar(50),
        year int,
        participationRatio real
);
DROP VIEW IF EXISTS  election_full CASCADE;
create view election_full as 
select e.id, e.country_id, extract(YEAR from e_date) as year, e.electorate, e.votes_cast
from election e;

DROP VIEW IF EXISTS  ratios CASCADE;
create view ratios as
select e.country_id, e.year, avg(votes_cast::numeric / electorate::numeric) as ratio
from election_full e
where e.year >= 2001 and e.year <= 2016
group by e.year, e.country_id;


-- countries whose average election participation ratios during
-- this period are monotonically non-decreasing (meaning that for Year Y and Year W, where at least
-- one election has happened in each of them, if Y < W, then the average participation in Year Y is
-- ≤ average participation in Year W)

--1) tuples only for countries with at least 1 election, 2) must be non-decreasing ratio over years
-- create view valid_countries as
-- SELECT ID of countries not valid
create view not_valid_countries
(select country_id from ratios) 
except
(SELECT country_id
FROM ratios
WHERE EXISTS (
        SELECT * 
        FROM ratios p
        WHERE 
                ratios.year > p.year AND
                ratios.ratio < p.ratio)
    );

(select country_id from ratios) 
except
(SELECT country_id
FROM ratios
WHERE EXISTS (
        SELECT * 
        FROM ratios p
        WHERE 
                ratios.year > p.year AND
                ratios.ratio < p.ratio)
    );

     