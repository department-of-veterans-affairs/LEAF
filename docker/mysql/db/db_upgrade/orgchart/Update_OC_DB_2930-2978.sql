START TRANSACTION;

ALTER TABLE `relation_group_employee` ADD UNIQUE (
`groupID` ,
`empUID`
);
ALTER TABLE `relation_group_position` ADD UNIQUE (
`groupID` ,
`positionID`
);
ALTER TABLE `relation_position_employee` ADD UNIQUE (
`positionID` ,
`empUID`
);

UPDATE `settings` SET `data` = '2978' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
