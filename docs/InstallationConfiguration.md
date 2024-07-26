# LEAF Development Environment

## Prerequisites

- Install Git
  - https://git-scm.com/downloads  Pick the one for your computer's OS
  - Just "next, next, next" until you get to the Configuring the line ending conversions window.  Choose "Chechout as-is, commit as-is".  Then "next, next, next, install". 
- Install Docker
  - For Windows:  https://www.docker.com/
  - For Mac: https://docs.docker.com/desktop/install/mac-install/
  - For Linux: Should be your distro's installer (yum, apt, dm, etc) install docker.
  - Enable setting: "Add the *.docker.internal names to the host's etc/hosts file" or associate `host.docker.internal` with localhost (127.0.0.1).

## Installation

1. Open File Explorer.  Create a new folder for the code.  For example "leaf-code".

2. Right click on this new folder.  At the bottom of the pop-up, click on "Show More Options".  Click on "Open Git Bash Here".

3. In the new terminal that opens up, enter these commands: 
######
    git clone https://github.com/department-of-veterans-affairs/LEAF.git LEAF
######
    cd LEAF
######
    sh RunMe.sh  

4. The last can take several minutes.  Some errors may pop up if you've run this before. These can be ignored if everything comes up. 
  You should see at least what is below.  The times may be different.
  
      [+] Running 10/10<br/>
      <table style="border: none;">
        <tr><td>✔ Network docker_ui-test</td><td>          Created  </td><td>      0.0s  </td></tr>
        <tr><td>  ✔ Container leaf-smtp </td><td>            Started </td><td>       4.9s  </td></tr>
        <tr><td>  ✔ Container selenium-chrome </td><td>      Started </td><td>       5.7s  </td></tr>
        <tr><td>  ✔ Container leaf-adminer </td><td>         Started </td><td>       5.3s  </td></tr>
        <tr><td>  ✔ Container leaf_vue_ui </td><td>          Started </td><td>       4.2s  </td></tr>
        <tr><td>  ✔ Container leaf-fpm </td><td>             Started </td><td>       5.7s  </td></tr>
        <tr><td>  ✔ Container leaf-mysql </td><td>           Started </td><td>       5.2s  </td></tr>
        <tr><td>  ✔ Container leaf-api-test-helper</td><td>  Started </td><td>       5.7s  </td></tr>
        <tr><td>  ✔ Container test-api </td><td>             Started </td><td>       6.3s  </td></tr>
        <tr><td>  ✔ Container leaf-nginx </td><td>           Started </td><td>       6.2x  </td></tr>
      </table>        
                   
5. Open your browser and go to https://host.docker.internal/ 
  - LEAF Sites.  These are the two primary sites you will use to access LEAF
    - Request Portal: A low code/no code workflow management tool utilized to digitize administrative business processes
    - Nexus: Digitized organizational charts to visually display the relationship of positions within LEAF. 
  - Automated tests.  These are one button tests that will make sure everything is working correctly.
    - API Tester:  These are tests primarily for api's that can be targeted by client-side javascript calls.
    - End-to-End Tests:  This is a set of tests meant to verify that all different components of LEAF are working correctly together.

      *Note:  This particular test is extensive and will take a significant amount of time.  The new page will be blank until it finishes running and then will bring back an intereactive results page.
  - Dev Corner.  These are used by developers.
    - Adminer:  This takes you to the login for a Gui for the MySQL database.
      - Username: tester
      - Password: tester
    - SMTP Server:  This takes you to the GUI for the fake mail system so you can verify emails are going out.
    - phpinfo():  For geeks.  This shows the current setup of the PHP engine.


### Vue Development

This container is used for the Form Editor and Site Designer Vue apps, and for the updated admin-side SASS files.

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

### Running without HTTPS

#### Docker

1. In `docker/docker-compose.yml`, comment out the line `- 443:443`
2. Rebuild the images with `docker compose build --no-cache`
