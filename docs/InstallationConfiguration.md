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

In the sections below `$dbUser` and `$dbPass` are the same values used in the mysql Dockerfile and setup script.

## Docker Compose

Prerequisite setup:
```
docker network create leaf
docker network create leaf-sql
docker network create traefik
```

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

In `docker/docker-compose.yml`, comment out the line `- 443:443`. Next, in `docker/php/Dockerfile`, comment out the line `EXPOSE 443`. Finally, rebuild the images with `docker compose build --no-cache` and navigate to http://localhost/LEAF_Nexus or http://localhost/LEAF_Request_Portal.

## Checking Email

Fake SMTP server is installed as part of the Docker stack to receive email locally from the system. Navigate to http://localhost:5080/email to view emails sent from the system.

Username: tester
Password: tester

## Vue Development

This container is used for the Form Editor and Site Designer Vue apps, and for the updated admin-side SASS files.

Dev mode: Log in to container, bash, and run the command:

npm run dev

webpack will watch for changes to /docker/vue-app/src
**Remember to build for production if src files have been edited**

Production mode: Log in to container, bash, and run the command:

npm run build

form editor and site designer apps builds to respective folders under /libs/js/vue-dest
sass (leaf.css and related fonts and assets) builds to /libs/css
