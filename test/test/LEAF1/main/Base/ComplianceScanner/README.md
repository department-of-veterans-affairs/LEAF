# Compliance Scanner

Simple wrapper around [pa11y](https://github.com/pa11y/pa11y) for generating LEAF accessibility findings reports.

## Install

Run `npm install` in the root directory.


## Usage

Currently the project does not support installing globally, so it must be run from within the `bin` directory.

```bash
./bin/complianceScanner.js
```

```
Options:
    -V, --version           output the version number
    -c, --config <path>     config to load for scanning
    -d, --directory <path>  directory to save the generated output (default is current directory)
    -s, --standard          which standard to use: Section508, WCAG2A, WCAG2AA (default), WCAG2AAA
    -h, --help              output usage information
```

## Config

The scanner output can be configured with a json file. See [test.json](config/test.json) for an example.

* **reportHeader**: The title of the findings overview report
* **description**: A description to include in the findings overview report
* **rootURL**: The base URL all urls in the `link` sections are prepended with
* **standard**: The compliance standard to scan against
* **links**: An array of URLs that will be scanned. The `id` of each object in the array must be unique, no error checking is done to ensure it is.
