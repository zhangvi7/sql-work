SET search_path TO parlgov;

create table q1(
        countryId integer, 
        alliedPartyId1 integer, 
        alliedPartyId2 integer
);
--Report the pair of parties that have been allies with each other in 
-- at least 30% of elections that have happened in a country
-- satisfy case with head and no head
create view partyPairs as
select e1.party_id as party1, e2.party_id as party2, e.id, e.country_id
from election_result e1, election_result e2, election e
where e1.election_id = e2.election_id = e.id and 
    ((e1.alliance_id = e2.alliance_id and e1.id < e2.id) or 
    (e1.alliance_id = null and e2.alliance_id = e1.id));

--at least 30% of elections that have happened in a country
--total number of elections in a country
create view electionAmount as
select country_id, count(*) as amt
from election
group by country_id

--ans: compare if amt > 0.3 
insert into q1
select partyPairs.country_id as countryId, 
    partyPairs.p1 as alliedPartyId1, 
    partyPairs.p2 as alliedPartyId2
from partyPairs p, electionAmount e
where p.country_id = e.country_id 
group by p.party1, p.party2, p.countryId
having count(*) >= e.amt * 0.3



-- -- Define views for your intermediate steps here.
-- -- Select the <party, party> pair where they formed alliance in some election in some country
-- CREATE VIEW partyPairs AS
-- SELECT ER1.party_id AS p1, ER2.party_id AS p2, ER1.election_id, election.country_id
-- FROM election_result ER1, election_result ER2, election
-- WHERE ER1.election_id = ER2.election_id AND
--         (ER1.alliance_id = ER2.id OR ER1.id = ER2.alliance_id OR ER1.alliance_id = ER2.alliance_id) AND
--         ER1.election_id = election.id AND
--         ER1.party_id < ER2.party_id
-- GROUP BY(ER1.election_id, ER1.party_id, ER2.party_id, election.country_id);

-- -- Number of elections in each country
-- CREATE VIEW sum_elections AS
-- SELECT country_id, COUNT(*) AS election_cnt
-- FROM election
-- GROUP BY country_id;

-- -- Sum the partyPairs to see if its more than 1/3 of that country


-- -- the answer to the query 
-- insert into q7 
-- SELECT partyPairs.country_id AS countryId, 
--         partyPairs.p1 AS alliedPartyId1, 
--         partyPairs.p2 AS alliedPartyId2
-- FROM partyPairs, sum_elections
-- WHERE partyPairs.country_id = sum_elections.country_id
-- GROUP BY partyPairs.p1, partyPairs.p2, partyPairs.country_id, sum_elections.election_cnt
-- HAVING COUNT(*) >= (sum_elections.election_cnt::numeric * 0.3);