START TRANSACTION;

UPDATE `indicators`
SET `format` = 'dropdown\r\n\r\nGS\r\nWG\r\nVM\r\nVN\r\nNS\r\nNA\r\nAD\r\nWS\r\nWL\r\nVP\r\nVC\r\nES\r\nFEE\r\nLVN\r\nRN\r\nL\r\nU\r\nQ\r\nK\r\nV1\r\nM\r\nT1'
WHERE `indicatorID` = 2;

UPDATE `settings` SET `data` = '2025021600' WHERE `settings`.`setting` = 'dbversion';

COMMIT;


/**** Revert DB *****
START TRANSACTION;

UPDATE `indicators`
SET `format` = 'dropdown\r\n\r\nGS\r\nWG\r\nVM\r\nVN\r\nNS\r\nNA\r\nAD\r\nWS\r\nWL\r\nVP\r\nVC\r\nES\r\nFEE\r\nLVN\r\nRN\r\nL\r\nU\r\nQ\r\nK\r\nV1'
WHERE `indicatorID` = 2;

UPDATE `settings` SET `data` = '2024092100' WHERE `settings`.`setting` = 'dbversion';

COMMIT;
*/