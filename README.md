# LEAF
The Light Electronic Action Framework (LEAF) empowers VA staff in process improvement. LEAF is a solution that enables non-technical users to rapidly digitize paper processes, such as travel and tuition reimbursement, FTE, and many other types of resource requests.

## Repository Overview
* LEAF_Nexus
    * User account cache and user groups
    * Organizational Chart
* LEAF_Request_Portal
    * Electronic forms and workflow system
* libs
    * Third party libraries

## Installation

#### Download git
https://git-scm.com/downloads	

#### Clone github repo to directory with docker-compose.yml
	git clone https://github.com/VHAINNOVATIONS/LEAF.git
	
#### Checkout localtesting branch
	cd LEAF
	git checkout dev

#### Download and install Docker
Windows Installation Instructions: https://docs.docker.com/docker-for-windows/install/
Mac Installation Instructions: https://docs.docker.com/docker-for-mac/install/
	Note: It will make you sign out and sign back in and could require restarting your computer
Recommended:  In Docker preferences, under the Advanced tab, increase the CPU's to 4 and memory to 8gb

### Using a text editor of your choice, edit the following files

#### In the LEAF_Nexus directory
	
	config-example.php
#####		Rename to config.php
		$dbHost = 'mysql'
		$dbName = 'leaf_users'
		$dbUser = 'tester'
		$dbPass = 'tester'

	Under the ini_set line, add: $_SERVER['REMOTE_USER'] = "\\tester";

#### In the LEAF_Request_Portal directory
	dbconfig-example.php
#####		Rename to db_config.php
		$dbHost = 'mysql'
		$dbName = 'leaf_users'
		$dbUser = 'tester'
		$dbPass = 'tester'

		$phonedbHost = 'mysql'
		$phonedbName = 'leaf_users'
		$phonedbUser = 'tester'
		$phonedbPass = 'tester'	

### Run

#### In the same directory as docker-compose.yml run these commands
	1.  docker-compose build
	2.  docker-compose up

#### Navigate to localhost/LEAF_Nexus or localhost/LEAF_Request_Portal in your browser
Once the scripts are finished, you should now be able to navigate to https://localhost/LEAF_Nexus

Within VA, LEAF is provided as a service (Software as a Service), and facilities are not responsible for procuring servers or installing software.

