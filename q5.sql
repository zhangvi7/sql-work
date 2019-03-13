SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

create table q5 (
        countryName varchar(50),
        year int,
        participationRatio real
);

-- create view as election_full as 
select e.country_id
from election e
group by e.country_id;

select e.e_date
from election e
group by e.e_date;

select e.country_id, e.e_date 
from election e
group by e.country_id, e.e_date;

-- -- CREATE VIEW election_full AS 
-- SELECT election.id, election.country_id, election.e_date, electorate,
--         (CASE WHEN votes_cast IS NOT NULL THEN votes_cast
--             ELSE (
--                     SELECT SUM(votes) 
--                     FROM election_result
--                     WHERE election_result.election_id = election.id)
--                 END) 
--                     AS votes_cast
-- FROM election;

-- -- Group by each country and year
-- create view ratio as
-- select
-- from election_full e
-- where e.e_date > '2001-01-01' and e.e_date < '2016-12-3'
-- group by


-- CREATE VIEW participation_ratio AS 
-- SELECT EXTRACT(year FROM e_date) AS year, country_id, AVG(votes_cast::numeric / electorate::numeric) AS ratio
-- FROM election_full
-- WHERE e_date > '2001-01-01' AND e_date < '2016-12-31'
-- GROUP BY year, country_id;