const path = require('path')			//     /LoadTesting/RunParallel.js
const async = require('async')
const newman = require('newman')

const PARALLEL_RUN_COUNT = 3

const parametersForTestRun = {
    collection: path.join('/LoadTesting', 'PP_Load_collection-2023-02-02.json'), // your collection
    environment: path.join(__dirname, 'postman/localhost.postman_environment.json'), //your env
    reporters: 'cli'	
};

parallelCollectionRun = function (done) {
    newman.run(parametersForTestRun, done);
};

let commands = []
for (let index = 0; index < PARALLEL_RUN_COUNT; index++) {
    commands.push(parallelCollectionRun);
}

// Runs the Postman sample collection as determined by PARALLEL_RUN_COUNT, in parallel.
async.parallel(
    commands,
    (err, results) => {
        err && console.error(err);

        results.forEach(function (result) {
            var failures = result.run.failures;
            console.info(failures.length ? JSON.stringify(failures.failures, null, 2) :
                `${result.collection.name} ran successfully.`);
        });
    });