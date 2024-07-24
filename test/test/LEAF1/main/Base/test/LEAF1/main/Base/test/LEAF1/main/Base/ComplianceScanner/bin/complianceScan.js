#!/usr/bin/env node
'use strict';

var fs = require('fs');
var pkg = require('../package.json');
var program = require('commander');

var scanner = require('../lib/complianceScan');

configureProgram(program);
runProgram(program);

function configureProgram(program) {
    program
        .version(pkg.version)
        .usage('[options]')
        .option(
            '-c, --config <path>',
            'config to load for scanning'
        )
        .option(
            '-d, --directory <path>',
            'directory to save the generated output (default is current directory)'
        )
        .option(
            '-s, --standard <name>',
            'which standard to use: Section508, WCAG2A, WCAG2AA (default), WCAG2AAA'
        )
        .parse(process.argv);
}

function runProgram(program) {
    var options = processOptions(program);
    var scan = scanner(options);
}

function processOptions(program) {
    var options = {
        "standard": program.standard ? program.standard : "WCAG2AA",
        "output": program.directory ? program.directory : "reports"
    };

    if (program.config == null) {
        console.log('Must specify config file');
        program.help();
        process.exit(0);
    }

    var configPath = program.config;
    if (fs.existsSync(configPath)) {
        options["config"] = require('../' + configPath);
        options.standard = options.config.standard ? options.config.standard : options.standard;
    } else {
        console.log('Invalid config file: ' + configPath);
        process.exit(0);
    }

    return options;
}