USE `Inventory`;

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
