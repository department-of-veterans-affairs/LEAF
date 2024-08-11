import { test, expect } from '@playwright/test';

test('change title', async ({ page }) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/admin/');

  let randNum = Math.random();
  let uniqueText = `LEAF Test Site ${randNum}`;

  await page.getByRole('button', { name: ' Site Settings Edit site' }).click();

  // This is necessary because the input field starts off empty on this page
  // So we'll wait until the async request populates it
  await expect(page.getByLabel('Title of LEAF site')).not.toBeEmpty();

  await page.getByLabel('Title of LEAF site').click();
  await page.getByLabel('Title of LEAF site').fill(uniqueText);
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.locator('#headerDescription')).toContainText(uniqueText);
});
