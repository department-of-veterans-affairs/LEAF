START TRANSACTION;

ALTER TABLE `group_tags` CHANGE `tag` `tag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL;
ALTER TABLE `position_tags` CHANGE `tag` `tag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL;
ALTER TABLE `tag_hierarchy` CHANGE `tag` `tag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL;
ALTER TABLE `tag_hierarchy` CHANGE `parentTag` `parentTag` VARCHAR(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL;

UPDATE `settings` SET `data` = '5204' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
