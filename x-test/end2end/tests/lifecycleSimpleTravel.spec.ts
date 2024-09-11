import { test, expect } from '@playwright/test';

// This test simulates the whole lifecycle of a request which covers: implementation,
// submission, approval, and reporting.
test.describe.configure({ mode: 'serial' });

// Generate unique text to help ensure that fields are being filled correctly.
let randNum = Math.random();
let uniqueText = `Travel ${randNum}`;

test('navigate to Workflow Editor and create a travel workflow', async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/admin/');

  await page.getByRole('button', { name: ' Workflow Editor Edit' }).click();

  // wait for async request to finish loading the first workflow
  await expect(page.getByLabel('workflow step: Group')).toBeInViewport();

  await page.getByRole('button', { name: 'New Workflow' }).click();
  await page.getByLabel('Workflow Title:').click();
  await page.getByLabel('Workflow Title:').fill(uniqueText);
  await page.getByRole('button', { name: 'Save' }).click();

  // wait for async request to finish saving
  // Workaround: Since the drag handles can overlap sometimes (maybe due to async rendering
  // in the jsPlumb library?), we'll move the requestor step out of the way first.
  // TODO: fix the workflow editor since end-users might have the same issue
  await expect(page.getByLabel('workflow step: Group')).not.toBeInViewport();
  await expect(page.locator('a').filter({ hasText: uniqueText })).toBeVisible();
  await expect(page.locator('rect').first()).toBeInViewport();
  // Workaround: Set specific position because the workflow step's drag handle overlaps with the connector's handle
  await page.getByLabel('workflow step: Requestor', { exact: true }).hover({position: {x: 16, y: 16}});
  await page.mouse.down();
  await page.mouse.move(250, 400);
  await page.mouse.up();

  await page.getByRole('button', { name: 'New Step' }).click();
  await page.getByLabel('Step Title:').fill('Supervisor Review');
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByLabel('workflow step: Supervisor')).toBeInViewport();

  // move the supervisor step to a typical location
  await page.getByLabel('workflow step: Supervisor').hover();
  await page.mouse.down();
  await page.mouse.move(650, 150);
  await page.mouse.up();

  // reload to workaround element order inconsistency (see above theory)
  await page.reload();
 
  let supervisorConnector = page.locator('.jtk-endpoint').nth(0);
  let requestorConnector = page.locator('.jtk-endpoint').nth(1);
  let endConnector = page.locator('.jtk-endpoint').nth(2);

  await requestorConnector.dragTo(supervisorConnector);
  await expect(page.getByText('Submit')).toBeInViewport();

  await supervisorConnector.dragTo(requestorConnector);
  await expect(page.getByText('Return to Requestor')).toBeInViewport();

  await supervisorConnector.dragTo(endConnector);
  await expect(endConnector).toBeInViewport();

  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByText('Approve')).toBeInViewport();

  // Add requirement to the Supervisor step
  await page.getByLabel('workflow step: Supervisor').click();
  await page.getByRole('button', { name: 'Add Requirement' }).click();
  await page.locator('a').filter({ hasText: 'Group A' }).click();
  await page.getByRole('option', { name: 'Service Chief' }).click();
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.locator('#step_requirements')).toContainText('Service Chief');

  await expect(page.getByText('Service Chief', { exact: true })).toBeInViewport();
  let screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });

  // hide modal for screenshot
  await page.getByLabel('Close Modal').click();
  await expect(page.getByText('Service Chief', { exact: true })).not.toBeInViewport();
  screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });
});

test('navigate to Form Editor and create a travel form', async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/admin/');

  await page.getByRole('button', { name: ' Form Editor Create and' }).click();
  await page.getByRole('button', { name: 'Create Form' }).click();
  await page.locator('#name').click();
  await page.locator('#name').fill(uniqueText);
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByLabel('Form name')).toHaveValue(uniqueText);

  await page.getByRole('button', { name: 'Add Section' }).click();
  await page.getByLabel('Section Heading').click();
  await page.getByLabel('Section Heading').fill('Traveler');
  await page.getByRole('button', { name: 'Save' }).click();
  await page.getByRole('button', { name: 'Add Question to Section' }).click();
  await page.getByLabel('Field Name').click();
  await page.getByLabel('Field Name').fill('Employee');
  await page.getByLabel('Input Format').selectOption('orgchart_employee');
  await page.getByText('Required').click();
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByRole('button', { name: 'Save' })).not.toBeVisible();
  await expect(page.getByText('Employee* Required')).toBeVisible();

  // Link the form to the workflow
  // selectOption only supports exact matches as of Playwright v.1.46, so
  // we need to retrieve the option's value first
  let optionToSelect = await page.locator('option', { hasText: uniqueText }).getAttribute('value');
  if(optionToSelect == null) {
    optionToSelect = '';
  }
  await page.locator('#workflowID').selectOption(optionToSelect);
  expect(page.locator('#workflowID')).toHaveValue(optionToSelect);

  const screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });
});

test('navigate to Homepage, create and submit a travel request', async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/');

  await page.getByText('New Request', { exact: true }).click();
  await page.getByRole('cell', { name: 'Select an Option Service' }).locator('a').click();
  await page.getByRole('option', { name: 'Cotton Computers' }).click();
  await page.getByLabel('Title of Request').click();
  await page.getByLabel('Title of Request').fill('e2e travel request');
  await page.locator('label').filter({ hasText: uniqueText }).locator('span').click();
  await page.getByRole('button', { name: 'Click here to Proceed' }).click();
  await page.getByLabel('Search for user to add as').click();
  await page.getByLabel('Search for user to add as').fill('a');
  await page.getByRole('cell', { name: 'Altenwerth, Ernest Bernier.' }).click();

  // selecting a user triggers an async request, wait for loading to complete
  await expect(page.getByText('*** Loading... ***')).not.toBeVisible();

  await page.getByRole('button', { name: 'Next Question', exact: true }).first().click();
  await expect(page.getByRole('button', { name: 'Submit Request' })).toBeInViewport();

  await page.getByRole('button', { name: 'Submit Request' }).click();
  await expect(page.getByRole('button', { name: 'Submit Request' })).not.toBeVisible();

  await expect(page.getByText('Pending Service Chief')).toBeInViewport();

  const screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });
});

test('navigate to Inbox, review and approve the travel request', async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/');

  await page.getByText('Inbox Review and apply').click();
  await page.getByRole('button', { name: 'View as Admin' }).click();
  await expect(page.locator('#inbox')).toContainText(uniqueText);

  await page.getByRole('button', { name: uniqueText }).click();
  await page.getByRole('button', { name: 'Take Action' }).click();
  await page.getByRole('button', { name: 'Approve' }).click();
  await expect(page.getByRole('button', { name: 'Take Action' })).not.toBeVisible();

  const screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });
});

test('navigate to the travel request and check approval status', async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/');

  await page.getByText(uniqueText).click();
  await expect(page.locator('#workflowbox_lastAction')).toContainText('Service Chief: Approved');

  await expect(page.getByText('Service Chief: Approved')).toBeInViewport();

  const screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });
});

test('navigate to the Report Builder, find the travel request, and check status', async ({ page }, testInfo) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/');

  await page.getByText('Report Builder').click();
  await page.getByRole('cell', { name: 'Current Status' }).locator('a').click();
  await page.getByRole('option', { name: 'Type' }).click();
  await page.getByRole('cell', { name: 'Complex Form' }).locator('a').click();
  await page.getByRole('option', { name: uniqueText }).click();
  await page.getByRole('button', { name: 'Next Step' }).click();
  await page.locator('#indicatorList').getByText('Current Status').click();
  await page.locator('#indicatorList').getByText(uniqueText, { exact: true }).click();

  await expect(page.locator('.formLabel').getByText(uniqueText)).toBeInViewport();

  /* TODO: find a working locator for this. we want to click on "Employee" in the middle column, and
           then expect to find the right employee in the view.
           Might need to retrieve the indicatorID for the field from an earlier step
  */
  // await page.locator('.indicatorOption').getByTitle('Employee').locator('span').first().click();

  await page.getByRole('button', { name: 'Generate Report' }).click();
  await expect(page.getByRole('cell', { name: 'Approved' })).toBeInViewport();

  const screenshot = await page.screenshot();
  await testInfo.attach('screenshot', { body: screenshot, contentType: 'image/png' });
});
