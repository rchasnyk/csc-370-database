CREATE DATABASE IF NOT EXISTS `Inventory`;

USE `Inventory`;

CREATE TABLE IF NOT EXISTS `Owners`(
    `id` INT, 
    `name` VARCHAR(120),
    PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `Locations`(
    `name` VARCHAR(120),
    PRIMARY KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `Items`(
    `id` INT,
    `name` VARCHAR(120),
    `IsAvailable` BOOLEAN DEFAULT TRUE,
    `History` TEXT DEFAULT NULL,
    `owner_id` INT DEFAULT NULL,
    `location` VARCHAR(120) DEFAULT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`owner_id`) REFERENCES `Owner`(`id`),
    FOREIGN KEY (`location`) REFERENCES `Location`(`name`)
);
