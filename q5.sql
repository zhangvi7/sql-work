SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

create table q5 (
        countryName varchar(50),
        year int,
        participationRatio real
);

DROP VIEW IF EXISTS elections CASCADE;
create view elections as 
select e.id, e.country_id, extract(YEAR from e_date) as year, e.electorate, e.votes_cast
from election e;

DROP VIEW IF EXISTS ratios CASCADE;
create view ratios as
select e.country_id, e.year, avg(votes_cast / electorate) as ratio
from elections e
where e.year >= 2001 and e.year <= 2016
group by e.year, e.country_id;

DROP VIEW IF EXISTS not_valid_countries CASCADE;
create view not_valid_countries as
select distinct country_id
FROM ratios r
WHERE EXISTS (
        SELECT * 
        FROM ratios r2
        WHERE 
                r.year > r2.year AND
                r.ratio < r2.ratio and
                r.country_id = r2.country_id);

DROP VIEW IF EXISTS valid_countries CASCADE;              
create view valid_countries as
select *
from ratios r
where not exists (
    SELECT *
    FROM not_valid_countries n
    WHERE r.country_id = n.country_id);

insert into q5 
SELECT c.name AS countryName, 
       v.year AS year, 
        v.ratio AS participationRatio
FROM valid_countries v, country c
WHERE v.country_id = c.id;




     