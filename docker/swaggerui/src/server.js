'use strict';
var express = require('express');
var cors = require('cors');
var bodyParser = require('body-parser');
var fs = require('fs');

// Constants
const PORT = process.env.PORT || 8080;
const SWAGGER_UI_DIR = '/swaggerui';
const SWAGGER_FILE = '/swaggerui/swagger/nexus-swagger.json';

var app = express();
app.use(cors());

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
});

// JSON formatting (beautify)
app.set('json spaces', 2);

// parse 'Content-Type: application/json'
app.use(bodyParser.json())

// serve the static SwaggerUI files
app.use('/', express.static(SWAGGER_UI_DIR));

// serve swagger.json spec
app.use('/spec', express.static(SWAGGER_FILE))

// publish a new swagger.json spec
app.post('/publish', function(request, response) {
  var swaggerSpec = request.body;

  fs.writeFile(SWAGGER_FILE, JSON.stringify(swaggerSpec), 'utf-8', function(err) {
    if (err) {
      response.status(500);
      response.json({
        message: err.message,
        error: err
      });
    } else {
      response.status(200);
      response.json({
        message: 'Successfully published new Swagger Spec'
      });
    }
  });
});

// catch 404 errors
app.use(function(request, response, next) {
  response.status(404);
  response.json({
    message: 'Not Found'
  });
});

// catch application errors
app.use(function(err, request, response, next) {
  response.status(500);
  response.json({
    message: err.message,
    error: err.stack
  });
})

// start the server and make it listen for connections
app.listen(PORT, function() {
  console.log('Listening on port ' + PORT);
});
