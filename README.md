# LEAF
The Light Electronic Action Framework (LEAF) empowers VA staff in process improvement. LEAF is a solution that enables non-technical users to rapidly digitize paper processes, such as travel and tuition reimbursement, FTE, and many other types of resource requests.

## Repository Overview
* `LEAF_Nexus`
    * User account cache and user groups
    * Organizational Chart
* `LEAF_Request_Portal`
    * Electronic forms and workflow system
* `libs`
    * Third party libraries

## Installation

### Docker

[Docker](https://docker.com) is used to provide a consistent enviroment between developers, and eventually production.

### Configuration

Several files need to be created/updated for LEAF to operate in your environment.

In the sections below `$dbUser` and `$dbPass` are the same values used in the mysql Dockerfile and setup script.

#### Apache

Ensure that the apache server configuration contains:

```apache
RewriteEngine On
RewriteRule (.*)/api/(.*)$ $1/api/index.php?a=$2 [QSA,L]
```

This will fix some issues where the API endpoint is unreachable.

#### LEAF_Nexus
	
Rename `config-example.php` to `config.php` and change the following variables 
```php
$dbHost = 'mysql'
$dbName = 'leaf_users'
$dbUser = 'tester'
$dbPass = 'tester'
```

#### LEAF_Request_Portal 

Rename `db_config-example.php` to `db_config.php` and change the following variables:

```php
$dbHost = 'mysql'
$dbName = 'leaf_users'
$dbUser = 'tester'
$dbPass = 'tester'

$phonedbHost = 'mysql'
$phonedbName = 'leaf_users'
$phonedbUser = 'tester'
$phonedbPass = 'tester'	

# this should point to the LEAF_Nexus directory
$orgchartPath = '../LEAF_Nexus'
```

### Run

In the same directory as `docker-compose.yml` run: 

```bash
docker-compose up
```

Navigate to http://localhost/LEAF_Nexus or http://localhost/LEAF_Request_Portal in your browser.

## NOTICE

Within VA, LEAF is provided as a service (Software as a Service), and facilities are not responsible for procuring servers or installing software.

LEAF is currently not configured/optimized for usage outside of the VA, proper setup and authentication are responsiblities of the user.