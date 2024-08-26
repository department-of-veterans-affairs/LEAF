import { test, expect } from '@playwright/test';

test('change field heading', async ({ page }) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/admin/');

  let randNum = Math.random();
  let uniqueText = `Single line text ${randNum}`;

  await page.getByRole('button', { name: ' Form Editor Create and' }).click();
  await page.getByRole('link', { name: 'General Form' }).click();
  await page.getByTitle('edit indicator 3').click();
  await page.getByLabel('Section Heading').click();
  await page.getByLabel('Section Heading').fill(uniqueText);
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.locator('#format_label_3')).toContainText(uniqueText);
});