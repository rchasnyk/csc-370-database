USE Inventory;

INSERT INTO AccessLevel (ID, Name, `Rank`) VALUES
(1, 'Level1', 1),
(2, 'Level2', 2),
(3, 'Level3', 3);

INSERT INTO Owners (ID, Name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Grug'),
(4, 'Josh');

INSERT INTO Student (ID) VALUES
(1), (2), (3);

INSERT INTO Employee (ID) VALUES
(4);

INSERT INTO Buildings (ID, Name) VALUES
(1, 'ECS'),
(2, 'Clearihue'),
(3, 'Library');

INSERT INTO Room (Building_ID, Number) VALUES
(1, 116),
(1, 250),
(2, 116),
(2, 250),
(2, 302),
(3, 152),
(3, 156);

INSERT INTO `Group` (ID, Name, Type, AccessLevel_ID) VALUES
(1, 'Students', 'Students', 1),
(2, 'Staff', 'TeachingStaff', 2),
(3, 'Admin', 'Management', 3);

INSERT INTO OwnerGroups (Owner_ID, Group_ID) VALUES
(1, 1), # Alice to Students
(2, 1), # Bob to Students
(4, 2), # Josh to Students
(4, 1); # Josh also to Staff

INSERT INTO Items
(
    ID, Name, IsAvailable,
    DateAcquired, Supplier,
    Owner_id, Room_number, Building_ID,
    RequiredAccessLevel, Item_Value
)
VALUES
(1, 'Laptop', TRUE,
 '2026-01-01', 'Apple',
 1, 116, 1, 1, 800),

(2, 'Printer', TRUE,
 '2020-06-01', 'HP',
 2, 250, 1, 2, 1000),

(3, 'Microscope', TRUE,
 '2024-01-01', NULL,
 3, 152, 3, 3, 2000),

(4, 'Projector', TRUE,
 '2025-01-01', NULL,
 4, 116, 1, 1, 1000);

INSERT INTO ItemHistory
(
    EntryID,
    Item_id,
    EntryDate,
    Owner_id,
    Room_number,
    Building_ID,
    DateSignedIn,
    DateSignedOut,
    Notes
)
VALUES
(1, 1, '2026-02-05', 2, 116, 1,
 '2026-02-05', '2026-02-01',
 'Laptop signed out by Bob from ECS Room 116'),

(2, 1, '2026-03-15', 3, 250, 1,
 '2026-03-15', '2026-03-10',
 'Laptop signed out by Grug from ECS Room 250'),

(3, 1, '2026-10-15', 1, 116, 1,
 NULL, '2026-10-15',
 'Laptop signed out by Alice'),

(1, 2, '2026-09-15', 4, 250, 1,
 '2026-09-15', '2026-09-11',
 'Printer signed out by Josh');

