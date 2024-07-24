'use strict';

var async = require('async');
var fs = require('fs');

var pa11y = require('pa11y');
var htmlReporter = require('pa11y/reporter/html');

var dot = require('dot');
var pkg = require('../package.json');

module.exports = complianceScan;

/**
 * Run a compliance scan
 * 
 * @param {*} options 
 */
function complianceScan(options) {
  generateReport(options);
}

/**
 * Generate and write the compliance report(s)
 * 
 * @param {*} options 
 */
function generateReport(options) {
  var pal = buildPa11y(options);
  var series = buildTestSeries(pal, options); 

  async.series( series, function (error, results) {
    if (error) return console.error(error.message);

    var templateData = buildTemplateData(results, options);

    writeReport(results, templateData, options);
  });
}

/**
 * Build a pa11y object with the given options
 * 
 * @param {*}   options 
 * @returns {*} the pa11y object
 */
function buildPa11y(options) {
  // TODO: Change this to custom standards for HTML_CodeSniffer
  var ignoreElements = [];
  options.config.links.forEach(link => {
    if (link.ignoreElements) {
      ignoreElements.push(link.ignoreElements);
    }
  });

  return pa11y({
    standard: options.standard,
    hideElements: ignoreElements.join(','),
    log: {
      error: console.error.bind(console),
      // hide any output that isn't an error
      debug: () => {},
      info: () => {}
    }
  });
}

/**
 * Build the data object for populating the report template
 * 
 * @param {*}   results object of results from the async series of pa11y.run()
 * @param {*}   options 
 * @returns {*} the template data object
 */
function buildTemplateData(results, options) {
  var templateData = {
    "reportParams": {
      "date": new Date(),
      "leafVersion": "unknown",
      "pa11yVersion": pkg.dependencies.pa11y,
      "scannerVersion": pkg.version
    },
    "options": options,
    "overview": {
      "totalPages": options.config.links.length,
      "numError": 0,
      "numWarning": 0,
      "numNotice": 0,
      "numTotal": 0
    },
    "reports": []
  };

  options.config.links.forEach((link, index) => {
    var findings = compileFindings(results[link.id]);

    templateData.overview.numError += findings.error;
    templateData.overview.numWarning += findings.warning;
    templateData.overview.numNotice += findings.notice;

    templateData.reports.push({"page": link.url, "findings": findings, "idx": index});
  });

  templateData.overview.numTotal = templateData.overview.numError + templateData.overview.numWarning + templateData.overview.numNotice;

  return templateData;
}

/**
 * Build the async series object from the options.config.links
 * 
 * @param {*}   pal       the pa11y object
 * @param {*}   options 
 * @returns {*} the async series object
 */
function buildTestSeries(pal, options) {
  var series = {};
  options.config.links.forEach((link, index) => {
    pal.options.hideElements = link.ignoreElements ? link.ignoreElements.join(',') : '';
    series[link.id] = pal.run.bind(pal, options.config.rootURL + link.url);
  });

  return series;
}

/**
 * Compile the compliance findings from pa11y.run() into the number of error, warning, notice and total number of issues
 * 
 * @param {*}   findings 
 * @returns {*} the compiled results object of the findings
 */
function compileFindings(findings) {
  var results = {
    "error": 0,
    "warning": 0,
    "notice": 0,
    "total": 0
  };

  findings.forEach(finding => {
    switch(finding.typeCode) {
      case 1:
        results.error += 1;
        break;
      case 2:
        results.warning += 1;
        break;
      case 3:
        results.notice += 1;
        break;
      default:
        break;
    }
  });

  results.total = results.error + results.warning + results.notice;

  return results;
}

/**
 * Write the results reports
 * 
 * @param {*} results 
 * @param {*} templateData 
 * @param {*} options 
 */
function writeReport(results, templateData, options) {
  fs.readFile(__dirname + '/../templates/complianceOverview.template', function (err, data) {
    if (err) throw err;

    var reportDirectory = __dirname + '/../' + options.output;
    fs.mkdir(reportDirectory, function(err) {
      // err will only happen if directory exists, and we don't care if it does
      // if (err) throw err;

      var template = dot.template(data.toString());
      var reportHTML = template(templateData);

      fs.writeFile(reportDirectory + "/overview.html", reportHTML, function(err) {
        if (err) throw err;

        options.config.links.forEach((link, index) => {
          var individualReportHTML = htmlReporter.process(results[link.id], link.url);

          fs.writeFile(reportDirectory + "/" + index + ".html", individualReportHTML, function(err) {
            if (err) throw err;
          });
        });
      });
    });
  });
}