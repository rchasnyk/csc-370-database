CREATE DATABASE IF NOT EXISTS `Inventory`;

USE `Inventory`;

CREATE TABLE IF NOT EXISTS `Owner`(
    `id` INT, 
    `name` VARCHAR(120),
    PRIMARY KEY (`id`),
);

CREATE TABLE IF NOT EXISTS `Location`(
    `name` VARCHAR(120),
    PRIMARY KEY (`name`),
);

CREATE TABLE IF NOT EXISTS `Items`(
    `id` INT,
    `name` VARCHAR(120), 
    `IsAvailable` BOOLEAN,
    `History` TEXT,
    `owner_id` INT,
    `location` VARCHAR(120),
    PRIMARY KEY (`id`),
    FOREIGN KEY (`owner_id`) REFERENCES `Owner`(`id`),
    FOREIGN KEY (`location`) REFERENCES `Location`(`name`)
);
