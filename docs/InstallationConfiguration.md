# LEAF Development Environment

## Prerequisites

- Install Git
- Install Docker for Desktop
  - Enable setting: "Add the *.docker.internal names to the host's etc/hosts file" or associate `host.docker.internal` with localhost (127.0.0.1).

## Installation

1. Run the command:
  - `git config --global core.autocrlf false`
    - Or ensure that `./docker/mysql/dev_bootstrap.sh uses the LF end-of-line sequence instead of CRLF.
2. Copy this project into a directory on your computer:
  - `git clone https://github.com/department-of-veterans-affairs/LEAF.git`

## Configuration

A couple docker networks need to be created:

```shell
docker network create leaf
docker network create leaf-sql
```

## Running

1. Navigate to the LEAF/docker directory
2. Run the command `docker compose up --build -d`
3. Navigate to https://host.docker.internal/ in your browser.

### Exploring Database

`http://localhost:8080/` this will get you into the database to allow for data adjustments and additions.

- Username: tester
- Password: tester

### Checking Email

smtp4dev is installed as part of the Docker stack to receive email locally from the system. Navigate to http://localhost:5080/ to view emails sent from the system.

### Vue Development

This container is used for the Form Editor and Site Designer Vue apps, and for the updated admin-side SASS files.

#### Devlopment mode

Log in to container, access the terminal, and run the command:

`npm run dev`

Webpack will watch for changes to /docker/vue-app/src

**Remember to build for production if src files have been edited**

#### Production mode

Log in to container, access the terminal, and run the command:

`npm run build`

form editor and site designer apps builds to respective folders under /libs/js/vue-dest
sass (leaf.css and related fonts and assets) builds to /libs/css

### Running without HTTPS

#### Docker

1. In `docker/docker-compose.yml`, comment out the line `- 443:443`
2. In `docker/php/Dockerfile`, comment out the line `EXPOSE 443`.
3. Rebuild the images with `docker compose build --no-cache`
