SELECT * FROM md_water_services.data_dictionary;
use md_water_services;
show tables;

-- we are looking at table LOCATON
select *
from location
limit 5;

-- we are looking at table VISITS
SELECT *
FROM VISITS
LIMIT 5;

-- WE ARE LOOKING AT THE WATER SOURCE TABLE
SELECT *
FROM WATER_SOURCE
LIMIT 5;

-- WE WANT TO SEE UNIQUE WATER SOURCES
SELECT DISTINCT TYPE_OF_WATER_SOURCE
FROM WATER_SOURCE;

-- Write an SQL query that retrieves all records from this table
-- where the time_in_queue is more than some crazy time, say 500 min. How
-- would it feel to queue 8 hours for water?
SELECT *
FROM VISITS
WHERE TIME_IN_QUEUE >500;

-- I am wondering what type of water sources take this long to queue for.
--  We will have to find that information in another table that lists
-- the types of water sources. If I remember correctly, the table has type_of_water_source,
SELECT VISITS.SOURCE_ID, TIME_IN_QUEUE, TYPE_OF_WATER_SOURCE
FROM VISITS AS VISITS
JOIN WATER_SOURCE AS WATER_S
ON VISITS. SOURCE_ID = WATER_S.SOURCE_ID
WHERE WATER_S.SOURCE_ID IN  ('AkKi00881224','SoRu37635224', 'SoRu36096224');

-- I chose these two:
-- AkRu05234224
-- HaZa21742224
-- Ok, so now back to the water_source table. Let's check the records for those source_ids. You can probably
-- remember there is a cool and a "not so cool" way to do it.
SELECT *
FROM WATER_SOURCE
WHERE SOURCE_ID in ("AkRu05234224", "HaZa21742224");

-- The quality of our water sources is the whole point of this survey. 
-- We have a table that contains a quality score for each visit made
-- about a water source that was assigned by a Field surveyor. 
SELECT *
FROM WATER_QUALITY;
-- They assigned a score to each source from 1, being terrible, 
-- to 10 for a good, clean water source in a home. Shared taps are not rated as high, 
-- and the score also depends on how long the queue times are.

-- Look through the table record to find the table.

-- Let's check if this is true. The surveyors only made multiple visits to shared taps and did not revisit other types of water sources.
-- So there should be no records of second visits to locations where there are good water sources, like taps in homes.
-- So please write a query to find records where the subject_quality_score is 10 -- only looking for home taps -- and where the source
-- was visited a second time. What will this tell us?

--  get 218 rows of data. But this should not be happening! I think some of our employees may have made mistakes. To be honest, I'll
-- be surprised if there are no errors in our data at this scale! I’m going to send Pres. Naledi a message that we have to recheck some of
-- thEse sources. We can appoint an Auditor to check some of the data independently, and make sure we have the right information!
SELECT *
FROM WATER_QUALITY
WHERE SUBJECTIVE_QUALITY_SCORE = 10
AND VISIT_COUNT = 2;

-- 5. Investigate pollution issues:
-- Did you notice that we recorded contamination/pollution data for all of the well sources? 
-- Find the right table and print the first few rows.
SELECT *
FROM md_water_services.well_pollution;

-- So, write a query that checks if the results is Clean but the biological column is > 0.01.
SELECT *
FROM md_water_services.WELL_POLLUTION
WHERE RESULTS = 'CLEAN' AND BIOLOGICAL > 0.01;

-- To find these descriptions, search for the word Clean with additional characters after it.
--  As this is what separates incorrect descriptions from the records that should have "Clean".
 
SELECT *
FROM md_water_services.well_pollution
WHERE description LIKE '%CLEAN%'
AND BIOLOGICAL >0.01;

/*Looking at the results we can see two different descriptions that we need to fix:
1. All records that mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli
2. All records that mistakenly have Clean Bacteria: Giardia Lamblia should updated to Bacteria: Giardia Lamblia*/

-- Case 1a: Update descriptions that mistakenly mention 'Clean Bacteria: E. coli' to 'Bacteria: E. coli'
SET SQL_SAFE_UPDATES = 0;
UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

-- Case 1b: Update descriptions that mistakenly mention 'Clean Bacteria: Giardia Lamblia' to 'Bacteria: Giardia Lamblia'
UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

-- Case 2: Update the `result` to `Contaminated: Biological` where `biological` is greater than 0.01 and current result is `Clean`
UPDATE well_pollution
SET resultS = 'Contaminated: Biological'
WHERE biological > 0.01 AND resultS = 'Clean';


CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);


SELECT *
FROM MD_WATER_SERVICES.well_pollution_copy
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);


UPDATE
well_pollution_copy
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';
UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
well_pollution_copy
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';
DROP TABLE
md_water_services.well_pollution_copy;
