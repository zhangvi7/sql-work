SET SEARCH_PATH TO parlgov;

create table q3(
       countryName VARCHAR(50),
       partyName VARCHAR(100),
       partyFamily VARCHAR(50),
       wonElections integer,
       mostRecentlyWonElectionId integer,
       mostRecentlyWonElectionYear integer
); 


DROP VIEW IF EXISTS winning_partys CASCADE;
create view winning_partys as
select election_id, max(votes) as max_votes
from election_result
group by election_id;

DROP VIEW IF EXISTS winning_party CASCADE;
create view winning_party as
select p.id as party_id, p.country_id, e.election_id
from election_result e, winning_partys w, party p
where e.election_id = w.election_id and e.votes = w.max_votes and 
      e.party_id = p.id;


DROP VIEW IF EXISTS wins_per_party CASCADE;
CREATE VIEW wins_per_party AS
SELECT wins.party_id, party.country_id, wins.num_wins as party_wins
FROM 
    (SELECT winning_party.party_id, count(party.country_id) AS num_wins 
    FROM winning_party RIGHT JOIN party ON winning_party.party_id = party.id 
    GROUP BY party_id) wins
        LEFT JOIN party ON party.id = wins.party_id;


DROP VIEW IF EXISTS avg_wins_country CASCADE;
create view avg_wins_country as
SELECT party.country_id, (sum(wins_per_party.party_wins)/count(party.id) ) AS country_avg_win
FROM wins_per_party right join party ON wins_per_party.party_id = party.id 
GROUP BY party.country_id;

 
DROP VIEW IF EXISTS won_more_three_times CASCADE;
create view won_more_three_times as
select w.country_id, w.party_id, w.party_wins
from wins_per_party w, avg_wins_country a
where w.country_id = a.country_id and w.party_wins > (3 * a.country_avg_win);

create view with_country_name as
select c.name as countryName, w.party_wins, w.party_id
from won_more_three_times w, country c
where w.country_id = c.id;

create view with_party_name as
select w.countryName, p.name as partyName, w.party_wins as wonElections, w.party_id
from with_country_name w, party p
where w.party_id = p.id;

create view with_party_family as
select w.countryName, w.partyName, p.family as familyName, w.wonElections, w.party_id
from with_party_name w left join party_family p on 
w.party_id = p.party_id;


DROP VIEW IF EXISTS find_election_date CASCADE;
create view find_election_date as
select distinct w.party_id, MAX(e.e_date) AS max_date
from winning_party w left join election e 
on w.election_id = e.id
group by w.party_id;

CREATE VIEW find_election_id AS
SELECT f.party_id, w.election_id, cast (f.max_date AS DATE)
FROM (find_election_date f join winning_party w ON f.party_id = w.party_id)
    JOIN election ON election.id = w.election_id AND f.max_date = election.e_date;


insert into q3
select w.countryName, w.partyName, w.familyName, w.wonElections, f.election_id as mostRecentlyWonElectionId, 
EXTRACT(YEAR FROM f.max_date) AS mostRecentlyWonElectionYear 
from find_election_id f join with_party_family w on
f.party_id = w.party_id;

select w.countryName, w.partyName, w.familyName, w.wonElections, f.election_id as mostRecentlyWonElectionId, 
EXTRACT(YEAR FROM f.max_date) AS mostRecentlyWonElectionYear 
from find_election_id f join with_party_family w on
f.party_id = w.party_id;









