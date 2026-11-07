CREATE DATABASE IF NOT EXISTS `Inventory`;

USE `Inventory`;

CREATE TABLE IF NOT EXISTS `AccessLevel`(
    `ID` INT NOT NULL, 
    `Name` VARCHAR(120) NOT NULL,
    `Rank` INT NOT NULL,
    PRIMARY KEY (`ID`),

    CONSTRAINT CheckAccessRank
    CHECK (`Rank` >= 1)
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
    `Supplier` VARCHAR(120) DEFAULT NULL,
    `Owner_id` INT DEFAULT NULL,
    `Room_number` INT DEFAULT NULL,
    `Building_ID` INT DEFAULT NULL, 
    `RequiredAccessLevel` INT NOT NULL DEFAULT 1,
    `Item_Value` DECIMAL(10,2) DEFAULT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`Owner_id`) REFERENCES `Owners`(`ID`),
    FOREIGN KEY (`Room_number`, `Building_ID`) REFERENCES `Room`(`Number`, `Building_ID`),
    FOREIGN KEY (`RequiredAccessLevel`) REFERENCES `AccessLevel`(`ID`),

    CONSTRAINT CheckItemValue
    CHECK (`Item_Value` >= 0)
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
    FOREIGN KEY (`Room_number`, `Building_ID`) REFERENCES `Room`(`Number`, `Building_ID`),

    CONSTRAINT CheckHistoryDates
        CHECK (
            `DateSignedIn` IS NULL
            OR `DateSignedOut` IS NULL
            OR `DateSignedIn` >= `DateSignedOut`
        )
);

# Triggers

DELIMITER $
# Trigger: Check if owner has requried access level.
# Insert if yes, do nothing if no.
CREATE TRIGGER IF NOT EXISTS CheckItemAccess
BEFORE INSERT ON Items
FOR EACH ROW
BEGIN
    IF NEW.Owner_id IS NOT NULL AND (
        SELECT COALESCE(MAX(a.`Rank`), 0)
        FROM OwnerGroups og
        JOIN `Group` g ON og.Group_ID = g.ID
        JOIN AccessLevel a ON g.AccessLevel_ID = a.ID
        WHERE og.Owner_ID = NEW.Owner_id
    ) 
    < 
    (
        SELECT `Rank`
        FROM AccessLevel
        WHERE ID = NEW.RequiredAccessLevel
    )
    THEN 
        SIGNAL SQLSTATE '45000'; # reject insertion
    END IF;
END$

# Trigger: Update ItemHistory when owner or location is changed

CREATE TRIGGER IF NOT EXISTS RecordItemHistory
AFTER UPDATE ON Items
FOR EACH ROW
BEGIN
    DECLARE new_entry INT;

    IF NOT (OLD.Owner_id <=> NEW.Owner_id)
       OR NOT (OLD.Room_number <=> NEW.Room_number)
       OR NOT (OLD.Building_ID <=> NEW.Building_ID)
    THEN
        SELECT COALESCE(MAX(EntryID), 0) + 1
        INTO new_entry
        FROM ItemHistory
        WHERE Item_id = OLD.ID;

        INSERT INTO ItemHistory (
            EntryID,
            Item_id,
            EntryDate,
            Owner_id,
            Room_number,
            Building_ID,
            Notes
        )
        VALUES (
            new_entry,
            OLD.ID,
            CURRENT_DATE(),
            OLD.Owner_id,
            OLD.Room_number,
            OLD.Building_ID,
            'Owner/location changed'
        );
    END IF;
END$

DELIMITER ;
