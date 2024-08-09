// Quick way to trigger tests from a web UI
const http = require('http');
const { spawn } = require('child_process');
const fs = require('fs');
const mysql = require('mysql2/promise');

function main() {
  const server = http.createServer((req, res) => {
    let paths = [
      {url: '/api/v1/test', func: (req, res) => {
        runTests(req, res);
      }},
      {url: '/api/v1/data', func: (req, res) => {
        retrieveData(req, res);
      }},
      {url: '/api/v1/db/leaf_portal_API_testing', func: async (req, res) => {
        await setupDB();
        res.writeHead(302, {
          'Location': 'https://host.docker.internal/LEAF_Request_Portal'
        });
        res.end('Switched to leaf_portal_API_testing DB');
      }},
      {url: '/api/v1/db/leaf_portal', func: async (req, res) => {
        await teardownDB();
        res.writeHead(302, {
          'Location': 'https://host.docker.internal/LEAF_Request_Portal'
        });
        res.end('Switched to leaf_portal DB');
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

async function connectDB() {
  try {
    let db = mysql.createConnection({
      host: process.env.MYSQL_HOST,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      database: 'national_leaf_launchpad'
    });
    return db;

  } catch(err) {
    throw err;
  }
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

// setupDB switches the active DB to the test database
async function setupDB() {
  let db;
  try {
    db = await connectDB();
  } catch(err) {
    return;
  }

  try {
    await db.query('USE leaf_portal_API_testing');
  } catch(err) {
    console.log('Test DB not found. Building it via API tester...');
    await fetch('http://host.docker.internal:8000/api/v1/test').then(res => res.text());
    console.log('... Done.');
  }

  try {
    await db.query('USE national_leaf_launchpad');

    await db.query('UPDATE sites SET portal_database="leaf_portal_API_testing" WHERE id=1');   
  } catch(err) {
    console.err(err);
  }

  db.end();
}

// teardownDB switches the active DB back to the default
async function teardownDB() {
  let db;
  try {
    db = await connectDB();
  } catch(err) {
    return;
  }

  try {
    await db.query('UPDATE sites SET portal_database="leaf_portal" WHERE id=1');
  } catch(err) {
    console.err(err);
  }

  db.end();
}

function retrieveData(req, res) {
  let parts = req.url.split('/api/v1/data/')
  let filename = parts[1];
  console.log(filename);

  fs.readFile(`playwright-report/data/${filename}`, null, (err, data) => {
    if (err) {
      console.error(err);
      return;
    }
    res.end(data);
  });
}

main();
