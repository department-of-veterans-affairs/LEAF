![LEAF](libs/dynicons/svg/LEAF-logo.svg)

# 

Built by VA for VA, LEAF empowers non-technical users to implement workflows and digital forms that allow for fast turnaround, complete transparency and status tracking. LEAF’s built-in Form Library promotes standardization of best practices. LEAF minimizes the startup costs of technology necessary to modernize the underlying business processes, while ultimately improving the health and safety of Veterans. 

**Problem to be solved:** Make it easy for non-technical users to take ownership in digitizing and improving their business processes, reduce no-value steps and focus on superb customer service for our Veterans. Standardize and propagate best practices at minimal cost.

**Who will benefit:** Any agency or department with multi-layered approval processes, credentialing, validation, resources management, resource readiness, preliminary approval or preparation steps that must be tracked with high reliability and full transparency will benefit from LEAF platform. Anybody who needs a convenient, centralized platform to conduct evidence-based process improvements.

[Introduction to LEAF](docs/LEAF_Product_Overview.pdf)

## NOTICE

Within VA, LEAF is provided as a service (Software as a Service), and facilities are not responsible for procuring servers or installing software.

LEAF is currently not configured/optimized for usage outside of the VA, proper setup and authentication are responsiblities of the user.

## Repository Overview
* [LEAF_Nexus](LEAF_Nexus)

    Organizational Chart, user accounts, user groups 

* [LEAF_Request_Portal](LEAF_Request_Portal)

    Electronic forms and workflow system

* [libs](libs) 

    Shared and third party libraries used within LEAF

* [docs](docs)
    
    LEAF documentation

    * [Installation and Configuration](docs/InstallationConfiguration.md)
    * [Code Reviews](docs/CodeReviews.md)
    * [Contributing](docs/Development.md)

## USWDS GULP NPM Install

LEAF will be using the United States Web Design System (USWDS): https://designsystem.digital.gov/how-to-use-uswds/

The assets include fonts, colors, layout grid, and FontAwesome icons that are managed and compiled with npm and Gulp. 
The links below provide instructions on how to install the resources using npm and Gulp.

USWDS NPM Install: https://www.npmjs.com/package/uswds#install-using-npm

USWDS Gulp Install: https://github.com/uswds/uswds-gulp

USWDS Gulp pipeline for copying assets and compiling Sass

A simple Gulp 4.0 workflow for transforming USWDS Sass into browser-readable CSS.

Requirements
You'll need to be familiar with the command line.

You'll need node and npm.

You'll need to install the following packages via npm:

autoprefixer
cssnano
fibers
gulp@^4.0.0
gulp-notify
gulp-postcss
gulp-rename
gulp-replace
gulp-sass
gulp-sourcemaps
path
postcss-sort-media-queries
sass
uswds@^2.0.0
uswds-gulp@github:uswds/uswds-gulp

Installation
If you've never installed Gulp, you'll need to install the Gulp command line interface:

npm install gulp-cli -g

Add all the required dependencies at once with following command from your project's root directory:

npm install autoprefixer gulp@^4.0.0 gulp-notify gulp-postcss gulp-replace gulp-sass gulp-sourcemaps postcss-csso sass uswds@latest uswds-gulp@github:uswds/uswds-gulp --save-dev

Usage
If you don't already have a project gulpfile, copy the gulpfile.js to your current directory (the project root):

cp node_modules/uswds-gulp/gulpfile.js .

OR

If you do already have a project gulpfile, copy and rename the USWDS gulpfile (then you can manually add the contents of the USWDS gulpfile to your existing gulpfile and continue with the instructions):

cp node_modules/uswds-gulp/gulpfile.js gulpfile-uswds.js

Open gulpfile.js in a text editor. In the Paths section, set the following constants with the proper paths. Don't use trailing slashes in the paths. All paths should be relative to the project root.

PROJECT_SASS_SRC: The directory where we'll save your USWDS settings files and the project's custom Sass.
IMG_DEST: The directory where we'll save the USWDS images
FONTS_DEST: The directory where we'll save the USWDS fonts
JS_DEST: The directory where we'll save the USWDS javascript
CSS_DEST: The destination of the final, compiled CSS
Save gulpfile.js with these updated paths.

Initialize your USWDS project. Initialization does the following:

Copies settings files and the USWDS base Sass file to your project Sass directory
Copies images, fonts, and javascript files to the directories you set above
Compiles the USWDS Sass into a usable CSS file, called styles.css by default
Intitialize your USWDS project by running the following command:

gulp init

Edit your USWDS settings in the new settings files and add custom Sass to the new _uswds-theme-custom-styles.scss file. Watch these files and compile any changes with

gulp watch
🚀


