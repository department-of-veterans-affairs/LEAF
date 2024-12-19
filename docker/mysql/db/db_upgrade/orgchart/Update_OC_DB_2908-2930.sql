START TRANSACTION;
INSERT INTO `settings` (
`setting` ,
`data`
)
VALUES (
'salt', RAND( )
);


UPDATE `settings` SET `data` = '2930' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
