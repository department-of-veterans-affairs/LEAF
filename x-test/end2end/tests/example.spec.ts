import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('https://host.docker.internal/LEAF_Request_Portal/');

  // Expect a title "to contain" a substring.
  await expect(page).toHaveTitle(/Leaf/);
});

test('search record ID', async ({ page }) => {
  await page.goto('https://host.docker.internal/LEAF_Request_Portal/');
  await page.getByLabel('Enter your search text').click();
  await page.getByLabel('Enter your search text').fill('500');
  await expect(page.getByRole('link', { name: '500' })).toBeVisible();
});