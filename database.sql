create database tel_management;

use tel_management;

create table charges
( 
code integer ,
type integer ,
cost integer,
primary key(code,type)
);

create table amenities
(
a_id integer primary key AUTO_INCREMENT,
a_type integer,
a_status integer,
a_capacity integer,
a_title varchar(50),
a_description text
);

create table rooms
(
r_id  varchar(4) primary key ,
r_number integer,
r_type integer,
r_capacity integer,
r_status integer
);

create table admins(
id integer primary key AUTO_INCREMENT,
name varchar(20) not null,
email varchar(50),
username varchar(50) not null,
password varchar(50) not null
);

create table guests
( 
g_id integer primary key AUTO_INCREMENT,
g_name varchar(50),
g_email varchar(50),
g_count varchar(50),
g_streetno varchar(50),
g_city varchar(50),
g_state varchar(50),
g_country varchar(50),
g_pincode varchar(50)
);

create table bookings
(
b_id integer primary key,
r_id varchar(50),
g_id integer,
b_status integer not null,
a_id integer,
st date,
et date
);

create table login_attempts
(
    username varchar(255) not null,
    success int not null
);

#procedures for amenities
#creating procedure for selecting records from amenities table

DELIMITER //
CREATE PROCEDURE get_all_amenities()
BEGIN
	SELECT * FROM amenities;
END//
DELIMITER ;

#get amenity by id
DELIMITER //
CREATE PROCEDURE get_amenity_by_id (IN id INT)
BEGIN
  DECLARE amenity_id INT;
  DECLARE amenity_type int;
  DECLARE amenity_status int;
  DECLARE amenity_description TEXT;
  DECLARE amenity_cap int;
  DECLARE amenity_title varchar(50);
  DECLARE amenity_cursor CURSOR FOR SELECT a_id, a_type, a_status,a_capacity,a_title, a_description FROM amenities WHERE a_id = id;
  OPEN amenity_cursor;
  FETCH amenity_cursor INTO amenity_id, amenity_type, amenity_status, amenity_cap,amenity_title,amenity_description;
  CLOSE amenity_cursor;
  SELECT amenity_id, amenity_type, amenity_status, amenity_cap,amenity_title,amenity_description;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_amenity_id BEFORE INSERT ON amenities
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM amenities WHERE a_id = NEW.a_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amenity ID already exists';
    END IF;
END//
DELIMITER ;


#procedure for inserting into amenities
DELIMITER //
CREATE PROCEDURE add_amenity(IN idd INT, IN type int, IN status int, IN capacity int, IN title VARCHAR(50), IN description TEXT)
BEGIN
    INSERT INTO amenities(a_id, a_type, a_status, a_capacity, a_title, a_description) VALUES(idd, type, status, capacity, title, description);
END//

DELIMITER ;

#procedure for updating amenities
DELIMITER //
CREATE PROCEDURE update_amenity(
    IN amenity_id INT,
    IN amenity_type int,
    IN amenity_status int,
    IN amenity_capacity INT,
    IN amenity_title VARCHAR(50),
    IN amenity_description TEXT
)
BEGIN
    UPDATE amenities
    SET a_type = amenity_type,
        a_status = amenity_status,
        a_capacity = amenity_capacity,
        a_title = amenity_title,
        a_description = amenity_description
    WHERE a_id = amenity_id;
END//

DELIMITER ;

#procedure for deleting amenities
DELIMITER //
CREATE PROCEDURE delete_amenity(IN amenity_id INT)
BEGIN
    DELETE FROM amenities WHERE a_id = amenity_id;
END//

DELIMITER ;

#procedures for rooms
#creating procedure to fetch the details of all the rooms
DELIMITER //
CREATE PROCEDURE get_all_rooms()
BEGIN
  SELECT * FROM rooms;
END//

#trigger for inserting
DELIMITER //
CREATE TRIGGER before_insert_room
BEFORE INSERT ON rooms
FOR EACH ROW
BEGIN
  DECLARE room_id VARCHAR(4);
  SELECT r_id INTO room_id FROM rooms WHERE r_id = NEW.r_id LIMIT 1;
  IF room_id IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room ID already exists';
  END IF;
END//
DELIMITER ;


DELIMITER ;
#procedure to insert into rooms
DELIMITER //
CREATE PROCEDURE insert_room(IN p_id varchar(4), IN p_number int, IN p_type int, IN p_capacity INT, IN p_status int)
BEGIN
  INSERT INTO rooms (r_id, r_number, r_type, r_capacity, r_status)
  VALUES (p_id, p_number, p_type, p_capacity, p_status);
END//

DELIMITER ;

#procedure to update rooms using cursor

DELIMITER //
CREATE PROCEDURE update_room(IN room_id varchar(4), IN room_type int, IN room_status int, IN room_capacity int)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE old_type INT;
  DECLARE old_status INT;
  DECLARE old_capacity INT;
  DECLARE room_cur CURSOR FOR SELECT r_type, r_status, r_capacity FROM rooms WHERE r_id = room_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN room_cur;
  FETCH room_cur INTO old_type, old_status, old_capacity;
  IF NOT done THEN
    UPDATE rooms SET r_type = room_type, r_status = room_status, r_capacity = room_capacity WHERE r_id = room_id;
  END IF;
  CLOSE room_cur;
END//
DELIMITER ;

#procedure to delete rooms
DELIMITER //
CREATE PROCEDURE delete_room(IN room_id varchar(4))
BEGIN
    DELETE FROM rooms WHERE r_id = room_id;
END//

DELIMITER ;

--procedures for guests
DELIMITER //
CREATE PROCEDURE select_all_guests()
BEGIN
    SELECT * FROM guests;
END//

DELIMITER ;

#procedure to insert into guests
DELIMITER //
CREATE PROCEDURE insert_guests (IN id int, IN name varchar(50), IN email varchar(50),IN count varchar(50),IN streetno varchar(50),IN city varchar(50),IN state varchar(50),IN country varchar(50),IN pincode varchar(50))
BEGIN
  INSERT INTO guests VALUES (id,name,email,count,streetno,city,state,country,pincode);
END//

DELIMITER //
CREATE PROCEDURE DELETE_GUESTS(IN id int)
BEGIN
	DELETE FROM guests where g_id=id;
END//

#procedures for admins
#procedure for inserting a data into admin
DELIMITER //
CREATE PROCEDURE insert_admin (IN admin_name VARCHAR(20), IN admin_email VARCHAR(50), IN admin_username VARCHAR(50), IN admin_password VARCHAR(50))
BEGIN
  INSERT INTO admins (name, email, username, password) VALUES (admin_name, admin_email, admin_username, admin_password);
END//

DELIMITER ;

#trigger to check if no username found

#checking the validity of login
-- Procedure to check if username exists in admins table
DELIMITER //
CREATE PROCEDURE check_username(IN p_username VARCHAR(50), OUT p_user_id INT)
BEGIN
    SELECT id INTO p_user_id FROM admins WHERE username = p_username;
END//

DELIMITER ;

#Procedure to check if password matches for a given user ID
DELIMITER //
CREATE PROCEDURE check_password(IN p_user_id INT, IN p_password VARCHAR(50), OUT p_match BOOL)
BEGIN
    DECLARE password_hash CHAR(64);
    SELECT password INTO password_hash FROM admins WHERE id = p_user_id;
    IF password_hash IS NULL THEN
        SET p_match = FALSE;
    ELSE
        SET p_match = password_hash = SHA2(CONCAT(p_password, salt), 256);
    END IF;
END//

DELIMITER ;

#deleting from admin
DELIMITER //

CREATE PROCEDURE delete_admin(IN idd int)
BEGIN
	DELETE FROM admin where id=idd;
END//


#PROCEDURE FOR CHARGES
#INSERTING INTO CHARGES

DELIMITER //
CREATE PROCEDURE insert_charges (in c int,in t int,in co int)
BEGIN
  INSERT INTO guests VALUES (c,t,co);
END//

DELIMITER //
CREATE PROCEDURE delete_charges(in c int,in t int)
BEGIN
	DELETE FROM charges where code=c and type=t;
END//

DELIMITER //
CREATE PROCEDURE update_charges(in c int,in t int, in co int)
BEGIN
	UPDATE charges set cost=co where code=c and type=t;
END //


#PROCEDURE FOR BOOKINGS

#INSERT 
DELIMITER //
CREATE PROCEDURE insert_bookings(in id int,in rid varchar(50),in gid int,in bs int,in aid int,in st date,in et date, in ftype int,in cost float)
BEGIN
	insert into bookings values(id,rid,gid,bs,aid,st,et,ftype,cost);
END//

#DELETE
DELIMITER //
CREATE PROCEDURE delete_booking(in id int)
BEGIN
	DELETE FROM bookings where b_id=id;
END//


SELECT * FROM charges WHERE code = 1;
SELECT * FROM charges WHERE code = 1 AND type = <whatever_f_type_is>;

ALTER TABLE guests ADD checkout_status BOOLEAN DEFAULT FALSE;
 show tables;

ALTER TABLE guests ADD checkout_date DATETIME;

CREATE TABLE archived_guests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    room_number VARCHAR(50),
    check_in DATE,
    check_out DATE,
    total_amount DECIMAL(10,2),
    billing_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SHOW TABLES;
SELECT * FROM archived_guests LIMIT 10;
DROP TABLE IF EXISTS amenities;
show tables;
CREATE TABLE amenities (
    a_id INT AUTO_INCREMENT PRIMARY KEY,
    a_type VARCHAR(100),
    a_status VARCHAR(50),
    a_capacity INT,
    a_title VARCHAR(50),
    a_description TEXT,
    cost DECIMAL(10,2)
);

desc amenities;

ALTER TABLE amenities MODIFY a_type VARCHAR(100);

INSERT INTO amenities (a_type, a_status, a_capacity, a_title, a_description, cost)
VALUES ('Water', 'Available', 100, 'Drinking Water', 'Clean filtered water supply', 100.00);

ALTER TABLE amenities MODIFY COLUMN amenity_type VARCHAR(100);

INSERT INTO amenities (a_type, cost) VALUES ('1', 1000.00);
INSERT INTO amenities (a_type, cost) VALUES ('2', 2000.00);
INSERT INTO amenities (a_type, cost) VALUES ('3', 3000.00);
INSERT INTO amenities (a_type, cost) VALUES ('4', 4000.00);

ALTER TABLE amenities ADD COLUMN amenity_type VARCHAR(100);

DROP TABLE IF EXISTS amenities;
CREATE TABLE amenities (
    a_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    a_type VARCHAR(100) NOT NULL,  -- a_type as VARCHAR to store string values
    a_status INT,  -- Assuming you want to keep status as an integer (0 or 1 for example)
    a_capacity INT,
    a_title VARCHAR(50),
    a_description TEXT,
    cost DECIMAL(10,2)
);

select *from amenities;
select *from charges;

DROP TABLE IF EXISTS charges;
CREATE TABLE charges (
    code INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- Assuming 'code' is an auto-increment value
    type INT,  -- Type of the charge (could be linked to amenities table)
    cost DECIMAL(10, 2)  -- Cost of the charge
);
INSERT INTO charges (type, cost)
VALUES
    (1, 1500),
    (2, 2000),
    (3, 4000);
















