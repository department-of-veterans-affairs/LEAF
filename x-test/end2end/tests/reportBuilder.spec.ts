import { test, expect } from '@playwright/test';

// When the underlying issue is fixed, we should expect this test to pass.
// Tests should be tagged with an associated ticket or PR reference
test.fail('column order is maintained after modifying the search filter', {tag: '@issue:LEAF-4482'}, async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/?a=reports&v=3&query=N4IgLgpgTgtgziAXAbVASwCZJBghmXEAGhDQDsM0BjfAeygEkARbAVmJFoAdo6psAPBxj4qAC2wBOAAyyOAc3wRsAQQByLAL5F0WRDggAbCJCwluvMPWwBeYaImJpJRZFUaQmgLokAVrXIEFB8QOHowJGBtEHkTJnxCFBAAFg4ARjSOdhDDNBg0CMQ02WcQXPywAHkAM2q4EyRpTSA%3D%3D&indicators=NobwRAlgdgJhDGBDALgewE4EkAiYBcYyEyANgKZgA0YUiAthQVWAM4bL4AMAvpeNHCRosuAgBZmtBvjABZAK4kiAAhLQyy5GQAeHam3Qc8ARl79YCFBhwzjxyfUatoAc3Kr1mnXtbt8AJjNICyFrUTAAVgdpAgA5eQZ0BGYDIwBmbgBdIA%3D%3D&sort=N4Ig1gpgniBcIFYQBoQHsBOATCG4hwGcBjEAXyA%3D');

  await expect(page.getByLabel('Sort by Numeric')).toBeInViewport();
  await expect(page.locator('th').nth(4)).toContainText('Numeric');
  // Screenshot the original state
  let screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });

  await page.getByRole('button', { name: 'Modify Search' }).click();
  await page.getByLabel('text', { exact: true }).click();
  await page.getByLabel('text', { exact: true }).fill('8000');
  await page.getByRole('button', { name: 'Next Step' }).click();
  await expect(page.getByText('Develop search filter')).not.toBeInViewport();

  await page.getByRole('button', { name: 'Generate Report' }).click();
  await expect(page.getByText('Select Data Columns')).not.toBeInViewport();
  // this is not necessary, but it makes the screenshot look cleaner
  await expect(page.getByRole('button', { name: 'Generate Report' })).not.toBeInViewport();

  await expect(page.getByLabel('Sort by Numeric')).toBeInViewport();
  // Screenshot the new state. The column order should be the same.
  screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });

  await expect(page.locator('th').nth(4)).toContainText('Numeric');
});
