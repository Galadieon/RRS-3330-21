DROP DATABASE IF EXISTS RRS;
CREATE DATABASE RRS; -- Railway Reservation System

USE RRS;

CREATE TABLE Train (
    TrainNumber INT PRIMARY KEY,
    TrainName VARCHAR(100) UNIQUE,
    PremiumFair DECIMAL(10,2),
    GeneralFair DECIMAL(10,2),
    SourceStation VARCHAR(100),
    DestinationStation VARCHAR(100),
    AvailabilityOnWeekdays VARCHAR(100)
);

CREATE TABLE TrainStatus (
    TrainDate VARCHAR(50),
    TrainName VARCHAR(50),
    PremiumSeatsAvailable INT,
    GenSeatsAvailable INT,
    PremiumSeatsOccupied INT,
    GenSeatsOccupied INT,
    PRIMARY KEY(TrainDate, TrainName),
    FOREIGN KEY(TrainName) REFERENCES Train(TrainName)
);

CREATE TABLE Passenger (
    SSN INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Address VARCHAR(255),
    City VARCHAR(100),
    County VARCHAR(100),
    Phone VARCHAR(15),
    Bdate DATE
);

CREATE TABLE Booking (
    SSN INT,
    TrainNumber INT,
    TicketType VARCHAR(15),
    Status VARCHAR(15),
    PRIMARY KEY(SSN, TrainNumber),
    FOREIGN KEY(SSN) REFERENCES Passenger(SSN),
    FOREIGN KEY(TrainNumber) REFERENCES Train(TrainNumber)
);

LOAD DATA INFILE '/var/lib/mysql-files/RRS/Train.csv'
INTO TABLE Train 
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/var/lib/mysql-files/RRS/Train_status.csv'
INTO TABLE TrainStatus 
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/var/lib/mysql-files/RRS/Passenger-1.csv'
INTO TABLE Passenger 
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/var/lib/mysql-files/RRS/booked-1.csv'
INTO TABLE Booking 
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- SELECT * FROM Train;
-- DESCRIBE Train;
-- SELECT * FROM TrainStatus;
-- DESCRIBE TrainStatus;
-- SELECT * FROM Passenger;
-- DESCRIBE Passenger;
-- SELECT * FROM Booking;
-- DESCRIBE Booking;

-- 1. ER Diagram stuff
-- 2. Given a passenger's last name and first name and retrieve all trains they are booked on.
SELECT Train.TrainName
FROM Booking, Passenger, Train
WHERE Booking.SSN = Passenger.SSN
AND Train.TrainNumber = Booking.TrainNumber
AND Passenger.FirstName = 'Josephine'
AND Passenger.LastName = 'Darakjy';

-- 3. Given a day, list the passengers traveling on that day with confirmed tickets. 
SELECT TrainStatus.TrainDate, Train.TrainName, Train.TrainNumber, Passenger.FirstName, Passenger.LastName, Booking.Status
FROM TrainStatus, Booking, Passenger, Train
WHERE TrainStatus.TrainDate = 'Sunday'
AND Booking.SSN = Passenger.SSN
AND Train.TrainName = TrainStatus.TrainName
AND Booking.TrainNumber = Train.TrainNumber
AND Booking.Status = 'Booked';

-- 4. Display the train information (Train Number, Train Name, Source and Destination) and passenger information (Name, Address, Category, ticket status) of passengers who are between the ages of 50 to 60. 
SELECT Tr.TrainNumber, Tr.TrainName, Tr.SourceStation, Tr.DestinationStation, 
Pa.FirstName, Pa.LastName, Pa.Address, Pa.City, Pa.County, Pa.Bdate,
Bk.TicketType, Bk.Status
FROM Train Tr, Passenger Pa, Booking Bk
WHERE Pa.SSN = Bk.SSN
AND Bk.TrainNumber = Tr.TrainNumber
AND TIMESTAMPDIFF(YEAR, Pa.Bdate, CURDATE()) BETWEEN 50 AND 60;

-- 5. List train name, day and number of passenger on that train. 
SELECT Tr.TrainName, TrSt.TrainDate, 
    (SELECT COUNT(*) 
     FROM Booking Bk 
     WHERE Bk.TrainNumber = Tr.TrainNumber
     AND Bk.Status = 'Booked') AS PassengerCount
FROM Train Tr, TrainStatus TrSt
WHERE Tr.TrainName = TrSt.TrainName;

-- 6. Enter a train name and retrieve all the passengers with confirmed status traveling on that train.
SELECT Bk.Status, Tr.TrainName,
Pa.SSN, Pa.FirstName, Pa.LastName
FROM Train Tr, Passenger Pa, Booking Bk
WHERE Pa.SSN = Bk.SSN
AND Tr.TrainNumber = Bk.TrainNumber
AND Tr.TrainName = 'Flying Scotsman'
AND Bk.Status = 'Booked';

-- 7. List passengers that are waitlisted including the name of the train.
SELECT Bk.Status, Tr.TrainName,
Pa.SSN, Pa.FirstName, Pa.LastName
FROM Train Tr, Passenger Pa, Booking Bk
WHERE Pa.SSN = Bk.SSN
AND Tr.TrainNumber = Bk.TrainNumber
AND Bk.Status = 'WaitL';

-- 8. List passenger names in descending order that have '605' phone area code.
SELECT Pa.LastName, Pa.FirstName
FROM Passenger Pa 
WHERE Pa.Phone LIKE '605%' 
ORDER BY Pa.LastName DESC; 

-- 9. List name of passengers that are traveling on Thursdays in ascending order.

-- This prints out an empty set if thursday since train status has no thursday trains

SELECT TrSt.TrainDate, Pa.FirstName, Pa.LastName
FROM Passenger Pa, TrainStatus TrSt, Booking Bk, Train Tr
WHERE Pa.SSN = Bk.SSN
AND Tr.TrainName = TrSt.TrainName
AND Bk.TrainNumber = Tr.TrainNumber
AND TrSt.TrainDate = 'Thursday'
ORDER BY Pa.LastName ASC;