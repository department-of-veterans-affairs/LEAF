/**
*    To execute, from Windows terminal -> get inside the container:
*		-> docker exec -it newman bash      (Can be run from anywhere in the repo)
*    	then -> node load-tests.js
*
* @fileOverview A script to execute parallel collection runs using async.
*/

var path = require('path'), 
    async = require('async'), // https://npmjs.org/package/async 
    newman = require('newman'), 
	
	/**
     * @type {Object}
     */
        options = {
        //collection: path.join(__dirname, 'sample-collection.json'),
		collection: path.join(__dirname, 'PreProd-LOAD-TESTS.json'),
		//environment: require('filename.json'),
		reporters: 'cli',			//  cli  junit  json  progress  htmlextra   newman-reporter-csv
		insecure: true
    },   
    
	/**
     * A collection runner function that runs a collection for a pre-determined options object.
     * @param {Function} done - A callback function that marks the end of the current collection run, when called.
     */
    parallelCollectionRun = function (done) {
        newman.run(options, done);
    };


// Runs the Postman sample collection the # of times in the ary, in parallel.
const runs = Array(4).fill(parallelCollectionRun);
async.parallel(runs,
    /**
    * @param {?Error} err - An Error instance / null that determines whether or not the parallel collection run
    * succeeded.
    * @param {Array} results - An array of collection run summary objects.
    */
    function (err, results) {
        err && console.error(err);     
        results.forEach(function (result) {
            var failures = result.run.failures;
            console.info(failures.length ? JSON.stringify(failures.failures, null, 2) :
                `${result.collection.name} ran successfully.`);
    });
});

 