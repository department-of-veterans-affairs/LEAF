# LEAF Development Environment

## Prerequisites
- Git
- OCI-compliant Container Engine such as Docker
  - Ensure that your host file contains the line `127.0.0.1 host.docker.internal` 

## Installation

Open up a terminal and enter these commands: 

### Windows Prerequisites
Some files require specific formatting. You can either apply the following command OR after running `git clone`, ensure that `./docker/mysql/dev_bootstrap.sh` uses the LF end-of-line sequence instead of CRLF.
```
    git config --global core.autocrlf false
```

### All platforms

```
    git clone --recurse-submodules https://github.com/department-of-veterans-affairs/LEAF.git LEAF

```

Automated Tests are organized in a Git submodule, and the following commands will retrieve the latest version:
```
    cd LEAF/LEAF-Automated-Tests
    git checkout main
    git pull
```

## Running

1. Make sure you're in the LEAF/docker directory
2. Run the below command. Note that this can take several minutes the first time it is run.

```
    docker compose up --build -d
```

3. Open your browser and go to https://host.docker.internal/ 

## Development

### Vue Development

The leaf_vue_ui container is used for the Form Editor and Site Designer Vue apps, and for the updated admin-side SASS files.

#### Devlopment mode

Log in to container, access the terminal, and run the command:
```
    npm run dev
```

Webpack will watch for changes to /docker/vue-app/src

**Remember to build for production if src files have been edited**

#### Production mode

Log in to container, access the terminal, and run the command:
```
    npm run build
```

form editor and site designer apps builds to respective folders under /libs/js/vue-dest
sass (leaf.css and related fonts and assets) builds to /libs/css

## Troubleshooting
Some versions of Docker Desktop on certain platforms may ask you to "Share your Files".

You will see errors like the following during building.
``` bash
error during connect: Post "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.48/containers/create?name=leaf-php-fpm-1": EOF
PS C:\Users\******\LEAF\docker> docker compose up --build -d
Compose now can delegate build to bake for better performances
Just set COMPOSE_BAKE=true
2025/03/26 06:56:41 http2: server: error reading preface from client //./pipe/dockerDesktopLinuxEngine: file has already been closed
```

 - Open Docker Desktop
 - Settings (Gear Icon near the top) 
 - Open Resources
 - Open File Sharing in the sub menu
 - Click on the browse button and find the root of your LEAF folder
 - Once selected click on the "+" icon 