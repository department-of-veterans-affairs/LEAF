import { test, expect } from '@playwright/test';

test('search record ID', async ({ page }) => {
  await page.goto('https://host.docker.internal/LEAF_Request_Portal/');

  await page.getByLabel('Enter your search text').click();
  await page.getByLabel('Enter your search text').fill('500');
  await expect(page.getByRole('link', { name: '500' })).toBeVisible();
});

test('new record', async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/LEAF_Request_Portal/');
  
  let randNum = Math.random();
  let uniqueText = `New e2e request ${randNum}`;

  await page.getByText('New Request', { exact: true }).click();
  await page.getByRole('cell', { name: 'Select an Option Service' }).locator('a').click();
  await page.getByRole('option', { name: 'Iron Sports' }).click();
  await page.getByRole('cell', { name: 'Please enter keywords to' }).click();
  await page.getByLabel('Title of Request').fill(uniqueText);
  await page.getByText('Simple form').click();
  await page.getByRole('button', { name: 'Click here to Proceed' }).click();
  await page.getByLabel('single line text').click();
  await page.getByLabel('single line text').fill('single line');
  await page.getByRole('button', { name: 'Next Question', exact: true }).click();
  await expect(page.locator('#requestTitle')).toContainText(uniqueText);

  const screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });
});
