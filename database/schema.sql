CREATE DATABASE IF NOT EXISTS `Inventory`;

USE `Inventory`;

CREATE TABLE IF NOT EXISTS `AccessLevel`(
    `ID` INT NOT NULL, 
    `Name` VARCHAR(120) NOT NULL,
    `Rank` INT NOT NULL,
    PRIMARY KEY (`ID`),
    UNIQUE (`Rank`),

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
    FOREIGN KEY (`Owner_ID`) REFERENCES `Owners`(`ID`),
    FOREIGN KEY (`Room_number`, `Building_ID`) REFERENCES `Room`(`Number`, `Building_ID`),
    FOREIGN KEY (`RequiredAccessLevel`) REFERENCES `AccessLevel`(`ID`),

    CONSTRAINT CheckItemValue
    CHECK (`Item_Value` >= 0),

    CONSTRAINT CheckItemRoomBuilding
    CHECK (
        (`Room_number` IS NULL AND `Building_ID` IS NULL)
        OR (`Room_number` IS NOT NULL AND `Building_ID` IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS `ItemHistory`(
    `EntryID` INT NOT NULL,
    `Item_ID` INT NOT NULL,
    `EntryDate` DATE NOT NULL,
    `Owner_ID` INT DEFAULT NULL,
    `Room_number` INT DEFAULT NULL,
    `Building_ID` INT DEFAULT NULL,
    `DateSignedIn` DATE DEFAULT NULL,
    `DateSignedOut` DATE DEFAULT NULL,
    `Notes` TEXT DEFAULT NULL,
    PRIMARY KEY (`Item_ID`, `EntryID`),
    FOREIGN KEY (`Item_ID`) REFERENCES `Items`(`ID`),
    FOREIGN KEY (`Owner_ID`) REFERENCES `Owners`(`ID`),
    FOREIGN KEY (`Room_number`, `Building_ID`) REFERENCES `Room`(`Number`, `Building_ID`),

    CONSTRAINT CheckHistoryDates
        CHECK (
            `DateSignedOut` IS NULL
            OR (
                `DateSignedIn` IS NOT NULL
                AND `DateSignedOut` >= `DateSignedIn` #swapped signedin and signedout so someone cant sign out an item until its been signed in
            ) 
        ),

    CONSTRAINT CheckHistoryRoomBuilding
    CHECK (
        (`Room_number` IS NULL AND `Building_ID` IS NULL)
        OR (`Room_number` IS NOT NULL AND `Building_ID` IS NOT NULL)
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
    IF NEW.Owner_ID IS NOT NULL AND (
        SELECT COALESCE(MAX(a.`Rank`), 0)
        FROM OwnerGroups og
        JOIN `Group` g ON og.Group_ID = g.ID
        JOIN AccessLevel a ON g.AccessLevel_ID = a.ID
        WHERE og.Owner_ID = NEW.Owner_ID
    ) 
    < 
    (
        SELECT `Rank`
        FROM AccessLevel
        WHERE ID = NEW.RequiredAccessLevel
    )
    THEN 
        SIGNAL SQLSTATE '45000' # reject insertion
            SET MESSAGE_TEXT = 'Owner does not have required access level for this item.';
    END IF;
END$

# Trigger: Check if owner has required access level on update.
CREATE TRIGGER IF NOT EXISTS CheckItemAccessUpdate
BEFORE UPDATE ON Items
FOR EACH ROW
BEGIN
    IF NEW.Owner_ID IS NOT NULL AND (
        SELECT COALESCE(MAX(a.`Rank`), 0)
        FROM OwnerGroups og
        JOIN `Group` g ON og.Group_ID = g.ID
        JOIN AccessLevel a ON g.AccessLevel_ID = a.ID
        WHERE og.Owner_ID = NEW.Owner_ID
    )
    <
    (
        SELECT `Rank`
        FROM AccessLevel
        WHERE ID = NEW.RequiredAccessLevel
    )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Owner does not have required access level for this item.';
    END IF;
END$

# Trigger: Update ItemHistory when owner or location is changed

CREATE TRIGGER IF NOT EXISTS RecordItemHistory
AFTER UPDATE ON Items
FOR EACH ROW
BEGIN
    DECLARE new_entry INT;

    IF NOT (OLD.Owner_ID <=> NEW.Owner_ID)
       OR NOT (OLD.Room_number <=> NEW.Room_number)
       OR NOT (OLD.Building_ID <=> NEW.Building_ID)
    THEN
        SELECT COALESCE(MAX(EntryID), 0) + 1
        INTO new_entry
        FROM ItemHistory
        WHERE Item_ID = OLD.ID;

        INSERT INTO ItemHistory (
            EntryID,
            Item_ID,
            EntryDate,
            Owner_ID,
            Room_number,
            Building_ID,
            Notes
        )
        VALUES (
            new_entry,
            OLD.ID,
            CURRENT_DATE(),
            OLD.Owner_ID,
            OLD.Room_number,
            OLD.Building_ID,
            'Owner/location changed'
        );
    END IF;
END$

# Trigger: Check if changing group access level would remove an Owners required access level for any items they own.
CREATE TRIGGER IF NOT EXISTS CheckGroupAccessLevelChange
BEFORE UPDATE ON `Group`
FOR EACH ROW
BEGIN
    IF EXISTS (
            SELECT 1
            FROM OwnerGroups og
            JOIN Items i ON og.Owner_ID = i.Owner_ID
            WHERE og.Group_ID = OLD.ID
            AND (
                SELECT COALESCE(MAX(a.`Rank`), 0)
                FROM OwnerGroups og2
                JOIN `Group` g ON og2.Group_ID = g.ID
                JOIN AccessLevel a ON 
                    a.ID = CASE
                        WHEN og2.Group_ID = OLD.ID THEN NEW.AccessLevel_ID
                        ELSE g.AccessLevel_ID
                    END
                WHERE og2.Owner_ID = og.Owner_ID
            )
            < 
            (
                SELECT `Rank`
                FROM AccessLevel
                WHERE ID = i.RequiredAccessLevel
            )
    )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Changing this group''s access level would remove an owner''s required access level for an item they own.';
    END IF;
END$

DELIMITER ;
