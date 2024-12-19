START TRANSACTION;

UPDATE `indicators` SET `format` = 'dropdown\r\n\r\nGS\r\nWG\r\nVM\r\nVN\r\nNS\r\nNA\r\nAD\r\nWS\r\nWL\r\nVP\r\nVC\r\nES\r\nFEE\r\nLVN\r\nRN\r\nL\r\nU' WHERE `indicators`.`indicatorID` = 2;

UPDATE `settings` SET `data` = '5140' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
