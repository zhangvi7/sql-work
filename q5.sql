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


-- Group by each country and year
CREATE VIEW participation_ratio AS 
SELECT EXTRACT(year FROM e_date) AS year, country_id, AVG(votes_cast::numeric / electorate::numeric) AS ratio
FROM election_full
WHERE e_date > '2001-01-01' AND e_date < '2016-12-31'
GROUP BY year, country_id;

-- countries whose average election participation ratios during
-- this period are monotonically non-decreasing (meaning that for Year Y and Year W, where at least
-- one election has happened in each of them, if Y < W, then the average participation in Year Y is
-- ≤ average participation in Year W)

--1) tuples only for countries with at least 1 election, 2) must be non-decreasing ratio over years

-- SELECT ID of countries not valid
CREATE VIEW cid_not_valid AS
SELECT DISTINCT country_id
FROM participation_ratio
WHERE EXISTS (
        SELECT * 
        FROM participation_ratio p
        WHERE 
                participation_ratio.year > p.year AND
                participation_ratio.ratio < p.ratio);
                
SELECT DISTINCT country_id
FROM participation_ratio
WHERE EXISTS (
        SELECT * 
        FROM participation_ratio p
        WHERE 
                participation_ratio.year > p.year AND
                participation_ratio.ratio < p.ratio);

-- SELECT ID of countries that are valid
CREATE VIEW cid_valid AS
SELECT id
FROM country
WHERE NOT EXISTS (
        SELECT * 
        FROM cid_not_valid
        WHERE country.id = cid_not_valid.country_id
);

SELECT id
FROM country
WHERE NOT EXISTS (
        SELECT * 
        FROM cid_not_valid
        WHERE country.id = cid_not_valid.country_id
);



     