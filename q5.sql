SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

create table q5 (
        countryName varchar(50),
        year int,
        participationRatio real
);

-- create view as election_check as 
select e.id, e.country_id, e.e_date, e.electorate, e.votes_cast
from election e;

-- CREATE VIEW election_full AS 
SELECT election.id, election.country_id, election.e_date, electorate,
        (CASE WHEN votes_cast IS NOT NULL THEN votes_cast
            ELSE (
                    SELECT SUM(votes) 
                    FROM election_result
                    WHERE election_result.election_id = election.id)
                END) 
                    AS votes_cast
FROM election;

-- Group by each country and year
-- CREATE VIEW participation_ratio AS 
-- SELECT EXTRACT(year FROM e_date) AS year, country_id, AVG(votes_cast::numeric / electorate::numeric) AS ratio
-- FROM election_full
-- WHERE e_date > '2001-01-01' AND e_date < '2016-12-31'
-- GROUP BY year, country_id;