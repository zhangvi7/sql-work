SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

create table q3(
       countryName VARCHaR(50),
       partyName VARCHaR(100),
       partyFamily VARCHaR(50),
       wonElections INT,
       mostRecentlyWonElectionId INT,
       mostRecentlyWonElectionYear DATE
); 

-- Find parties that have won more than 3 times the average number of winning elections of parties of the same country. 
--Report the country name, party name and the party’s family name along with --the total number of elections it has won

--1) Find all winning parties for an election:
-- 1) max votes for an election
DROP VIEW IF EXISTS winning_partys CASCADE;
create view winning_partys as
select election_id, max(votes) as max_votes
from election_result
group by election_id;
-- 2) find parties that win elections
DROP VIEW IF EXISTS winning_party CASCADE;
create view winning_party as
select p.id as party_id, p.country_id, e.election_id
from election_result e, winning_partys w, party p
where e.election_id = w.election_id and e.votes = w.max_votes and 
      e.party_id = p.id;
--2) Using all winning parties in election, find number of wins per party
-- DROP VIEW IF EXISTS wins_per_party_no_country CASCADE;
-- create view wins_per_party_no_country as
-- select w.party_id, count(p.country_id) as party_wins
-- from winning_party w right join party p on w.party_id = p.id
-- group by w.party_id; 

-- DROP VIEW IF EXISTS wins_per_party CASCADE;
-- CREATE VIEW wins_per_party AS
-- SELECT w.party_id, p.country_id, w.party_wins
-- FROM wins_per_party_no_country w LEFT JOIN party p ON p.id= w.party_id;
DROP VIEW IF EXISTS wins_per_party CASCADE;
CREATE VIEW wins_per_party AS
SELECT num.party_id, party.country_id, num.num_of_winning as party_wins
FROM 
    (SELECT winning_party.party_id, count(party.country_id) AS num_of_winning 
    FROM winning_party RIGHT JOIN party ON winning_party.party_id = party.id 
    GROUP BY party_id) num  
    LEFT JOIN party ON party.id= num.party_id;

-- 3)average number of winning elections of parties of the same country

DROP VIEW IF EXISTS avg_wins_country CASCADE;
create view avg_wins_country as
SELECT party.country_id, (sum(wins_per_party.party_wins)/count(party.id) ) AS country_avg_win
FROM wins_per_party right join party ON wins_per_party.party_id = party.id 
GROUP BY party.country_id ;


--4) Find parties that won more than 3 x average win per country 
DROP VIEW IF EXISTS won_more_3x CASCADE;
create view won_more_3x as
select w.country_id, w.party_id, w.party_wins
from wins_per_party w, avg_wins_country a
where w.country_id = a.country_id and w.party_wins > (3 * a.country_avg_win);

create view with_country_name as
select c.name as countryName, w.party_wins, w.party_id
from won_more_3x w, country c
where w.country_id = c.id;

create view with_party_name as
select w.countryName, p.name as partyName, w.party_wins as wonElections, w.party_id
from with_country_name w, party p
where w.party_id = p.id;

create view with_party_family as
select w.countryName, w.partyName, p.family as familyName, w.wonElections, w.party_id
from with_party_name w left join party_family p on 
w.party_id = p.party_id;

select w.countryName, w.partyName, p.family as familyName, w.wonElections, w.party_id
from with_party_name w left join party_family p on 
w.party_id = p.party_id;


--find all winner parties election id
DROP VIEW IF EXISTS find_election_date CASCADE;
create view find_election_date as
select distinct w.party_id, MAX(e.e_date) AS max_date
from winning_party w left join election e 
on w.election_id = e.id
group by w.party_id;

CREATE VIEW find_election_id AS
SELECT f.party_id, w.election_id, f.max_date
FROM (find_election_date f 
        Join winning_party w ON f.party_id = w.party_id)  
        JOIN election ON election.id = w.election_id AND cast (f.max_date AS DATE) = election.e_date;

        SELECT f.party_id, w.election_id, f.max_date
FROM (find_election_date f 
        Join winning_party w ON f.party_id = w.party_id)  
        JOIN election ON election.id = w.election_id AND cast (f.max_date AS DATE) = election.e_date;


-- SELECT f.party_id, w.election_id, f.max_date
-- FROM ((select w.party_id, MAX(e.e_date) AS max_date
-- from winning_party w left join election e 
-- on w.election_id = e.id
-- group by w.party_id) f join winning_party w ON f.party_id = w.party_id)  
-- JOIN election ON election.id = w.election_id AND cast (f.max_date AS DATE) = election.e_date;

-- DROP VIEW IF EXISTS ans CASCADE;
-- create view ans as
-- insert into q3
select w.countryName, w.partyName,w.familyName, w.wonElections, f.election_id as mostRecentlyWonElectionId, 
EXTRACT(year FROM f.max_date) AS mostRecentlyWonElectionYear 
from find_election_id f join with_party_family w on
f.party_id = w.party_id;








