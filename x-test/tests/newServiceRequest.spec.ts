import { test, expect } from '@playwright/test';
import  faker  from '@faker-js/faker';

const fixedText = "leaf-test"
  const randomString = faker.lorem.word(5);
  console.log(randomString);
  const todayDate: string = new Date().toISOString().slice(0, 10);
  const randomTextwithDate =  `${fixedText} ${todayDate}`;

test.describe.serial('Service Request Workflow', () =>{

test.only('create a new request and submit the form', async ({ page }) => {
  // Navigate to the Test Request Portal.
  await page.goto('https://host.docker.internal/Test_Request_Portal/');

  // Click on the "New Request" button to start creating a new request.
  await page.getByText('New Request', { exact: true }).click();

  // Select an option from the "Service" dropdown menu.
  await page.getByRole('cell', { name: 'Select an Option Service' }).locator('a').click();
  await page.getByRole('option', { name: 'Bronze Kids' }).click();

  // Click on the "Title of Request" input field and fill it with the request title.
  await page.getByLabel('Title of Request').click();
  await page.getByLabel('Title of Request').fill(randomTextwithDate);

  // Select the "Simple form" option by clicking on the corresponding label.
  await page.locator('label').filter({ hasText: 'Simple form' }).locator('span').click();

  // Ensure the "Click here to Proceed" button is visible before clicking it.
  await expect(page.getByRole('button', { name: 'Click here to Proceed' })).toBeVisible();
  await page.getByRole('button', { name: 'Click here to Proceed' }).click();

  // Click on the "single line text" input field and fill it with a response.
  await page.getByLabel('single line text').click();
  await page.getByLabel('single line text').fill('test question 1');

  // Click on the "Next Next Question" button to move to the next step of the form.
  await page.getByRole('button', { name: 'Next Next Question' }).click();

  // Ensure the "Submit Request" button is visible before clicking it to submit the form.
  await expect(page.getByRole('button', { name: 'Submit Request' })).toBeVisible();
  await page.getByRole('button', { name: 'Submit Request' }).click();

  // Verify that the submission status contains the text "Pending Group A".
  await expect(page.locator('#workflowbox_dep9')).toContainText('Pending Group A');

  // Click on the "Main Page" link to return to the main page.
  await page.getByRole('link', { name: 'Main Page' }).click();

  // Ensure the newly created request is visible on the main page.
  await expect(page.getByRole('link', { name: 'new request test' }).first()).toBeVisible();
});

test("new request test cancel emergency", async ({page}) => {
  await page.goto('https://host.docker.internal/Test_Request_Portal/');
  await page.getByText('New Request Start a new').click();
  await page.getByRole('cell', { name: 'Select an Option Service' }).locator('a').click();
  await page.getByRole('option', { name: 'AS Test Group' }).click();
  await page.getByRole('cell', { name: 'Normal Priority' }).click();
  await page.getByRole('option', { name: 'EMERGENCY' }).click();
  await page.getByLabel('Title of Request').click();
  await page.getByLabel('Title of Request').fill(randomTextwithDate);
  await page.locator('label').filter({ hasText: 'Simple form' }).locator('span').click();
  await page.getByRole('button', { name: 'Click here to Proceed' }).click();
  await page.getByLabel('single line text').click();
  await page.getByLabel('single line text').fill(randomString);
  await page.getByRole('button', { name: 'Next Next Question' }).click();
  await expect(page.locator('#headerTab')).toContainText('EMERGENCY');
  await expect(page.getByText('EMERGENCY', { exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Submit Request' }).click();
  await page.getByRole('link', { name: 'Main Page' }).click();
})

test("Validate Emergency Text", async ({page}) => {
  await expect(page.locator('#LeafFormGrid173_1002_title').getByText('( Emergency )')).toBeVisible();
  await page.getByRole('link', { name: 'Emergency' }).click();
  await page.getByRole('button', { name: 'Cancel Request' }).click();
  await page.getByPlaceholder('Enter Comment').click();
  await page.getByPlaceholder('Enter Comment').fill('cancel');
  await page.getByRole('button', { name: 'Yes Yes' }).click();
  await expect(page.locator('#bodyarea')).toContainText('Request #1002 has been cancelled!');
  await page.getByRole('link', { name: 'Main Page' }).click();
})


test('approve the newly created request', async ({ page }) => {
  // Navigate to the Test Request Portal.
  await page.goto('https://host.docker.internal/Test_Request_Portal/');

  // Click on the link for the new request to view its details.
  await page.getByRole('link', { name: 'new request test' }).first().click();

  // Click on the comment box for step 9 and fill it with a comment to approve the request.
  await page.locator('#comment_dep9').click();
  await page.locator('#comment_dep9').fill('This comment to approve');

  // Ensure the "Approve" button for step 9 is visible before clicking it to approve the request.
  await expect(page.locator('#button_step9_approve')).toBeVisible();
  await page.locator('#button_step9_approve').click();

  // Repeat the above steps to add and approve additional comments as required by the workflow.
  await page.getByLabel('comment text area').click();
  await page.getByLabel('comment text area').fill('another comment to approve');
  await expect(page.getByRole('button', { name: 'Approve' })).toBeVisible();
  await page.getByRole('button', { name: 'Approve' }).click();

  await page.getByLabel('comment text area').click();
  await page.getByLabel('comment text area').fill('another comment for group');
  await expect(page.getByRole('button', { name: 'Approve' })).toBeVisible();
  await page.getByRole('button', { name: 'Approve' }).click();

  await page.getByLabel('comment text area').click();
  await page.getByLabel('comment text area').fill('follow up comment');
  await expect(page.getByRole('button', { name: 'Approve' })).toBeVisible();
  await page.getByRole('button', { name: 'Approve' }).click();

  await page.getByLabel('comment text area').click();
  await page.getByLabel('comment text area').fill('another comment');
  await expect(page.getByRole('button', { name: 'Approve' })).toBeVisible();
  await page.getByRole('button', { name: 'Approve' }).click();

  // Verify that the workflow box contains the text indicating the group approval.
  await expect(page.locator('#workflowbox_lastAction')).toContainText('Group designated step: Approved');

  // Click on the "Main Page" link to return to the main page and verify the request status.
  // Finally, return to the main page and check that the request status reflects the approval
  await page.getByRole('link', { name: 'Main Page' }).click();
  await expect(page.getByText('Approved').first()).toBeVisible();
 });

});
