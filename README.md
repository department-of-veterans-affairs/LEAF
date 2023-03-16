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

LEAF will be using the United States Web Design System (USWDS): <https://designsystem.digital.gov/how-to-use-uswds/>

The assets include fonts, colors, layout grid, and FontAwesome icons that are managed and compiled with npm and Gulp. 
The links below provide instructions on how to install the resources using npm and Gulp.

USWDS NPM Install Instructions: <https://www.npmjs.com/package/uswds#install-using-npm>

USWDS Gulp Install Instructions: <https://github.com/uswds/uswds-gulp>

Installation
A simple Gulp 4.0 workflow for transforming USWDS Sass into browser-readable CSS.

If you've never installed Gulp, you'll need to install the Gulp command line interface:

npm install gulp-cli -g

Add all the required dependencies at once with following command from your project's root directory:

npm install autoprefixer gulp@^4.0.0 gulp-notify gulp-postcss gulp-replace gulp-sass gulp-sourcemaps postcss-csso sass uswds@latest uswds-gulp@github:uswds/uswds-gulp --save-dev

Usage
If you don't already have a project gulpfile, copy the gulpfile.js to your current directory (the project root):

cp node_modules/uswds-gulp/gulpfile.js .


