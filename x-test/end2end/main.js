// Quick way to trigger tests from a web UI
const http = require('http');
const { spawn } = require('child_process');
const fs = require('fs');

function main() {
  const server = http.createServer((req, res) => {
    let paths = [
      {url: '/api/v1/test', func: (req, res) => {
        runTests(req, res);
      }},
      {url: '/api/v1/data', func: (req, res) => {
        retrieveData(req, res);
      }},
    ];
  
    if(req.method == 'GET') {
      for(let i in paths) {
        if(req.url.indexOf(paths[i].url) != -1) {
          paths[i].func(req, res);
          return;
        }
      }
    }
  
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end("This is the end2end test helper");
    console.log('Unhandled route: ', req.url);
  
  });
  
  server.listen(8001, () => console.log('Server running on port 8001'));
}

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

function retrieveData(req, res) {
  let parts = req.url.split('/api/v1/data/')
  let filename = parts[1];

  fs.readFile(`playwright-report/data/${filename}`, null, (err, data) => {
    if (err) {
      console.error(err);
      return;
    }
    res.end(data);
  });
}

main();
