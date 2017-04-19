<?php
/************************
    Orgchart
    Date: September 1, 2011
    
*/

namespace Orgchart;

class Orgchart
{
    private $db;
    private $login;

    public $employee;
    public $position;
    public $group;

    function __construct($db, $login)
    {
        $this->db = $db;
        $this->login = $login;

        $this->employee = new Orgchart\Employee($db, $login);
        $this->position = new Orgchart\Position($db, $login);
        $this->group = new Orgchart\Group($db, $login);
    }

	public function getEmployeeDossierByLogin($userID)
	{
		
	}
}
