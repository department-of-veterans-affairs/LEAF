import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('https://host.docker.internal/LEAF_Request_Portal/');

  // Expect a title "to contain" a substring.
  await expect(page).toHaveTitle(/Leaf/);
});
