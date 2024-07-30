# LEAF Development Environment

## Prerequisites
- Git
- Docker:  You'll need to ensure that your hosts file has a line pointing *.docker.internal to localhost (127.0.0.1)

## Installation

Open up a terminal and enter these commands: 
######    
    git config --global core.autocrlf false
######
    git clone https://github.com/department-of-veterans-affairs/LEAF.git LEAF
######
    cd LEAF/docker
######
    docker network create leaf
    docker network create leaf-sql
    docker volume create leaf-php-data
    docker volume create leaf-lib

## Running

1. Make sure you're in the LEAF/docker directory
2. Run the below command.  Note that this can take several minutes the first time it is run.
###### 
    docker compose up --build -d

3. Open your browser and go to https://host.docker.internal/ 
  - LEAF Sites.  These are the two primary sites you will use to access LEAF
  - Automated tests.  These are one button tests that will make sure everything is working correctly.
  - Dev Corner.  These are used by developers.
    - The Adminer site will require the below credentials.  
      - Username: tester
      - Password: tester

## Development

### Vue Development

The leaf_vue_ui container is used for the Form Editor and Site Designer Vue apps, and for the updated admin-side SASS files.

#### Devlopment mode

Log in to container, access the terminal, and run the command:
######
    npm run dev

Webpack will watch for changes to /docker/vue-app/src

**Remember to build for production if src files have been edited**

#### Production mode

Log in to container, access the terminal, and run the command:
######
    npm run build

form editor and site designer apps builds to respective folders under /libs/js/vue-dest
sass (leaf.css and related fonts and assets) builds to /libs/css

