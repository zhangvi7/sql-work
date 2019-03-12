-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
       countryName VARCHaR(50),
       partyName VARCHaR(100),
       partyFamily VARCHaR(50),
       wonElections INT,
       mostRecentlyWonElectionId INT,
       mostRecentlyWonElectionYear INT
); 

-- Find parties that have won more than 3 times the average number of winning elections
-- of parties of the same country. Report the country name, party name and the party’s
-- family name along with the total number of elections it has won

--1) Find all winning parties for an election:
-- 1) max votes for an election
-- DROP VIEW IF EXISTS max_votes CASCADE;
create view winners as
select election_id, max(votes) as max_votes
from election_result
group by election_id;
-- 2) find parties that win elections
-- DROP VIEW IF EXISTS winning_party CASCADE;
create view winning_party as
select p.id, p.name, p.country_id, e.election_id
from election_result e, winners w, party p
where e.election_id = w.election_id and e.votes = w.max_votes and 
      e.party_id = p.id;
--2) Using all winning parties in election, find number of wins per party
-- DROP VIEW IF EXISTS wins_per_party CASCADE;
create view wins_per_party as
select w.id, count(w.id) as party_wins, w.country_id, w.name, w.election_id
from winning_party w
group by w.id, w.country_id, w.name, w.election_id;
--3) Find average number of winning elections of parties per country
-- DROP VIEW IF EXISTS avg_wins_country CASCADE;
create view avg_wins_country as
select p.country_id, (sum(w.party_wins) / count(p.id)) as country_avg_win
from wins_per_party w, party p
where w.id = p.id
group by p.country_id;
--4) Find parties that won more than 3 x average win per country 
-- DROP VIEW IF EXISTS ans CASCADE;
create view ans as
select w.country_id, w.name, p.family, w.party_wins, w.id
from wins_per_party w, avg_wins_country a, party_family p
where w.country_id = a.country_id and w.party_wins > (3 * a.country_avg_win) 
      and w.id = p.party_id;
--6) Find most recently won election id/year for each party
create view most_recent_date as
select p.id as party_id, max(e.e_date) as mostRecentlyWonElectionDate, e.id
from wins_per_party p, election e 
where p.election_id = e.id
group by p.id; 

create view most_recent_id as
select m.party_id, m.mostRecentlyWonElectionDate, e.id as mostRecentlyWonElectionId
from most_recent_date m, election e
where m.id = e.id; 
--5) insert into table
insert into q3
select c.name as countryName, 
    a.name as partyName, 
    a.family as partyFamily,
    a.party_wins as wonElections,
    m.mostRecentlyWonElectionDate as mostRecentlyWonElectionDate
    m.mostRecentlyWonElectionId as mostRecentlyWonElectionId
from ans a, country c, most_recent_id m
where a.country_id = c.id, a.id = m.party_id;






-- --Find the number of vote that win that election for each election
-- CREATE VIEW winner_vote AS 
-- SELECT election_id,max(votes)AS max_vote FROM election_result GROUP BY election_id;

--  --Find the party that wins the election for each election
-- CREATE VIEW winner AS
-- SELECT party.id AS party_id, party.country_id, election_result.election_id
-- FROM (election_result NATURAL JOIN winner_vote )JOIN party ON party.id = election_result.party_id
-- WHERE winner_vote.max_vote = election_result.votes ;

-- --Find the number of win for each party. For the party that does not win, set 0
-- CREATE VIEW num_win AS
-- SELECT num.party_id, party.country_id, num.num_of_winning
-- FROM(SELECT winner.party_id , count(party.country_id) AS num_of_winning 
-- FROM winner  RIGHT JOIN party ON winner.party_id = party.id GROUP BY party_id )num  LEFT JOIN party ON party.id= num.party_id;

-- --Find the average number of winning elections of each country
-- CREATE VIEW country_avg_win AS
-- SELECT party.country_id, (sum(num_win.num_of_winning)/count(party.id) )AS average 
-- FROM num_win RIGHT JOIN party ON num_win.party_id = party.id GROUP BY party.country_id ;

-- --Find the party that that have won three times the average number of winning elections of parties of the same country
-- CREATE VIEW answer_party AS
-- SELECT n.party_id ,c.country_id FROM num_win n JOIN country_avg_win c ON n.country_id = c.country_id 
-- WHERE 3*(c.average) < n.num_of_winning ;

--Anwser except mostRecentlyWonElectionId and mostRecentlyWonElectionYear
-- CREATE VIEW answer_without_five_attributes AS
-- SELECT a.party_id,c.name AS countryName
-- FROM answer_party a JOIN country c ON a.country_id=c.id;

-- CREATE VIEW answer_without_four_attributes AS
-- SELECT a.party_id, a.countryName, p.name AS partyName
-- FROM answer_without_five_attributes a JOIN party p ON a.party_id=p.id;

-- CREATE VIEW answer_without_three_attributes AS
-- SELECT a.party_id,a.countryName, a.partyName, pf.family AS partyFamily
-- FROM answer_without_four_attributes a LEFT JOIN party_family pf ON a.party_id=pf.party_id;

-- CREATE VIEW answer_without_two_attributes AS
-- SELECT a.party_id,a.countryName, a.partyName, a.partyFamily, n.num_of_winning AS wonElections
-- FROM answer_without_three_attributes a JOIN num_win n ON a.party_id = n.party_id;

-- --Find the most recentwon election for each party.
-- CREATE VIEW most_recent_won AS
-- SELECT recent.party_id,winner.election_id AS mostRecentlyWonElectionId, recent. mostRecentlyWonElectionDate
-- FROM ((SELECT winner.party_id, MAX(election.e_date) AS mostRecentlyWonElectionDate
--      FROM winner LEFT JOIN election ON winner.election_id = election.id 
--      GROUP BY winner.party_id) recent JOIN winner ON recent.party_id = winner.party_id) 
--      JOIN election ON election.id = winner.election_id AND cast(recent.mostRecentlyWonElectionDate AS DATE) = election.e_date;



-- -- the answer to the query
-- insert into q2 
-- SELECT a.countryName,a.partyName,a.partyFamily,a.wonElections, m.mostRecentlyWonElectionId,EXTRACT(year FROM m.mostRecentlyWonElectionDate ) AS mostRecentlyWonElectionYear 
-- FROM answer_without_two_attributes a JOIN most_recent_won m ON a.party_id = m.party_id;