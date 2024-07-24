<?php
/*
 * As a work of the United States government, this project is in the public domain within the United States.
 */

use Phinx\Seed\AbstractSeed;

/**
 * A base set of data to test against.
 */
class BaseTestSeed extends AbstractSeed
{
    public function run()
    {
        $this->execute("
            INSERT INTO `employee` 
            (`empUID`, `userName`, `lastName`, `firstName`, `middleName`, `phoneticFirstName`, `phoneticLastName`, `domain`, `deleted`, `lastUpdated`) VALUES 
            ('1', 'tester', 'tester', 'tester', 'tester', 'tester', 'tester', '', '0', '0');

            INSERT INTO `employee_data`
            (`empUID`, `indicatorID`, `data`, `author`, `timestamp`) VALUES
            (1, 2, 'GS', 'tester', 0),
            (1, 4, '10000', 'tester', 0),
            (1, 5, '123-456-7890', 'tester', 0),
            (1, 6, 'test@email.com', 'tester', 0),
            (1, 8, 'Test Room', 'tester', 0);

            INSERT INTO `group_data`
            (`groupID`, `indicatorID`, `data`, `author`, `timestamp`) VALUES
            (1, 24, '987-654-3210', 'tester', 0),
            (1, 25, 'Test City, USA', 'tester', 0);

            INSERT INTO `groups`
            (`parentID`, `groupTitle`, `groupAbbreviation`, `phoneticGroupTitle`) VALUES
            (0, 'Test Group Title 1', NULL, 'TGT1'),
            (1, 'Test Group Title 2', NULL, 'TGT2');

            INSERT INTO `positions`
            (`parentID`, `positionTitle`, `phoneticPositionTitle`, `numberFTE`) VALUES
            (0, 'Test Position Title Super', 'TPTS', 1),
            (1, 'Test Subordinate Position', 'TSP', 1);

            INSERT INTO `position_data`
            (`positionID`, `indicatorID`, `data`, `author`, `timestamp`) VALUES
            (1, 2, 'GS', 'tester', 0),
            (2, 9, '4', 'tester', 0),
            (3, 12, 'Test Classification Title', 'tester', 0),
            (4, 2, 'VN', 'tester', 0),
            (5, 9, '9', 'tester', 0),
            (6, 12, 'Test Sub Classification Title', 'tester', 0);

            INSERT INTO `relation_group_position`
            (`groupID`, `positionID`) VALUES
            (1, 1),
            (1, 2);

            INSERT INTO `relation_group_employee` 
            (`groupID`, `empUID`) VALUES 
            ('1', '1');
        ");
    }
}
