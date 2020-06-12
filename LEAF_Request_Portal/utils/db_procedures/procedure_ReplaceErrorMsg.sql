/**************************************************************************************
CREATED BY : Liping Wang
CREATION DATE : 06/08/2020
DESCRIPTION: Stored procedure to search Database Errors from a specific column on a specific table, to replace the DB Errors with a emply string.
It accepts 'find' string and 'replce' as parameters to replace 'find' by 'replce' on the column in entire database.
**************************************************************************************/*/

/*
USE [LEAF_Database]
GO
*/

/********* Create procedure for replacing error string ****************/
CREATE PROCEDURE `ReplaceErrorMsg`(find varchar(255), 
        replce varchar(255))
BEGIN
	DECLARE loopdone INTEGER DEFAULT 0;
	DECLARE currtable varchar(100);
	DECLARE currcol varchar(100);
	DECLARE alltables CURSOR FOR 
	SELECT 
		t.table_name, 
		c.column_name 
	FROM 
		information_schema.tables t,
		information_schema.columns c
    WHERE t.table_schema=DATABASE()
    AND c.table_schema=DATABASE()
    AND t.table_name=c.table_name;

	DECLARE CONTINUE HANDLER FOR NOT FOUND
	SET loopdone = 1;

	SET SQL_SAFE_UPDATES = 0;
    
 	OPEN alltables;

 	tableloop: LOOP
    	FETCH alltables INTO currtable, currcol; 
    	IF (loopdone>0) THEN LEAVE tableloop;
    	END IF;
    
    	SET @stmt = 'UPDATE `|table|` SET `|column|` = REPLACE(`|column|`, "|find|", "|replace|") WHERE `|column|` LIKE "%|find|%"';
		SET @stmt = REPLACE(@stmt, '|table|', currtable);
		SET @stmt = REPLACE(@stmt, '|column|', currcol);
		SET @stmt = REPLACE(@stmt, '|find|', find);
		SET @stmt = REPLACE(@stmt, '|replace|', replce);
  
		
    	PREPARE s1 FROM @stmt;
    	EXECUTE s1;
    	DEALLOCATE PREPARE s1;
    END LOOP;
 END