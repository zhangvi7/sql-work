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

-- DROP VIEW IF EXISTS wins_per_party CASCADE;
-- CREATE VIEW wins_per_party AS
SELECT num.party_id, party.country_id, num.num_of_winning
FROM(SELECT winning_party.party_id , count(party.country_id) AS num_of_winning 
FROM winning_party  RIGHT JOIN party ON winner_party.party_id = party.id GROUP BY winning_party.party_id) num  LEFT JOIN party ON party.id= num.party_id;

-- 3)average number of winning elections of parties of the same country

-- DROP VIEW IF EXISTS avg_wins_country CASCADE;
-- create view avg_wins_country as
-- select p.country_id, (sum(w.party_wins) / count(w.party_id)) as country_avg_win
-- from wins_per_party w right join party p on w.party_id = p.id
-- group by p.country_id;

-- --4) Find parties that won more than 3 x average win per country 
-- DROP VIEW IF EXISTS won_more_3x CASCADE;
-- create view won_more_3x as
-- select w.country_id, w.party_wins, w.party_id
-- from wins_per_party w join avg_wins_country a on
-- w.country_id = a.country_id 
-- where 3 * (a.country_avg_win) < w.party_wins;

-- select w.country_id, w.party_wins, w.party_id
-- from wins_per_party w join avg_wins_country a on
-- w.country_id = a.country_id 
-- where 3 * (a.country_avg_win) < w.party_wins;

-- -- select w.country_id, w.party_wins, w.party_id
-- -- from wins_per_party w, avg_wins_country a
-- -- where w.country_id = a.country_id and w.party_wins > (3 * a.country_avg_win);
     
-- -- --5) Find most recently won election id/year for each party
-- -- DROP VIEW IF EXISTS most_recent_date CASCADE;
-- -- create view most_recent_date as
-- -- select w.party_id, max(e.e_date) as mostRecentlyWonElectionDate, e.id as mostRecentlyWonElectionId
-- from winning_party w, election e 
-- where w.election_id = e.id 
-- group by w.party_id, e.id; 

-- --find party family and name
-- DROP VIEW IF EXISTS win_name CASCADE;
-- create view win_name as
-- select w.country_id, w.party_wins, w.party_id, p.name
-- from won_more_3x w, party p
-- where w.party_id = p.id;

-- DROP VIEW IF EXISTS win_family CASCADE;
-- create view win_family as
-- select w.country_id, w.party_wins, w.party_id, w.name, p.family
-- from win_name w left join party_family p on w.party_id = p.party_id;




