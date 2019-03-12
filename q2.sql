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

--Find the number of vote that win that election for each election
CREATE VIEW winner_vote AS 
SELECT election_id,max(votes)AS max_vote FROM election_result GROUP BY election_id;

 --Find the party that wins the election for each election
CREATE VIEW winner AS
SELECT party.id AS party_id, party.country_id, election_result.election_id
FROM (election_result NATURAL JOIN winner_vote )JOIN party ON party.id = election_result.party_id
WHERE winner_vote.max_vote = election_result.votes ;

--Find the number of win for each party. For the party that does not win, set 0
CREATE VIEW num_win AS
SELECT num.party_id, party.country_id, num.num_of_winning
FROM(SELECT winner.party_id , count(party.country_id) AS num_of_winning 
FROM winner  RIGHT JOIN party ON winner.party_id = party.id GROUP BY party_id) num  LEFT JOIN party ON party.id= num.party_id;

--Find the average number of winning elections of each country
CREATE VIEW country_avg_win AS
SELECT party.country_id, (sum(num_win.num_of_winning)/count(party.id) )AS average 
FROM num_win RIGHT JOIN party ON num_win.party_id = party.id GROUP BY party.country_id ;

--Find the party that that have won three times the average number of winning elections of parties of the same country
CREATE VIEW answer_party AS
SELECT n.party_id ,c.country_id FROM num_win n JOIN country_avg_win c ON n.country_id = c.country_id 
WHERE 3*(c.average) < n.num_of_winning ;

SELECT n.party_id ,c.country_id FROM num_win n JOIN country_avg_win c ON n.country_id = c.country_id 
WHERE 3*(c.average) < n.num_of_winning ;

-- select w.country_id, w.party_wins, w.party_id
-- from wins_per_party w, avg_wins_country a
-- where w.country_id = a.country_id and w.party_wins > (3 * a.country_avg_win);
     
-- --5) Find most recently won election id/year for each party
-- DROP VIEW IF EXISTS most_recent_date CASCADE;
-- create view most_recent_date as
-- select w.party_id, max(e.e_date) as mostRecentlyWonElectionDate, e.id as mostRecentlyWonElectionId
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




