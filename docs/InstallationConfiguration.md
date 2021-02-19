# Prerequisites

Install Git

Install Docker for Desktop

# Installation

`git config --global core.autocrlf false`  
Clone this project into a directory on your computer (example: C:\Desktop\Projects).

# Configuration

Several files need to be created/updated for LEAF to operate in your environment.

In the sections below `$dbUser` and `$dbPass` are the same values used in the mysql Dockerfile and setup script.

## LEAF_Nexus

Copy `globals.php.example` to `globals.php` and change the following variables to reflect your setup:

```php
const DIRECTORY_HOST = 'mysql';
const DIRECTORY_DB = 'leaf_users';
const DIRECTORY_USER = 'tester';
const DIRECTORY_PASS = 'tester';
const LEAF_NEXUS_URL = 'https://localhost/LEAF_Nexus/';
const HTTP_HOST = 'localhost';

const AUTH_URL = 'localhost/LEAF_Nexus/auth_domain';

//const AUTH_TYPE = 'cookie';
```
	
Copy `config-example.php` to `config.php` and change the following variables to reflect your setup:

```php
$dbHost = 'mysql'
$dbName = 'leaf_users'
$dbUser = 'tester'
$dbPass = 'tester'
```

## LEAF_Request_Portal 

Copy `globals.php.example` to `globals.php` and change the following variables to reflect your setup:

```php
const DIRECTORY_HOST = 'mysql';
const DIRECTORY_DB = 'leaf_portal';
const DIRECTORY_USER = 'tester';
const DIRECTORY_PASS = 'tester';
const LEAF_NEXUS_URL = 'https://localhost/LEAF_Nexus/';
const HTTP_HOST = 'localhost';

const AUTH_URL = 'localhost/LEAF_Nexus/auth_domain';

//const AUTH_TYPE = 'cookie';
```

Copy `db_config-example.php` to `db_config.php` and change the following variables to reflect your setup:

```php
$dbHost = 'mysql'
$dbName = 'leaf_portal'
$dbUser = 'tester'
$dbPass = 'tester'

$phonedbHost = 'mysql'
$phonedbName = 'leaf_users'
$phonedbUser = 'tester'
$phonedbPass = 'tester'	

# this should point to the LEAF Nexus base path 
$orgchartPath = '../LEAF_Nexus'
```

## Docker Compose

Open up a terminal and navigate to the LEAF/docker directory.  
Run the command `docker-compose up -build -d`  
Docker will build the local environment based on the docker-compose.yml file.  
Check to see that docker is running your local environment.  

## Running

Navigate to https://localhost/LEAF_Nexus or https://localhost/LEAF_Request_Portal in your browser.

## Running without HTTPS
### Docker
In `docker/docker-compose.yml`, comment out the line `- 443:443`.  Next, in `docker/php/Dockerfile`, comment out the line `EXPOSE 443`.  Finally, rebuild the images with `docker-compose build --no-cache` and navigate to http://localhost/LEAF_Nexus or http://localhost/LEAF_Request_Portal.


## Checking Email

Fake SMTP server is installed as part of the Docker stack to receive email locally from the system. Navigate to http://localhost:5080/email to view emails sent from the system.

Username: tester
Password: tester
