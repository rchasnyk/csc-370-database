CREATE DATABASE IF NOT EXISTS `Inventory`;

USE `Inventory`;

CREATE TABLE IF NOT EXISTS `AccessLevel`(
    `ID` INT NOT NULL, 
    `Name` VARCHAR(120) NOT NULL,
    `Rank` INT NOT NULL,
    PRIMARY KEY (`ID`)
);

CREATE TABLE IF NOT EXISTS `Group`(
    `ID` INT NOT NULL, 
    `Name` VARCHAR(120) NOT NULL,
    `Type` VARCHAR(120) NOT NULL,
    `AccessLevel_ID` INT NOT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`AccessLevel_ID`) REFERENCES `AccessLevel`(`ID`)
);

CREATE TABLE IF NOT EXISTS `Owners`(
    `ID` INT NOT NULL, 
    `Name` VARCHAR(120) NOT NULL,
    PRIMARY KEY (`ID`)
);

CREATE TABLE IF NOT EXISTS `Employee`(
    `ID` INT NOT NULL, 
    PRIMARY KEY (`ID`),
     FOREIGN KEY (`ID`) REFERENCES `Owners`(`ID`)
);

CREATE TABLE IF NOT EXISTS `Student`(
    `ID` INT NOT NULL, 
    PRIMARY KEY (`ID`),
     FOREIGN KEY (`ID`) REFERENCES `Owners`(`ID`)
);

CREATE TABLE IF NOT EXISTS `OwnerGroups`(
    `Owner_ID` INT NOT NULL,
    `Group_ID` INT NOT NULL,
    PRIMARY KEY (`Owner_ID`,`Group_ID`),
    FOREIGN KEY (`Owner_ID`) REFERENCES `Owners`(`ID`),
    FOREIGN KEY (`Group_ID`) REFERENCES `Group`(`ID`)
);

CREATE TABLE IF NOT EXISTS `Buildings`(
    `Name` VARCHAR(120) NOT NULL,
    `ID` INT NOT NULL,
    PRIMARY KEY (`ID`)
);

CREATE TABLE IF NOT EXISTS `Room`(
    `Building_ID` INT NOT NULL,
    `Number` INT NOT NULL,
    PRIMARY KEY (`Number`,`Building_ID`),
    FOREIGN KEY (`Building_ID`) REFERENCES `Buildings`(`ID`)
);

CREATE TABLE IF NOT EXISTS `Items`(
    `ID` INT NOT NULL ,
    `Name` VARCHAR(120) NOT NULL,
    `IsAvailable` BOOLEAN NOT NULL DEFAULT TRUE,
    `DateAcquired` DATE DEFAULT NULL,
    `Owner_id` INT DEFAULT NULL,
    `Room_number` INT DEFAULT NULL,
    `Building_ID` INT DEFAULT NULL, 
    `RequiredAccessLevel` INT DEFAULT NULL,
    `Item_Value` DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`Owner_id`) REFERENCES `Owners`(`ID`),
    FOREIGN KEY (`Room_number`, `Building_ID`) REFERENCES `Room`(`Number`, `Building_ID`),
    FOREIGN KEY (`RequiredAccessLevel`) REFERENCES `AccessLevel`(`ID`)
);

CREATE TABLE IF NOT EXISTS `ItemHistory`(
    `EntryID` INT NOT NULL,
    `Item_id` INT NOT NULL,
    `EntryDate` DATE DEFAULT NULL,
    `Owner_id` INT DEFAULT NULL,
    `Room_number` INT DEFAULT NULL,
    `Building_ID` INT DEFAULT NULL,
    `DateSignedIn` DATE DEFAULT NULL,
    `DateSignedOut` DATE DEFAULT NULL,
    `Notes` TEXT DEFAULT NULL,
    PRIMARY KEY (`Item_id`, `EntryID`),
    FOREIGN KEY (`Item_id`) REFERENCES `Items`(`ID`),
    FOREIGN KEY (`Owner_id`) REFERENCES `Owners`(`ID`),
    FOREIGN KEY (`Room_number`, `Building_ID`) REFERENCES `Room`(`Number`, `Building_ID`)
);

