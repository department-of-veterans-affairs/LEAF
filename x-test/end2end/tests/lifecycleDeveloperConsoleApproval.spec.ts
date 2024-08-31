import { test, expect } from '@playwright/test';

test('no javascript errors on supervisor selection page', async ({ page }) => {
  let errors = new Array<Error>;
  page.on('pageerror', err => {
    errors.push(err);
  });

  await page.goto('https://host.docker.internal/Test_Request_Portal/report.php?a=LEAF_start_leaf_dev_console_request');
  await page.getByRole('button', { name: 'I understand and accept' }).click();
  await page.getByRole('button', { name: 'Next Next Question' }).click();

  // wait for async request to complete
  await expect(page.getByText('Approval Officials', { exact: true })).toContainText('Approval Officials');

  expect(errors).toHaveLength(0);
});
