import { test as setup } from '@playwright/test';
import mysql from 'mysql2/promise';

setup('teardown database', async ({ }) => {
  return;
    let db = await mysql.createConnection({
        host: process.env.MYSQL_HOST,
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: 'national_leaf_launchpad'
    });

    try {
        await db.query('UPDATE sites SET portal_database="leaf_portal" WHERE id=1');
      } catch(err) {
        console.error(err);
      }
});