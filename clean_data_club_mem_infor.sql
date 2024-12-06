'''In this project, I will 
1. Check for duplicate entries and remove them.
2. Remove extra spaces and/or other invalid characters.
3. Separate or combine values as needed.
4. Ensure that certain values (age, dates...) are within certain range.
5. Check for outliers.
6. Correct incorrect spelling or inputted data.
7. Adding new and relevant rows or columns to the new dataset.
8. Check for null or empty values.'''


--query dataset
SELECT * FROM new_club_member_info
LIMIT 10;

--create a temp table to manipulate and restructure the data without altering the original. 
DROP TABLE IF EXISTS cleaned_club_member_info;
CREATE TABLE cleaned_club_member_info AS (

--cleaning data procedure
	SELECT
		member_id ,
--full_name column, we need proper the full name, remove space 
		regexp_replace(split_part(trim(initcap(full_name)), ' ', 1), '\W+', '', 'g') AS first_name,
		CASE
			WHEN array_length(string_to_array(trim(initcap(full_name)), ' '), 1) = 3 THEN concat(split_part(trim(initcap(full_name)), ' ', 2) || ' ' || split_part(trim(initcap(full_name)), ' ', 3))
			WHEN array_length(string_to_array(trim(initcap(full_name)), ' '), 1) = 4 THEN concat(split_part(trim(initcap(full_name)), ' ', 2) || ' ' || split_part(trim(initcap(full_name)), ' ', 3) || ' ' || split_part(trim(initcap(full_name)), ' ', 4))
			ELSE split_part(trim(initcap(full_name)), ' ', 2)
		END AS last_name,
--age_column, we remove some digits at the end of some values
		CASE
		WHEN length(age::text) = 0 THEN NULL
		WHEN length(age::text) = 3 THEN substr(age::text, 1, 2)::numeric
			ELSE age
		END age ,

--martial_status column, we trim whitespace and if empty, ensure its of null type
		CASE
			WHEN trim(matial_status) = '' THEN NULL
			ELSE trim(matial_status)
		END AS matial_status ,

--email_column, we convert to lowercase and trim off any whitespace
		trim(lower(email)) AS member_email,

--phone_column, we trim whitespace and if empty or incomplete, ensure its of null type
		CASE
			WHEN trim(phone) = '' THEN NULL
			WHEN length(trim(phone)) < 12 THEN NULL
			ELSE trim(phone)
		END AS phone ,

--full_address column, we convert to lowercase, trim off any whitespace and split the full address to individual street address, city and state.
		split_part(trim(lower(full_adress)), ',', 1) AS street_address,
		split_part(trim(lower(full_adress)), ',', 2) AS city,
		split_part(trim(lower(full_adress)), ',', 3) AS state,

--job_title column, we convert levels to numbers and add descriptor (ex. Level 3).
-- Trim whitespace from job title, rename to occupation and if empty convert to null type.
		CASE
			WHEN trim(lower(job_title)) = '' THEN NULL
		ELSE 
			CASE
				WHEN array_length(string_to_array(trim(job_title), ' '), 1) > 1 AND lower(split_part(job_title, ' ', array_length(string_to_array(trim(job_title), ' '), 1))) = 'i'
					THEN replace(lower(job_title), ' i', ', level 1')
				WHEN array_length(string_to_array(trim(job_title), ' '), 1) > 1 AND lower(split_part(job_title, ' ', array_length(string_to_array(trim(job_title), ' '), 1))) = 'ii'
					THEN replace(lower(job_title), ' ii', ', level 2')
				WHEN array_length(string_to_array(trim(job_title), ' '), 1) > 1 AND lower(split_part(job_title, ' ', array_length(string_to_array(trim(job_title), ' '), 1))) = 'iii'
					THEN replace(lower(job_title), ' iii', ', level 3')
				WHEN array_length(string_to_array(trim(job_title), ' '), 1) > 1 AND lower(split_part(job_title, ' ', array_length(string_to_array(trim(job_title), ' '), 1))) = 'iv'
					THEN replace(lower(job_title), ' iv', ', level 4')
				ELSE trim(lower(job_title))
			END 
		END AS occupation,

--membership_date column, a few members show membership_date year in the 1900's.  Change the year into the 2000's
		CASE 
			WHEN EXTRACT('year' FROM membership_date) < 2000 
				THEN concat(replace(EXTRACT('year' FROM membership_date)::text, '19', '20') || '-' || EXTRACT('month' FROM membership_date) || '-' || EXTRACT('day' FROM membership_date))::date
			ELSE membership_date
		END AS membership_date
		FROM new_club_member_info
);

--Display new clean data table
SELECT * FROM cleaned_club_member_info 
LIMIT 10;


--Check DUPLICATE process
SELECT count(*) AS record_count 
FROM cleaned_club_member_info;

-- All members must have a unique email address to join. Lets try to find duplicate entries.
SELECT member_email,
	count(member_email)
FROM 
	cleaned_club_member_info
GROUP BY 
	member_email
HAVING 
	count(member_email) > 1

--REMOVE DUPLICATE entries
DELETE FROM 
	cleaned_club_member_info AS c1
USING 
	cleaned_club_member_info AS c2
WHERE 
	c1.member_id < c2.member_id 
AND 
	c1.member_email = c2.member_email;

--record count after REMOVING
SELECT count(*) AS new_record_count 
FROM 
	cleaned_club_member_info;

--record count where matial_status is NULL
SELECT count(*) AS null_record_count 
FROM 
	cleaned_club_member_info
WHERE matial_status IS null;	


--count each type of maritial_status
SELECT matial_status,
	count(*) AS new_record_count 
FROM 
	cleaned_club_member_info
GROUP BY 
	matial_status;

--correct spelling mistake 'divorced'
UPDATE cleaned_club_member_info
SET 
	matial_status = 'divorced'
WHERE 
	matial_status = 'divored';

--recheck maritial_status column
SELECT matial_status,
	count(*) AS new_record_count 
FROM 
	cleaned_club_member_info
GROUP BY 
	matial_status;


--check state_column
SELECT state
FROM 
	cleaned_club_member_info
GROUP BY 
	state;


--correct some spelling mistakes of state
UPDATE
	cleaned_club_member_info
SET 
	state = 'kansas'
WHERE 
	state = 'kansus';

UPDATE
	cleaned_club_member_info
SET 
	state = 'district of columbia'
WHERE 
	state = 'districts of columbia';

UPDATE
	cleaned_club_member_info
SET 
	state = 'north carolina'
WHERE 
	state = 'northcarolina';

UPDATE
	cleaned_club_member_info
SET 
	state = 'california'
WHERE 
	state = 'kalifornia';

UPDATE
	cleaned_club_member_info
SET 
	state = 'texas'
WHERE 
	state = 'tejas';

UPDATE
	cleaned_club_member_info
SET 
	state = 'texas'
WHERE 
	state = 'tej+f823as';

UPDATE
	cleaned_club_member_info
SET 
	state = 'tennessee'
WHERE 
	state = 'tennesseeee';

UPDATE
	cleaned_club_member_info
SET 
	state = 'new york'
WHERE 
	state = 'newyork';

UPDATE
	cleaned_club_member_info
SET 
	state = 'puerto rico'
WHERE 
	state = ' puerto rico';

--count again distict state
SELECT
	count(DISTINCT state)
FROM 
	cleaned_club_member_info
	
--display state_column after fix
SELECT state
FROM 
	cleaned_club_member_info
GROUP BY 
state;

--covert order member_id to DES order
WITH cte AS (
    SELECT member_id, ROW_NUMBER() OVER (ORDER BY member_id) AS new_id
    FROM cleaned_club_member_info
)
UPDATE cleaned_club_member_info
SET member_id = cte.new_id
FROM cte
WHERE cleaned_club_member_info.member_id = cte.member_id;


--Display new clean data table
SELECT * FROM cleaned_club_member_info ORDER BY member_id;

-- Output to csv file.
COPY (SELECT * FROM cleaned_club_member_info ORDER BY member_id) TO 'D:\exporter\cleanclubmem.csv' WITH CSV HEADER;
