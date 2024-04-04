# Prerequisites

Install Git

Install Docker for Desktop

# Installation

Open Git Bash
Run the command `git config --global core.autocrlf false`
Clone this project into a directory on your computer (example: C:\Desktop\Projects).
`git clone <repo url>`

# Configuration

Initial setup will require you to setup a couple networks to allow for a full build

`docker network create leaf`

`docker network create traefik`

`docker network create leaf-sql`

## Docker Compose

Open up a terminal and navigate to the LEAF/docker directory.
Run the command `docker compose up --build -d`
Docker will build the local environment based on the docker-compose.yml file.
Check to see that docker is running your local environment.

Adding -p before `up` allows you to name your dockers, so for example database
moves from mariadb to mysql you can keep the two containers separate. for example `docker compose -p leaf_20 up --build -d`

## Running

Navigate to https://host.docker.internal/LEAF_Nexus or https://host.docker.internal/LEAF_Request_Portal in your browser. There is another entry point that will allow for running of testing scripts located at https://host.docker.internal/ clicking on the links for testing will run the tests within the browser.

## Exploring Database

`http://localhost:8080/` this will get you into the database to allow for data adjustments and additions.

Username: tester
Password: tester

## Checking Email

Fake SMTP server is installed as part of the Docker stack to receive email locally from the system. Navigate to https://localhost:5080/email to view emails sent from the system.

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

## Running without HTTPS

### Docker

In `docker/docker-compose.yml`, comment out the line `- 443:443`. Next, in `docker/php/Dockerfile`, comment out the line `EXPOSE 443`. Finally, rebuild the images with `docker compose build --no-cache` and navigate to http://host.docker.internal/LEAF_Nexus or http://host.docker.internal/LEAF_Request_Portal.