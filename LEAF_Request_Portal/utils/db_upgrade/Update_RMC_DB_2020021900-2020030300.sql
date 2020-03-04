START TRANSACTION;

-- new_empUUID column added to all tables using userID
ALTER TABLE `action_history` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `approvals` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `data` ADD COLUMN new_empUUID VARCHAR(36) NULL;
-- ALTER TABLE `data_action_log` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `data_extended` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `data_history` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `notes` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `records` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `service_chiefs` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `signatures` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `tags` ADD COLUMN new_empUUID VARCHAR(36) NULL;
ALTER TABLE `users` ADD COLUMN new_empUUID VARCHAR(36) NULL;

UPDATE 
  `action_history` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `action_history`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `approvals` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `approvals`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `data` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `data`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

-- UPDATE 
--   `data_action_log` as portaltable,
--   national_orgchart.employee nat_emp
-- SET 
--   portaltable.new_empUUID = nat_emp.new_empUUID
-- WHERE 
--   portaltable.userID = nat_emp.userName;

-- UPDATE 
--   `data_action_log`
-- SET 
--   new_empUUID = CONCAT('not_in_national_', userID)
-- WHERE 
--   new_empUUID IS NULL
--   AND DATABASE() != 'national_orgchart';

UPDATE 
  `data_extended` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `data_extended`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `data_history` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `data_history`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `notes` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `notes`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `records` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `records`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `service_chiefs` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `service_chiefs`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `signatures` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `signatures`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `tags` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `tags`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE 
  `users` as portaltable,
  national_orgchart.employee nat_emp
SET 
  portaltable.new_empUUID = nat_emp.new_empUUID
WHERE 
  portaltable.userID = nat_emp.userName;

UPDATE 
  `users`
SET 
  new_empUUID = CONCAT('not_in_national_', userID)
WHERE 
  new_empUUID IS NULL
  AND DATABASE() != 'national_orgchart';

UPDATE `settings` SET `data` = '2020030300' WHERE `settings`.`setting` = 'dbversion';

COMMIT;