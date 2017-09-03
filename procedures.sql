delimiter $$

CREATE DATABASE `travelo_db` /*!40100 DEFAULT CHARACTER SET latin1 */$$


delimiter $$

CREATE DEFINER=`prabhat`@`182.71.170.162` PROCEDURE `add_new_booking`(
    packageID INT,
    name_Details  VARCHAR(500),
    journeymodeUP VARCHAR(500),
    journeymodeDOWN VARCHAR(500),
    residentialAddress VARCHAR(500),
    currentAddress VARCHAR(500), 
    contactNo  VARCHAR(15), 
    emailID VARCHAR(45),
	panCARD VARCHAR(45),
	voterCARD VARCHAR(45),
	passportNO VARCHAR(45),
	drivingLicense VARCHAR(45),
    mode    TINYINT, 
	bookingID INT,
	countNo INT,
	age_break_UP varchar(20),
	sbr_count INT,
	dbr_count INT,
	tbr_count INT,
	fID varchar(50)
    )
BEGIN
	
	-- Time of Insert 
	
	IF (mode = 0) THEN
		BEGIN

			
	DECLARE var_available_seats INT;
	DECLARE var_waiting_list INT;
	DECLARE var_booking_id INT;
	
	SET var_available_seats = (SELECT seats_available FROM tr_Package_availability WHERE package_id = packageID);
	SET var_waiting_list = (SELECT waiting_list FROM tr_Package_availability WHERE package_id = packageID);
	
			
			INSERT INTO tr_booking_details
			(
			`package_id` ,
			`booking_time` ,
			`update_time` ,
			`name_details` ,
			`mode_of_journey_up`,
			`mode_of_journey_down`,
			`residential_address`,
			`current_address` ,
			`contact_no`,
			`email_id`,
			`Pan_card`,
			`Voter_card`,
			`Passport_no`,
			`Driving_license`,
			sbr_count,
			dbr_count,
			tbr_count,
			age_break_up,
			count_head,
			fid
			)
			VALUES
			(
			packageID ,
			now() ,
			now() ,
			name_Details ,
			journeymodeUP, 
			journeymodeDOWN ,
			residentialAddress ,
			currentAddress, 
			contactNo, 
			emailID,
			panCARD,
			voterCARD,
			passportNO,
			drivingLicense,
			age_break_UP,
			sbr_count,
			dbr_count,
			tbr_count,
			countNo,
			fID
			);
			
			SELECT LAST_INSERT_ID() INTO var_booking_id;
			/*
			INSERT INTO tr_booking_files(booking_id,fid,deleted)
			(SELECT var_booking_id,fID,0);
				*/

			IF var_available_seats > countNo THEN

				UPDATE tr_Package_availability pp 
				SET pp.seats_available = pp.seats_available - countNo WHERE pp.package_id = packageID;

			END IF;


			IF (var_available_seats = 0 AND  var_waiting_list <= 22 ) THEN

				UPDATE tr_Package_availability pp 
				SET pp.waiting_list = pp.waiting_list + countNo WHERE pp.package_id = packageID;

			END IF;

			IF(var_available_seats >0 AND var_available_seats < countNo) THEN
				UPDATE tr_Package_availability pp 
				SET pp.waiting_list = countNo - var_available_seats,pp.seats_available=0 WHERE pp.package_id = packageID;
			END IF;
		END;
	END IF;
		
	
	
	
    
	-- Time of Update
	
	IF( mode = 1 ) THEN
	
	BEGIN
	
		DECLARE pre_count INT;
		DECLARE difference_count INT;
		DECLARE var_available_seats INT;
		DECLARE var_waiting_list INT;
		DECLARE package_SEAT_count INT;

	
		SET pre_count = (SELECT count_head from tr_booking_details where booking_id = bookingID);
		SET difference_count = pre_count - countNo;
		
		SELECT package_seats from tr_package where package_id = packageID INTO package_SEAT_count;

		IF(difference_count>0) THEN


			UPDATE tr_booking_details tr SET tr.deleted = 1
			WHERE  tr.booking_id = bookingID;

			SET var_available_seats = (SELECT seats_available FROM tr_Package_availability WHERE package_id = packageID);
			SET var_waiting_list = (SELECT waiting_list FROM tr_Package_availability WHERE package_id = packageID);
			
			IF (var_available_seats < package_SEAT_count - difference_count   AND var_available_seats > 0 ) THEN
	
				UPDATE tr_Package_availability pp 
				SET pp.seats_available = pp.seats_available + difference_count WHERE pp.package_id = packageID;
	
			ELSE 
			
				IF ( var_waiting_list  >= difference_count ) THEN
			
					UPDATE tr_Package_availability pp 
					SET pp.waiting_list = pp.waiting_list - difference_count WHERE pp.package_id = packageID;
			
				ELSE
					
					UPDATE tr_Package_availability pp 
					SET pp.seats_available = pp.seats_available + difference_count - var_waiting_list,pp.waiting_list=0  WHERE pp.package_id = packageID;
				END IF;
					
			END IF;

		END IF;
			
		
		
		
		UPDATE tr_booking_details tr
		SET tr.package_id = IFNULL(packageID,tr.package_id),
			tr.update_time = now(),
			tr.name_details = IFNULL(name_Details,tr.name_details),
			tr.mode_of_journey_up = IFNULL(journeymodeUP,tr.mode_of_journey_up),
			tr.mode_of_journey_down = IFNULL(journeymodeDOWN,tr.mode_of_journey_down),
			tr.residential_address = IFNULL(residentialAddress,tr.residential_address),
			tr.current_address = IFNULL(currentAddress,tr.current_address),
			tr.contact_no = IFNULL(contactNo,tr.contact_no),
			tr.email_id = IFNULL(emailID,tr.email_id),
			tr.Pan_card = IFNULL(panCARD,tr.Pan_card),
			tr.Voter_card = IFNULL(voterCARD,tr.Voter_card),
			tr.Passport_no = IFNULL(passportNO,tr.Passport_no),
			tr.Driving_license = IFNULL(drivingLicense,tr.Driving_license),
			tr.age_break_up=IFNULL(age_break_UP,tr.age_break_up),
			tr.sbr_count=IFNULL(sbr_count,tr.sbr_count),
			tr.dbr_count=IFNULL(dbr_count,tr.dbr_count),
			tr.tbr_count=IFNULL(tbr_count,tr.tbr_count),
			tr.count_head=IFNULL(countNo,tr.count_head),
			tr.fid=IFNULL(fID,tr.fid)
			
		WHERE tr.booking_id = bookingID;
	END	;
	END IF;
END$$


delimiter $$

CREATE DEFINER=`prabhat`@`%` PROCEDURE `add_or_edit_package`( IN placeID INT, IN packageDATE DATE,IN packageSEAT INT, IN packageID INT)
BEGIN
DECLARE var_package_id INT;
DECLARE var_available INT DEFAULT 0;

	IF (packageID IS NULL) THEN

		SELECT COUNT(*)>0 INTO var_available FROM tr_package WHERE package_date=packageDATE AND place_id = placeID AND active = 1;
		IF(var_available = 1) THEN
			SELECT 2 AS val;
		ELSE

			INSERT INTO tr_package(place_id,package_date,payer_id,package_seats,active)
			(SELECT placeID,packageDATE,1,packageSEAT,1);

			SELECT last_insert_id() INTO var_package_id;
				
			INSERT INTO tr_Package_availability(SELECT var_package_id,1,packageSEAT,0,1);
			SELECT 1 as val;
		END IF;

	END IF;

	IF (packageID IS NOT NULL) THEN

		UPDATE tr_package SET package_date = packageDATE WHERE package_id = packageID;

	END IF;

	


END$$


delimiter $$

CREATE DEFINER=`prabhat`@`%` PROCEDURE `delete_bookings`(IN bookingID INT,IN packageID INT)
BEGIN
		
			DECLARE var_available_seats INT;
			DECLARE var_waiting_list INT;
			DECLARE var_count INT;
			DECLARE package_SEAT_count INT;

			SELECT count_head from tr_booking_details where booking_id=bookingID INTO var_count;
			SELECT package_seats from tr_package where package_id = packageID INTO package_SEAT_count;

			UPDATE tr_booking_details tr SET tr.deleted = 2,tr.package_id = packageID
			WHERE  tr.booking_id = bookingID;


	
	
			SET var_available_seats = (SELECT seats_available FROM tr_Package_availability WHERE package_id = packageID);
			SET var_waiting_list = (SELECT waiting_list FROM tr_Package_availability WHERE package_id = packageID);
			
			IF (var_available_seats < package_SEAT_count - var_count   AND var_available_seats > 0 ) THEN
	
			UPDATE tr_Package_availability pp 
				SET pp.seats_available = pp.seats_available + var_count WHERE pp.package_id = packageID;
	
		
	
			ELSE 
			
				IF ( var_waiting_list  >= var_count ) THEN
			
					UPDATE tr_Package_availability pp 
						SET pp.waiting_list = pp.waiting_list - varcount WHERE pp.package_id = packageID;
			
				ELSE
					
					UPDATE tr_Package_availability pp 
						SET pp.seats_available = pp.seats_available + var_count - var_waiting_list,pp.waiting_list=0  WHERE pp.package_id = packageID;
				END IF;
					
				
			END IF;

			
			
	
		END$$


delimiter $$

CREATE DEFINER=`prabhat`@`%` PROCEDURE `delete_one_package`( IN packageID INT)
BEGIN

	UPDATE tr_Package_availability SET active=0
	WHERE package_id = packageID;

	UPDATE tr_package SET active= 0
	WHERE package_id = packageID;

	UPDATE tr_booking_details
	SET deleted = 2
	WHERE package_id = packageID;

END$$


delimiter $$

CREATE DEFINER=`prabhat`@`%` PROCEDURE `export_package`(IN packageID INT)
BEGIN
	SELECT concat(SPLIT_STR(name_details,':',1),'(',age_break_up,')') as contact_person, sbr_count AS SBR,dbr_count AS DBR,tbr_count AS TBR 
	from tr_booking_details WHERE package_id = packageID and deleted!= 2 ;
	
	SELECT sum(sbr_count) AS total_sbr,sum(dbr_count) AS total_dbr,sum(tbr_count) AS total_tbr from tr_booking_details WHERE package_id = packageID and deleted!= 2 ;
	
END$$


delimiter $$

CREATE DEFINER=`prabhat`@`%` PROCEDURE `get_booking_details`(IN packageID INT,IN locationID INT,IN nameDetails VARCHAR(50),IN contactNo VARCHAR(12))
BEGIN
	
		DECLARE var_search_string VARCHAR(50) DEFAULT CONCAT('%', nameDetails, '%');
		DECLARE filtered_count INT DEFAULT 0;
		
			SELECT SQL_CALC_FOUND_ROWS
			a.booking_id,
			b.package_id ,
			`booking_time` ,
			`update_time` ,
			sbr_count,
			dbr_count,
			tbr_count,
			`name_details` ,
			`mode_of_journey_up`,
			`mode_of_journey_down`,
			`residential_address`,
			`current_address` ,
			`contact_no`,
			`email_id`,
			`Pan_card`,
			`Voter_card`,
			`Passport_no`,
			`Driving_license`,
			c.place_id,
			c.place_name,
			b.package_date,
			a.fid
			/*e.journey_mode_name as  mode_of_journey_up_name,
			f.journey_mode_name as  mode_of_journey_down_name, */
			/*g.fid,
			h.uri,
			h.filename
			*/

			 FROM tr_booking_details a
			 JOIN tr_package b on (a.package_id=b.package_id)
				join tr_package_place c on (c.place_id=b.place_id)
				-- join tr_package_accomodation d on (a.accomodation_mode=d.accomodation_mode)
				-- join tr_package_journey_mode e on (a.mode_of_journey_up=e.journey_mode_id)
				-- join tr_package_journey_mode f on (a.mode_of_journey_down=f.journey_mode_id)
				-- join tr_booking_files g on (a.booking_id = g.booking_id) 
				-- join file_managed h on (h.fid=g.fid)
				WHERE (packageID IS NULL or b.package_id = packageID)
			 AND (var_search_string IS NULL OR a.name_details LIKE var_search_string)
			 AND (c.place_id=locationID OR locationID IS NULL )
			 AND (a.contact_no=contactNo OR contactNo IS NULL )
			 AND a.deleted != 2
				order by booking_time ;
			 
			SELECT FOUND_ROWS() INTO filtered_count;
			SELECT filtered_count ,COUNT(*) AS total_count FROM tr_booking_details where deleted != 2 ;
	
    

END$$


delimiter $$

CREATE DEFINER=`prabhat`@`%` FUNCTION `SPLIT_STR`(
  LongString VARCHAR(200),
  delim VARCHAR(5),
  pos INT
) RETURNS varchar(200) CHARSET latin1
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(LongString, delim, pos),
       LENGTH(SUBSTRING_INDEX(LongString, delim, pos -1)) + 1),
       delim, '')$$


	   
	   -- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`prabhat`@`182.71.170.162` PROCEDURE `add_new_booking`(
    packageID INT,
    name_Details  VARCHAR(500),
    journeymodeUP VARCHAR(500),
    journeymodeDOWN VARCHAR(500),
    residentialAddress VARCHAR(500),
    currentAddress VARCHAR(500), 
    contactNo  VARCHAR(15), 
    emailID VARCHAR(45),
	panCARD VARCHAR(45),
	voterCARD VARCHAR(45),
	passportNO VARCHAR(45),
	drivingLicense VARCHAR(45),
    mode    TINYINT, 
	bookingID INT,
	countNo INT,
	age_break_UP varchar(20),
	sbr_count INT,
	dbr_count INT,
	tbr_count INT,
	fID varchar(50)
    )
BEGIN
	
	-- Time of Insert 
	
	IF (mode = 0) THEN
		BEGIN

			
	DECLARE var_available_seats INT;
	DECLARE var_waiting_list INT;
	DECLARE var_booking_id INT;
	
	SET var_available_seats = (SELECT seats_available FROM tr_Package_availability WHERE package_id = packageID);
	SET var_waiting_list = (SELECT waiting_list FROM tr_Package_availability WHERE package_id = packageID);
	
			
			INSERT INTO tr_booking_details
			(
			`package_id` ,
			`booking_time` ,
			`update_time` ,
			`name_details` ,
			`mode_of_journey_up`,
			`mode_of_journey_down`,
			`residential_address`,
			`current_address` ,
			`contact_no`,
			`email_id`,
			`Pan_card`,
			`Voter_card`,
			`Passport_no`,
			`Driving_license`,
			sbr_count,
			dbr_count,
			tbr_count,
			age_break_up,
			count_head,
			fid
			)
			VALUES
			(
			packageID ,
			now() ,
			now() ,
			name_Details ,
			journeymodeUP, 
			journeymodeDOWN ,
			residentialAddress ,
			currentAddress, 
			contactNo, 
			emailID,
			panCARD,
			voterCARD,
			passportNO,
			drivingLicense,
			age_break_UP,
			sbr_count,
			dbr_count,
			tbr_count,
			countNo,
			fID
			);
			
			SELECT LAST_INSERT_ID() INTO var_booking_id;
			/*
			INSERT INTO tr_booking_files(booking_id,fid,deleted)
			(SELECT var_booking_id,fID,0);
				*/

			IF var_available_seats > countNo THEN

				UPDATE tr_Package_availability pp 
				SET pp.seats_available = pp.seats_available - countNo WHERE pp.package_id = packageID;

			END IF;


			IF (var_available_seats = 0 AND  var_waiting_list <= 22 ) THEN

				UPDATE tr_Package_availability pp 
				SET pp.waiting_list = pp.waiting_list + countNo WHERE pp.package_id = packageID;

			END IF;

			IF(var_available_seats >0 AND var_available_seats < countNo) THEN
				UPDATE tr_Package_availability pp 
				SET pp.waiting_list = countNo - var_available_seats,pp.seats_available=0 WHERE pp.package_id = packageID;
			END IF;
		END;
	END IF;
		
	
	
	
    
	-- Time of Update
	
	IF( mode = 1 ) THEN
	
	BEGIN
	
		DECLARE pre_count INT;
		DECLARE difference_count INT;
		DECLARE var_available_seats INT;
		DECLARE var_waiting_list INT;
		DECLARE package_SEAT_count INT;

	
		SET pre_count = (SELECT count_head from tr_booking_details where booking_id = bookingID);
		SET difference_count = pre_count - countNo;
		
		SELECT package_seats from tr_package where package_id = packageID INTO package_SEAT_count;

		IF(difference_count>0) THEN


			UPDATE tr_booking_details tr SET tr.deleted = 1
			WHERE  tr.booking_id = bookingID;

			SET var_available_seats = (SELECT seats_available FROM tr_Package_availability WHERE package_id = packageID);
			SET var_waiting_list = (SELECT waiting_list FROM tr_Package_availability WHERE package_id = packageID);
			
			IF (var_available_seats < package_SEAT_count - difference_count   AND var_available_seats > 0 ) THEN
	
				UPDATE tr_Package_availability pp 
				SET pp.seats_available = pp.seats_available + difference_count WHERE pp.package_id = packageID;
	
			ELSE 
			
				IF ( var_waiting_list  >= difference_count ) THEN
			
					UPDATE tr_Package_availability pp 
					SET pp.waiting_list = pp.waiting_list - difference_count WHERE pp.package_id = packageID;
			
				ELSE
					
					UPDATE tr_Package_availability pp 
					SET pp.seats_available = pp.seats_available + difference_count - var_waiting_list,pp.waiting_list=0  WHERE pp.package_id = packageID;
				END IF;
					
			END IF;
			
			
		ELSE
		
			SET difference_count = countNo - pre_count ;
			UPDATE tr_booking_details tr SET tr.deleted = 1
			WHERE  tr.booking_id = bookingID;

			SET var_available_seats = (SELECT seats_available FROM tr_Package_availability WHERE package_id = packageID);
			SET var_waiting_list = (SELECT waiting_list FROM tr_Package_availability WHERE package_id = packageID);
			
			IF (var_available_seats >= difference_count) THEN 
				UPDATE tr_Package_availability pp 
				SET pp.seats_available = pp.seats_available - difference_count WHERE pp.package_id = packageID;
			ELSE
				IF ( var_available_seats < difference_count AND var_available_seats >0) THEN
				
					UPDATE tr_Package_availability pp 
					SET pp.waiting_list = pp.waiting_list + difference_count - var_available_seats,pp.seats_available=0  WHERE pp.package_id = packageID;
				
				ELSE
				
					UPDATE tr_Package_availability pp 
					SET pp.waiting_list = pp.waiting_list + difference_count WHERE pp.package_id = packageID;
					
				END IF;

		END IF;
			
		
		
		
		UPDATE tr_booking_details tr
		SET tr.package_id = IFNULL(packageID,tr.package_id),
			tr.update_time = now(),
			tr.name_details = IFNULL(name_Details,tr.name_details),
			tr.mode_of_journey_up = IFNULL(journeymodeUP,tr.mode_of_journey_up),
			tr.mode_of_journey_down = IFNULL(journeymodeDOWN,tr.mode_of_journey_down),
			tr.residential_address = IFNULL(residentialAddress,tr.residential_address),
			tr.current_address = IFNULL(currentAddress,tr.current_address),
			tr.contact_no = IFNULL(contactNo,tr.contact_no),
			tr.email_id = IFNULL(emailID,tr.email_id),
			tr.Pan_card = IFNULL(panCARD,tr.Pan_card),
			tr.Voter_card = IFNULL(voterCARD,tr.Voter_card),
			tr.Passport_no = IFNULL(passportNO,tr.Passport_no),
			tr.Driving_license = IFNULL(drivingLicense,tr.Driving_license),
			tr.age_break_up=IFNULL(age_break_UP,tr.age_break_up),
			tr.sbr_count=IFNULL(sbr_count,tr.sbr_count),
			tr.dbr_count=IFNULL(dbr_count,tr.dbr_count),
			tr.tbr_count=IFNULL(tbr_count,tr.tbr_count),
			tr.count_head=IFNULL(countNo,tr.count_head),
			tr.fid=IFNULL(fID,tr.fid)
			
		WHERE tr.booking_id = bookingID;
	END	;
	END IF;
END
