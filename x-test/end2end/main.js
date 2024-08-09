// Quick way to trigger tests from a web UI
const http = require('http');
const { spawn } = require('child_process');
const fs = require('fs');
const mysql = require('mysql');

const server = http.createServer((req, res) => {
  if (req.url === '/api/v1/test' && req.method === 'GET') {
    runTests(req, res);
  } else {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end("This is the end2end test helper");
  }
});

server.listen(8001, () => console.log('Server running on port 8001'));


var startedTests = false;
async function runTests(req, res) {
  if (startedTests) {
    res.end('Tests already running');
  }
  startedTests = true;

  console.log('running tests...');
  let cmd = spawn('npx', ['playwright', 'test']);
  res.writeHead(200, { 'Content-Type': 'text/html' });

  cmd.stdout.on('data', data => {
    console.log(data.toString());
  });

  cmd.stderr.on('data', data => {
    console.log(data.toString());
  });

  cmd.on('exit', () => {
    fs.readFile('playwright-report/index.html', 'utf8', (err, data) => {
      if (err) {
        console.error(err);
        return;
      }
      res.end(data);
    });

    startedTests = false;
  });
}

async function setupTestDB() {
  var connection = mysql.createConnection({
    host: 'localhost',
    user: 'me',
    password: 'secret',
    database: 'my_db'
  });
}
