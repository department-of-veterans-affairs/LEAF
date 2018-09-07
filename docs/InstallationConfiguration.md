# Installation

Clone this project into the directory where the development server serves content (for XAMPP, this will be `xampp/htdocs`).

# Configuration

Several files need to be created/updated for LEAF to operate in your environment.

In the sections below `$dbUser` and `$dbPass` are the same values used in the mysql Dockerfile and setup script.

## Apache

Ensure that the apache server configuration contains:

```apache
RewriteEngine On
RewriteRule (.*)/api/(.*)$ $1/api/index.php?a=$2 [QSA,L]
```

This will fix some issues where the API endpoint is unreachable.

## LEAF_Nexus

Copy `globals.php.example` to `globals.php` and change the following variables to reflect your setup:

```php
const DIRECTORY_HOST = 'mysql_host';
const DIRECTORY_DB = 'leaf_users';
const DIRECTORY_USER = 'dbnexususer';
const DIRECTORY_PASS = 'dbnexuspass';
```
	
Copy `config-example.php` to `config.php` and change the following variables to reflect your setup:

```php
$dbHost = 'mysql'
$dbName = 'leaf_users'
$dbUser = 'dbnexususer'
$dbPass = 'dbnexuspass'
```

## LEAF_Request_Portal 

Copy `globals.php.example` to `globals.php` and change the following variables to reflect your setup:

```php
const DIRECTORY_HOST = 'mysql_host';
const DIRECTORY_DB = 'leaf_portal';
const DIRECTORY_USER = 'dbportaluser';
const DIRECTORY_PASS = 'dbportalpass';
const LEAF_NEXUS_URL = 'https://wherever/path/to/nexus/'
```

Copy `db_config-example.php` to `db_config.php` and change the following variables to reflect your setup:

```php
$dbHost = 'mysql_host'
$dbName = 'leaf_portal'
$dbUser = 'dbportaluser'
$dbPass = 'dbportaluser'

$phonedbHost = 'mysql_host'
$phonedbName = 'leaf_users'
$phonedbUser = 'dbnexususer'
$phonedbPass = 'dbnexuspass'	

# this should point to the LEAF Nexus base path 
$orgchartPath = '../LEAF_Nexus'
```

## Running

Navigate to http://localhost/LEAF_Nexus or http://localhost/LEAF_Request_Portal in your browser.