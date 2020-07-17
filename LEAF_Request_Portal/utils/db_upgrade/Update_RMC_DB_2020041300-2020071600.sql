ALTER TABLE `users` 
ADD COLUMN `locallyManaged` TINYINT(1) NULL DEFAULT 0 AFTER `primary_admin`,
ADD COLUMN `active` TINYINT(4) NOT NULL DEFAULT 1 AFTER `locallyManaged`;
