delimiter $$

CREATE DATABASE `travelo_db` /*!40100 DEFAULT CHARACTER SET latin1 */$$


delimiter $$

CREATE TABLE `tr_booking_files` (
  `booking_id` int(11) NOT NULL,
  `fid` int(11) NOT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`booking_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `tr_package` (
  `package_id` int(11) NOT NULL AUTO_INCREMENT,
  `place_id` int(2) NOT NULL,
  `package_date` date NOT NULL,
  `payer_id` int(2) NOT NULL,
  `package_seats` int(11) NOT NULL,
  `active` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`package_id`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `tr_package_accomodation` (
  `accomodation_mode` int(11) NOT NULL AUTO_INCREMENT,
  `accomodation_mode_name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`accomodation_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `tr_Package_availability` (
  `package_id` int(11) NOT NULL,
  `payer_id` int(5) NOT NULL,
  `seats_available` int(5) DEFAULT '44',
  `waiting_list` int(5) DEFAULT '0',
  `active` int(11) DEFAULT '1',
  PRIMARY KEY (`package_id`),
  KEY `tr_Package_fk1_idx` (`payer_id`),
  KEY `tr_Package_fk2_idx` (`package_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `tr_package_journey_mode` (
  `journey_mode_id` int(11) NOT NULL AUTO_INCREMENT,
  `journey_mode_name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`journey_mode_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `tr_package_place` (
  `place_id` int(2) NOT NULL AUTO_INCREMENT,
  `place_name` varchar(100) NOT NULL,
  PRIMARY KEY (`place_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `tr_payer` (
  `payer_id` int(5) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`payer_id`),
  UNIQUE KEY `payer_id_UNIQUE` (`payer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `tr_booking_details` (
  `booking_id` int(11) NOT NULL AUTO_INCREMENT,
  `package_id` int(11) NOT NULL,
  `booking_time` datetime NOT NULL,
  `update_time` datetime NOT NULL,
  `name_details` varchar(2000) DEFAULT NULL,
  `mode_of_journey_up` varchar(100) DEFAULT NULL,
  `mode_of_journey_down` varchar(100) DEFAULT NULL,
  `residential_address` varchar(400) DEFAULT NULL,
  `current_address` varchar(400) DEFAULT NULL,
  `contact_no` varchar(11) NOT NULL,
  `email_id` varchar(45) NOT NULL,
  `deleted` tinyint(4) NOT NULL DEFAULT '0',
  `Pan_card` varchar(45) DEFAULT NULL,
  `Voter_card` varchar(45) DEFAULT NULL,
  `Passport_no` varchar(45) DEFAULT NULL,
  `Driving_license` varchar(45) DEFAULT NULL,
  `count_head` int(11) DEFAULT NULL,
  `age_break_up` varchar(45) DEFAULT NULL,
  `sbr_count` int(11) DEFAULT NULL,
  `dbr_count` int(11) DEFAULT NULL,
  `tbr_count` int(11) DEFAULT NULL,
  `fid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`booking_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1$$


