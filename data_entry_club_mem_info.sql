--create table
CREATE TABLE club_member_info (
    full_name varchar(100),
    age int,
    matial_status varchar(50),
    email varchar(150),
    phone varchar(20),
    full_adress varchar(150),
    job_title varchar(100),
    membership_date date
);


--copy data from csv file
COPY Public."club_member_info" FROM 'D:\club_member_info.csv' DELIMITER ',' CSV HEADER;

--display table
SELECT * FROM club_member_info;

--add member_id column
AlTER TABLE club_member_info
ADD COLUMN member_id SERIAL PRIMARY KEY;

--create new table with new order
CREATE TABLE new_club_member_info (
    member_id SERIAL PRIMARY KEY,
    full_name varchar(100),
    age int,
    matial_status varchar(50),
    email varchar(150),
    phone varchar(20),
    full_adress varchar(150),
    job_title varchar(100),
    membership_date date
);

--display new table
SELECT * FROM new_club_member_info;

--copy data from old table
INSERT INTO new_club_member_info (member_id, full_name, age, matial_status, email, phone, full_adress)
SELECT member_id, full_name, age, matial_status, email, phone, full_adress
FROM club_member_info;









