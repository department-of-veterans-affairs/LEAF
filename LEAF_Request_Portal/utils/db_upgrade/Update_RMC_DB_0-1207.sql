START TRANSACTION;
ALTER TABLE `category_dependencies` ADD UNIQUE (
`categoryID` ,
`dependencyID`
);
COMMIT;