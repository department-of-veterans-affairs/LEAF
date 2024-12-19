START TRANSACTION;

INSERT INTO dependencies (dependencyID, description) VALUES (5, "Request Submitted") ON DUPLICATE KEY UPDATE description="Request Submitted";

UPDATE `settings` SET `data` = '4951' WHERE `settings`.`setting` = 'dbversion';
COMMIT;
