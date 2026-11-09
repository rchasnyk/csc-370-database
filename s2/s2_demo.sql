USE `Inventory`;

# Show item availability

SELECT ID, Name, IsAvailable
FROM Items;

# Show items and their value in building

SELECT ID, Name, Item_Value
FROM Items
WHERE Building_ID = 1;

SELECT ID, Name, Item_Value
FROM Items
WHERE Building_ID = 3;

# Show items and their value in room

SELECT ID, Name, Item_Value
FROM Items
WHERE Building_ID = 1
  AND Room_number = 116;

# Show allowed access groups and their access level for an item

SELECT
    i.Name AS Item,
    g.Name AS AllowedGroup,
    a.Name AS GroupAccessLevel
FROM Items i
JOIN AccessLevel required
    ON i.RequiredAccessLevel = required.ID
JOIN AccessLevel a
    ON a.`Rank` >= required.`Rank`
JOIN `Group` g
    ON g.AccessLevel_ID = a.ID
WHERE i.ID = 3; #2,3

# Show owners and their group names

SELECT
    o.ID AS OwnerID,
    o.Name AS Owner,
    g.Name AS GroupName,
    g.Type AS GroupType
FROM Owners o
JOIN OwnerGroups og
    ON o.ID = og.Owner_ID
JOIN `Group` g
    ON og.Group_ID = g.ID;


# Show all item history entries

SELECT
    o.Name AS OwnerName,
    b.Name AS BuildingName,
    i.Name AS ItemName,
    h.EntryID,
    h.EntryDate,
    h.Item_id,
    h.Room_number AS Room,
    h.DateSignedOut,
    h.DateSignedIn,
    h.Notes
FROM ItemHistory h
JOIN Items i ON h.Item_id = i.ID
JOIN Owners o ON h.Owner_id = o.ID
JOIN Buildings b ON h.Building_ID = b.ID
ORDER BY Item_id, EntryID;

# Trigger/constraint tests

# INSERT Insufficient access level

INSERT INTO Items (ID, Name, Owner_ID, RequiredAccessLevel)
VALUES (5, 'Server Rack', 1, 3);

# INSERT Sufficient access level

INSERT INTO Items (ID, Name, Owner_ID, RequiredAccessLevel)
VALUES (5, 'Server Rack', 3, 3);

# UPDATE Insufficient access level
# Alice has access level 1, Printer requires access level 2

UPDATE Items
SET Owner_ID = 1
WHERE ID = 2;

# UPDATE Sufficient access level
# Josh has access level 4, Printer requires access level 2

UPDATE Items
SET Owner_ID = 4
WHERE ID = 2;

# UPDATE new item history entry

UPDATE Items
SET Room_number = 250
WHERE ID = 1;

UPDATE Items
SET Owner_ID = 2
WHERE ID = 1;

# Show item history

SELECT *
FROM ItemHistory
WHERE Item_ID = 1
ORDER BY EntryID;

# UPDATE check group access level change
# Josh has Printer with access level 2

UPDATE `Group`
SET AccessLevel_ID = 1
WHERE ID = 2;

# INSERT update item availability


INSERT INTO ItemHistory
(EntryID, Item_ID, EntryDate, DateSignedOut, Notes)
VALUES
(6, 2, CURRENT_DATE(), CURRENT_DATE(), 'Printer checked out');

# item not available after signed out

SELECT ID, Name, IsAvailable
FROM Items
WHERE ID = 2;

# UPDATE update item availability

UPDATE ItemHistory
SET DateSignedIn = CURRENT_DATE()
WHERE Item_ID = 2 AND EntryID = 6;

# item available after signed in

SELECT ID, Name, IsAvailable
FROM Items
WHERE ID = 2;
