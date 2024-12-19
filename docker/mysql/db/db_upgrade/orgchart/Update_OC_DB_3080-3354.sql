START TRANSACTION;

INSERT INTO `indicators` (
`indicatorID` ,
`name` ,
`format` ,
`description` ,
`default` ,
`parentID` ,
`categoryID` ,
`html` ,
`jsSort` ,
`required` ,
`sort` ,
`timeAdded` ,
`encrypted` ,
`disabled`
)
VALUES (
NULL , 'Recruitment Documents', 'fileupload', NULL , NULL , NULL , 'position', NULL , NULL , '1', '11',
CURRENT_TIMESTAMP , '0', '0'
);

UPDATE `settings` SET `data` = '3354' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
