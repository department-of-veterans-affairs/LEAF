# Prerequisites

Install Git

Install Docker for Desktop

# Installation

Open Git Bash
Run the command `git config --global core.autocrlf false`
Clone this project into a directory on your computer (example: C:\Desktop\Projects).
`git clone <repo url>`

# Configuration

Several files need to be created/updated for LEAF to operate in your environment.

## LEAF_Nexus

Create `LEAF_Nexus/sources/Config.php`, and add the following code to the file:

```php
<?php

namespace Orgchart;

class Config
{
    public $title = 'Organizational Chart';

    public $city = '';

    public $adminLogonName = DATABASE_DB_ADMIN;    // Administrator's logon name

    public $adPath = array('OU=Users,DC=va,DC=gov'); // Active directory paths

    public static $uploadDir = './UPLOADS/';

    // Directory for user uploads
    // using backslashes (/), with trailing slash

    public static $ERM_Sites = array('resource_management' => ''); // URL to ERM sites with trailing slash

    public $dbHost = DIRECTORY_HOST;
    public $dbName = DIRECTORY_DB;
    public $dbUser = DIRECTORY_USER;
    public $dbPass = DIRECTORY_PASS;
}

```

## LEAF_Request_Portal

Create `LEAF_Request_Portal/sources/Config.php` and add the following code into the file:

```php
<?php

namespace Portal;

class Config
{
    public $title = 'New LEAF Site';
    public $city = '';
    public $adminLogonName = DATABASE_DB_ADMIN;    // Administrator's logon name
    public $adPath = array('OU=myOU,DC=domain,DC=tld'); // Active directory path
    public static $uploadDir = './UPLOADS/';
    // Directory for user uploads
                                             // using backslashes (/), with trailing slash
    public static $orgchartPath = '../LEAF_Nexus'; // HTTP Path to orgchart with no trailing slash
    public static $orgchartImportTags = array('Academy_Demo1'); // Import org chart groups if they match these tags
    public $descriptionID = 16;    // indicator ID for description field
    public static $emailPrefix = 'Resources: ';              // Email prefix
    public static $emailCC = array();    // CCed for every email
    public static $emailBCC = array();    // BCCed for every email
    public $phonedbHost = DIRECTORY_HOST;
    public $phonedbName = DIRECTORY_DB;
    public $phonedbUser = DIRECTORY_USER;
    public $phonedbPass = DIRECTORY_PASS;
}

```

## Docker Compose

Open up a terminal and navigate to the LEAF/docker directory.
Run the command `docker compose -p leaf_20 up --build -d`
Docker will build the local environment based on the docker-compose.yml file.
Check to see that docker is running your local environment.

Adding -p before `up` allows you to name your dockers, so for example database
moves from mariadb to mysql you can keep the two containers separate.

## Running

Navigate to https://localhost/LEAF_Nexus or https://localhost/LEAF_Request_Portal in your browser.

## Running without HTTPS

### Docker

In `docker/docker-compose.yml`, comment out the line `- 443:443`. Finally, rebuild the images with `docker compose build --no-cache` and navigate to http://localhost/LEAF_Nexus or http://localhost/LEAF_Request_Portal.

## Checking Email

Fake SMTP server is installed as part of the Docker stack to receive email locally from the system. Navigate to http://localhost:5080/email to view emails sent from the system.

Username: tester
Password: tester

## Vue Development

Dev mode: Log in to container and run the command:

npm run dev-vue

webpack will watch for changes to /docker/vue-app/src
**Remember to build for production if src files have been edited**

Production mode: Log in to container and run the command:

npm run build-vue

webpack will build to /libs/js/vue-dest
