/***********************************************************************************************************
CREATED BY : Liping Wang
CREATION DATE : 06/08/2020

DESCRIPTION:  SQL script to create a temporary tables for storing resultant output of find_errorMsg procedure             
************************************************************************************************************/

/*
USE [LEAF_Database]
GO
*/

SET ANSI_NULLS ON
GO


PRINT '**** CREATE TABLE temp_details ****'
DROP TABLE IF EXISTS `temp_details`;
CREATE TABLE `temp_details` ( 
	`t_schema` varchar(45) NOT NULL,
	`t_table` varchar(45) NOT NULL,
	`t_field` varchar(45) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

GO