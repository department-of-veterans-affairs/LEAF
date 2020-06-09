
/**************************************************************************************
CREATED BY : Liping Wang
CREATION DATE : 06/08/2020
DESCRIPTION: Stored procedure to search Database Errors from a specific column on a specific table, to store the result to a temporary tables, temp_dtails.
It accepts searching string as parameters to find errors on the column in entire database.
**************************************************************************************/

/*
USE [LEAF_Database]
GO
*/

/**** CREATE TABLE temp_details ****/
/**** a temporary tables for storing resultant output of find_errorMsg procedure ****/
DROP TABLE IF EXISTS `temp_details`;
CREATE TABLE `temp_details` (
	`t_schema` varchar(45) NOT NULL,
	`t_table` varchar(45) NOT NULL,
	`t_field` varchar(45) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
GO

/********* Create procedure for searching error string ****************/
CREATE PROCEDURE `find_errorMsg`(in_search varchar(100))
    READS SQL DATA
BEGIN
	DECLARE trunc_cmd VARCHAR(50);
	DECLARE search_string VARCHAR(250);
	DECLARE db,tbl,clmn CHAR(50);
	DECLARE done INT DEFAULT 0;
	DECLARE COUNTER INT;
	DECLARE table_cur CURSOR FOR
	SELECT concat('SELECT COUNT(*) INTO @CNT_VALUE
		FROM `',table_schema,'`.`',table_name,'`
		WHERE `', column_name,'` REGEXP "',in_search,'"') ,table_schema,table_name,column_name
	FROM information_schema.COLUMNS
	WHERE TABLE_SCHEMA NOT IN ('information_schema','test','mysql')
	AND TABLE_SCHEMA NOT LIKE ('%orgchart%');

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;

	#Truncating table for refill the data for new search.
	PREPARE trunc_cmd FROM "TRUNCATE TABLE temp_details;";
	EXECUTE trunc_cmd ;
	OPEN table_cur;
	table_loop:LOOP
		FETCH table_cur INTO search_string,db,tbl,clmn;
		#Executing the search
		SET @search_string = search_string;
		##SELECT  search_string;
		PREPARE search_string FROM @search_string;
		EXECUTE search_string;
		SET COUNTER = @CNT_VALUE;
		##SELECT COUNTER;
		IF COUNTER>0 THEN
		# Inserting required results from search to table
		INSERT INTO temp_details VALUES(db,tbl,clmn);
		END IF;
		IF done=1 THEN
		LEAVE table_loop;
		END IF;
	END LOOP;
	CLOSE table_cur;
	#Finally Show Results
	SELECT * FROM temp_details;
END
