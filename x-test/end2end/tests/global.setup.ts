import { test as setup } from '@playwright/test';
import mysql from 'mysql2/promise';

setup('setup database', async ({ }) => {
    let db = await mysql.createConnection({
        host: process.env.MYSQL_HOST,
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: 'national_leaf_launchpad'
    });

    try {
        await db.query('USE leaf_portal_API_testing');
    } catch (err) {
        console.log('Test DB not found. Building it via API tester...');
        await fetch('http://host.docker.internal:8000/api/v1/test').then(res => res.text());
        console.log('API tester finished running.');
    }

    try {
        await db.query('USE national_leaf_launchpad');

        await db.query('UPDATE sites SET portal_database="leaf_portal_API_testing" WHERE id=1');
    } catch (err) {
        console.error(err);
    }
});